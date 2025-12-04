# MLflow Server

Self-hosted MLflow tracking server with authentication, designed for Coolify deployment.

## Features

- SQLite backend for experiment tracking
- Artifact storage with proxy serving
- Basic authentication with auto-generated admin password
- Persistent named volume for data

## Quick Start (Local)

```bash
docker compose up -d
# Access at http://localhost:5001
# Default credentials: admin / password1234
```

## Coolify Deployment

1. Create a new service in Coolify using this repo
2. Coolify auto-generates `SERVICE_PASSWORD_64_MLFLOW_ADMIN` for the admin password
3. Find the password in Coolify's environment variables dashboard

## Client Configuration

```bash
export MLFLOW_TRACKING_URI=https://your-mlflow-domain.com
export MLFLOW_TRACKING_USERNAME=admin
export MLFLOW_TRACKING_PASSWORD=<from coolify dashboard>
```

## Data Persistence

All data is stored in the `mlflow-data` named volume:
- `mlflow.db` - experiments, runs, metrics, parameters
- `artifacts/` - uploaded files
- `auth.db` - user accounts
