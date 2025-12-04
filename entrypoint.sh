#!/bin/bash
set -e

PASSWORD=${MLFLOW_ADMIN_PASSWORD:-password1234}

# Generate auth config
cat > /tmp/auth.ini << EOF
[mlflow]
default_permission = READ
database_uri = sqlite:///data/auth.db
admin_username = admin
admin_password = ${PASSWORD}
authorization_function = mlflow.server.auth:authenticate_request_basic_auth
EOF

export MLFLOW_AUTH_CONFIG_PATH=/tmp/auth.ini

# Function to update password after server starts (using Python since curl may not exist)
update_password() {
    sleep 8  # Wait for server to be ready

    python3 << PYTHON
import requests
import sys

password = "${PASSWORD}"
url = "http://localhost:5000/api/2.0/mlflow/users/update-password"
headers = {"Content-Type": "application/json"}
data = {"username": "admin", "password": password}

# Try with default password first
for old_pass in ["password1234", password]:
    try:
        resp = requests.patch(url, json=data, auth=("admin", old_pass), timeout=5)
        if resp.status_code == 200:
            print(f"Password synced successfully.")
            sys.exit(0)
    except Exception as e:
        pass

print("Password sync skipped (already set or server not ready).")
PYTHON
}

# Run password update in background
update_password &

# Start MLflow server
exec "$@"
