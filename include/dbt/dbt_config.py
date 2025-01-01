# dbt_config.py
from cosmos.config import ProfileConfig, ProjectConfig
from pathlib import Path

def get_dbt_config():
    DBT_CONFIG = ProfileConfig(
        profile_name='nyc_taxi',
        target_name='dev',
        profiles_yml_filepath=Path('/opt/airflow/include/dbt/profiles.yml')
    )
    
    DBT_PROJECT_CONFIG = ProjectConfig(
        dbt_project_path='/opt/airflow/include/dbt'
    )

    return DBT_PROJECT_CONFIG, DBT_CONFIG
