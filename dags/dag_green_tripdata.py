import os
import sys
from datetime import datetime, timedelta
import pandas as pd
import requests
import logging
from pathlib import Path 

from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.python import PythonOperator
from airflow.decorators import dag, task

from airflow.providers.google.cloud.transfers.local_to_gcs import LocalFilesystemToGCSOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator

sys.path.append('/opt/airflow/include')
from dbt.dbt_config import get_dbt_config
from cosmos.airflow.task_group import DbtTaskGroup
from cosmos.constants import LoadMode
from cosmos.config import ProjectConfig, RenderConfig



PROJECT_ID = os.environ.get('GCP_PROJECT_ID')
BUCKET = os.environ.get('GCP_GCS_BUCKET')

year = '2023'
month = '12'

year_nt = int(year)

filename_raw = f"green_tripdata_{year}-{month}.parquet"
dataset_transform = f"tf_green_tripdata_{year}-{month}.parquet"
path_to_raw_dataset = '/opt/airflow/dataset/raw/nyc_taxi'
path_to_transform_dataset = '/opt/airflow/dataset/transform'
zone_map = 'taxi_zone_lookup.csv'
tf_zone_map = 'taxi_zone_lookup.parquet'

tripdata_url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/{filename_raw}"
zone_lookup_url = "https://d37ci6vzurychx.cloudfront.net/misc/taxi+_zone_lookup.csv"


default_args = {
    "owner": "Muhii",
    "start_date": days_ago(1),
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "email": "muhii.smta@gmail.com",
    "retries": 1,
    "retry_delay": timedelta(minutes=5)
}

def extract():
    def download_file(url, destination):
        response = requests.get(url)
        with open(destination, 'wb') as f:
            f.write(response.content)

    os.makedirs(path_to_raw_dataset, exist_ok=True)
    download_file(tripdata_url, os.path.join(path_to_raw_dataset, filename_raw))
    download_file(zone_lookup_url, os.path.join(path_to_raw_dataset, zone_map))

def transform():
    df = pd.read_parquet(os.path.join(path_to_raw_dataset, filename_raw))
    df_zone = pd.read_csv(os.path.join(path_to_raw_dataset, zone_map))
    if df.shape[0] > 0:
        df = df.drop_duplicates()
        df = df.dropna(subset=['passenger_count', 'trip_distance', 'fare_amount', 'total_amount'])
        df = df[(df['trip_distance'] > 0) &
                (df['passenger_count'] > 0) &
                (df['fare_amount'] > 0) &
                (df['mta_tax'] > 0) &
                (df['total_amount'] > 0)]
        
        df['lpep_pickup_datetime'] = pd.to_datetime(df['lpep_pickup_datetime'], errors='coerce')
        df['lpep_dropoff_datetime'] = pd.to_datetime(df['lpep_dropoff_datetime'], errors='coerce')
        
        df = df[df['lpep_pickup_datetime'] < df['lpep_dropoff_datetime']]
        df = df[df['lpep_pickup_datetime'].dt.year == year_nt]
        
        df['RatecodeID'] = df['RatecodeID'].fillna(6).astype('int64')
        df['payment_type'] = df['payment_type'].fillna(6).astype('int64')
        df['trip_type'] = df['trip_type'].fillna(99).astype('int64')
        df['ehail_fee'] = df['ehail_fee'].fillna(99).astype('int64')
        
        df = df.astype({
            'VendorID': 'int64',
            'RatecodeID': 'int64',
            'passenger_count': 'int64',
            'payment_type': 'int64',
            'trip_type': 'int64',
            'ehail_fee': 'int64',
        })
    
        df_trip= df.rename(columns= {
            'VendorID': 'vendor_id',
            'lpep_pickup_datetime': 'lpep_pickup_datetime',
            'lpep_dropoff_datetime': 'lpep_dropoff_datetime',
            'store_and_fwd_flag': 'store_and_fwd_flag',
            'RatecodeID': 'rate_code_id',
            'PULocationID': 'pu_location_id',
            'DOLocationID': 'do_location_id',
            'passenger_count': 'passenger_count',
            'trip_distance': 'trip_distance',
            'fare_amount': 'fare_amount',
            'extra': 'extra',
            'mta_tax': 'mta_tax',
            'tip_amount': 'tip_amount',
            'tolls_amount': 'tolls_amount',
            'ehail_fee': 'ehail_fee',
            'improvement_surcharge': 'improvement_surcharge',
            'total_amount': 'total_amount',
            'payment_type': 'payment_type',
            'trip_type': 'trip_type',
            'congestion_surcharge': 'congestion_surcharge',
        })
        
        #check total_amount
        # other_amount = df['extra'] + df['mta_tax'] + df['fare_amount'] + df['toll_amount'] + df['tip_amount'] + df['improvement_surcharge'] + df['congestion_surcharge']
        # diff_amount_ori = df['total_amount'] - other_amount
        
        # if diff_amount_ori < 0:
        #     df.replace({
        #         'improvement_surcharge': 0,
        #         'congestion_surcharge': 0
        #     })
        # else:
        #     None
        
        df_trip.index = range(1, len(df_trip)+1)
        
        #rename columns for zone map
        df_zone_map = df_zone.rename(columns={
            'LocationID': 'location_id',
            'Borough': 'borough',
            'Zone': 'zone',
            'service_zone': 'service_zone',
        })
        
        os.makedirs(path_to_transform_dataset, exist_ok=True)
        df_trip.to_parquet(os.path.join(path_to_transform_dataset, dataset_transform), index=True)
        df_zone_map.to_parquet(os.path.join(path_to_transform_dataset, tf_zone_map), index=False)
        print(f"Data successfully saved to {dataset_transform}.")

