FROM apache/airflow:2.9.3-python3.9

ENV AIRFLOW_HOME=/opt/airflow
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

USER root

RUN apt-get update -qq && apt-get install -y vim curl git

COPY requirements.txt .
USER $AIRFLOW_UID
RUN pip install --no-cache-dir -r requirements.txt

RUN pip install --no-cache-dir astronomer-cosmos[dbt-bigquery]

ENV PIP_USER=false

RUN python -m venv soda_venv && source soda_venv/bin/activate && \
    pip install --no-cache-dir soda-core-bigquery && \
    pip install --no-cache-dir soda-core-scientific && deactivate

RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
    pip install --no-cache-dir dbt-bigquery && deactivate

ENV PIP_USER=true

SHELL ["/bin/bash", "-o", "pipefail", "-e", "-u", "-x", "-c"]

ARG CLOUD_SDK_VERSION=436.0.0
ENV GCLOUD_HOME=/home/google-cloud-sdk
ENV PATH="${GCLOUD_HOME}/bin/:${PATH}"

USER root
RUN DOWNLOAD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz" \
    && TMP_DIR="$(mktemp -d)" \
    && curl -fl --http1.1 "${DOWNLOAD_URL}" --output "${TMP_DIR}/google-cloud-sdk.tar.gz" \
    && mkdir -p "${GCLOUD_HOME}" \
    && tar xzf "${TMP_DIR}/google-cloud-sdk.tar.gz" -C "${GCLOUD_HOME}" --strip-components=1 \
    && "${GCLOUD_HOME}/install.sh" \
       --bash-completion=false \
       --path-update=false \
       --usage-reporting=false \
       --quiet \
    && rm -rf "${TMP_DIR}" \
    && gcloud --version

USER $AIRFLOW_UID

WORKDIR $AIRFLOW_HOME

COPY scripts scripts

USER root
RUN chmod +x scripts/*

USER $AIRFLOW_UID
