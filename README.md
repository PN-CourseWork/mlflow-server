# MLflow Server

Self-hosted MLflow tracking server with authentication, designed for Coolify deployment.

## Features

- SQLite backend for experiment tracking
- Artifact storage with proxy serving
- Basic authentication with auto-generated admin password
- Multi-user support with permissions (READ, EDIT, MANAGE)
- Persistent named volume for data

## Quick Start (Local)

```bash
docker compose up -d
# Access at http://localhost:5001
# Default credentials: admin / password1234
```

## Coolify Deployment

1. Create a new service in Coolify using this repo
2. Set domain in Coolify UI (e.g., `https://yourdomain.com/mlflow:5000`)
3. Coolify auto-generates `SERVICE_PASSWORD_MLFLOW` for the admin password
4. Find the password in Coolify's environment variables dashboard

## User Management

### Creating Users

**Option 1: Signup page**
Visit `https://your-mlflow-domain/signup` to create a new account.

**Option 2: Admin API**
```bash
curl -X POST -u admin:$ADMIN_PASSWORD \
  "https://your-mlflow-domain/api/2.0/mlflow/users/create" \
  -H "Content-Type: application/json" \
  -d '{"username": "teammate", "password": "their-password"}'
```

**Option 3: Python**
```python
from mlflow.server import get_app_client

auth_client = get_app_client("basic-auth", tracking_uri="https://your-mlflow-domain/")
auth_client.create_user(username="teammate", password="their-password")
```

### Permissions

| Permission | Can Read | Can Update | Can Delete | Can Manage |
|------------|----------|------------|------------|------------|
| READ       | Yes      | No         | No         | No         |
| EDIT       | Yes      | Yes        | No         | No         |
| MANAGE     | Yes      | Yes        | Yes        | Yes        |

- **Default permission**: READ (all users can view experiments)
- **Experiment creators**: Automatically get MANAGE permission
- **Admin users**: Unrestricted access to everything

### Granting Permissions

```python
from mlflow.server import get_app_client

auth_client = get_app_client("basic-auth", tracking_uri="https://your-mlflow-domain/")
auth_client.create_experiment_permission(
    experiment_id="1",
    username="teammate",
    permission="EDIT"  # or "MANAGE"
)
```

### Promoting to Admin

```python
auth_client.update_user_admin(username="teammate", is_admin=True)
```

## Client Configuration

```bash
export MLFLOW_TRACKING_URI=https://your-mlflow-domain
export MLFLOW_TRACKING_USERNAME=your-username
export MLFLOW_TRACKING_PASSWORD=your-password
```

Or use `~/.mlflow/credentials`:
```ini
[mlflow]
mlflow_tracking_username = your-username
mlflow_tracking_password = your-password
```

## Data Persistence

All data is stored in the `mlflow-data` named volume:
- `mlflow.db` - experiments, runs, metrics, parameters
- `artifacts/` - uploaded files
- `auth.db` - user accounts and permissions
