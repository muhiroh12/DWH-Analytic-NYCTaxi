from cosmos.config import ProfileConfig, ProjectConfig
from pathlib import Path

DBT_CONFIG = ProfileConfig(
    profile_name='nyc_taxi',
    target_name='dev',
    profiles_yml_filepath=Path('/opt/airflow/include/dbt/profiles.yml')
)

DBT_PROJECT_CONFIG = ProjectConfig(
    dbt_project_path='/opt/airflow/include/dbt'
)