# logging
logging.basicConfig(level=logging.INFO)

#@task.external_python(python='/opt/airflow/soda_venv/bin/python')
def check_load(scan_name='check_load', checks_subpath='sources'):
    import sys
    sys.path.append('/opt/airflow')
    from include.soda.check_function import check

    result = check(scan_name, checks_subpath)
    logging.info(f'Result from check: {result} of type {type(result)}')
    
    return str(result)

DBT_PROJECT_CONFIG, DBT_CONFIG = get_dbt_config()

def check_dbt_transform(scan_name='check_dbt_transform', checks_subpath='transform'):
    import sys
    sys.path.append('/opt/airflow')
    from include.soda.check_function import check

    result = check(scan_name, checks_subpath)
    logging.info(f'Result from check: {result} of type {type(result)}')
    
    return str(result)

with DAG(
    dag_id="nyc_green_tripdata",
    schedule_interval="@once",
    default_args=default_args,
    catchup=False
) as dag:
    
    download_dataset_task = PythonOperator(
        task_id="download_dataset_task",
        python_callable=extract,
    )
    
    upload_tripdata_raw_to_gcs = LocalFilesystemToGCSOperator(
        task_id = 'upload_green_tripdata_raw',
        src = f"{path_to_raw_dataset}/{filename_raw}",
        dst = f"raw/{filename_raw}",
        bucket = BUCKET
    )
    
    upload_zone_to_gcs = LocalFilesystemToGCSOperator(
        task_id = 'upload_zone_map',
        src = f"{path_to_raw_dataset}/{zone_map}",
        dst = f"raw/{zone_map}",
        bucket = BUCKET
    )

    transform_data_task = PythonOperator(
        task_id="transform_data_task",
        python_callable=transform,
    )
    
    upload_tripdata_transform_to_gcs = LocalFilesystemToGCSOperator(
        task_id = 'upload_tripdata_transform_to_gcs',
        src = f"{path_to_transform_dataset}/{dataset_transform}",
        dst = f"transform/{dataset_transform}",
        bucket = BUCKET
    )
    
    upload_zone_transform_to_gcs = LocalFilesystemToGCSOperator(
        task_id = 'upload_zone_transform_to_gcs',
        src = f"{path_to_transform_dataset}/{tf_zone_map}",
        dst = f"transform/{tf_zone_map}",
        bucket = BUCKET
    )
    
    load_tripdata_to_bq = GCSToBigQueryOperator(
        task_id = 'load_tripdata_to_bq',
        bucket = BUCKET,
        source_format="PARQUET",
        source_objects = f"transform/{dataset_transform}",
        destination_project_dataset_table = PROJECT_ID + ".nyc_taxi.green_tripdata",
        create_disposition='CREATE_IF_NEEDED',
        write_disposition='WRITE_APPEND',
        )
    
    load_zone_map_to_bq = GCSToBigQueryOperator(
        task_id = 'load_zone_map_to_bq',
        bucket = BUCKET,
        source_format="PARQUET",
        source_objects = f"transform/{tf_zone_map}",
        destination_project_dataset_table = PROJECT_ID + ".nyc_taxi.zone_map",
        create_disposition='CREATE_IF_NEEDED',
        write_disposition='WRITE_APPEND',
        )
    
    check_load_tripdata = PythonOperator(
    task_id="check_load_tripdata",
    python_callable=check_load,
    )
    
    transform_dbt_task = DbtTaskGroup(
            group_id='dbt_transform',
            project_config=DBT_PROJECT_CONFIG,
            profile_config=DBT_CONFIG,
            render_config=RenderConfig(
                load_method=LoadMode.DBT_LS,
                select=['path:models/transform']
            )
        )
    
    report_dbt_task = DbtTaskGroup(
            group_id='dbt_report',
            project_config=DBT_PROJECT_CONFIG,
            profile_config=DBT_CONFIG,
            render_config=RenderConfig(
                load_method=LoadMode.DBT_LS,
                select=['path:models/report']
            )
        )
    
    check_dbt_model = PythonOperator(
    task_id="check_dbt_model",
    python_callable=check_dbt_transform,
    )

    download_dataset_task >> upload_tripdata_raw_to_gcs >> transform_data_task >> upload_tripdata_transform_to_gcs >> load_tripdata_to_bq >> check_load_tripdata >> transform_dbt_task >> report_dbt_task
    download_dataset_task >> upload_zone_to_gcs >> transform_data_task >> upload_zone_transform_to_gcs >> load_zone_map_to_bq >> transform_dbt_task