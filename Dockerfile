FROM ghcr.io/mlflow/mlflow:latest

RUN pip install --no-cache-dir mlflow[auth]

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
