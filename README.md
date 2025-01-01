# Hands On Materi Apache Airflow in Data Engineer Class - Basic
This repository for course Data Engineer - Basic. In this course use tech stack :
- Data Ingestion & Transformation : Python, SQL and Pandas
- Workflow Orchestration : Apache Airflow
- Data Platform : OLTP(PostgreSQL)

Prerequisite :
- Already Install Docker Desktop for Windows OS or any docker software for Linux/Mac Os
- Already install postgresql in local computer
- Have knowledge Basic Docker & Docker Compose

Step by step to run Apache Airflow with use Docker

1) Download latest docker compose airflow in [here](https://airflow.apache.org/docs/apache-airflow/2.9.3/docker-compose.yaml)
2) Open docker-compose.yaml then add 1 parameter AIRFLOW__CORE__TEST_CONNECTION: 'Enabled' and update parameter AIRFLOW__CORE__LOAD__EXAMPLES become false
3) Run docker compose up -d



DBT
Running manually:
1. Enter the Airflow container
    ```
    docker exec -it <container_id> /bin/bash
    ```
2. Activate the dbt_venv
    ```
    source dbt_venv/bin/activate
    ```
3. Navigate to your dbt project
    ```
    cd include/dbt
    ```
4. Update the package
    ```
    dbt deps
    ```
5. Run dbt models
    ```
    dbt run --profiles-dir /opt/airflow/include/dbt/
    ```
6. Test dbt models
    ```
    dbt test --profiles-dir /opt/airflow/include/dbt/
    ```
    Note: Ensure the schema.yml has been created
7. Generate docs
    ```
    dbt docs generate
    ```
