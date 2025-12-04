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

# Function to update password after server starts (using urllib - stdlib, always available)
update_password() {
    sleep 10  # Wait for server to be ready

    python3 << PYTHON
import urllib.request
import urllib.error
import json
import base64
import sys

password = "${PASSWORD}"
url = "http://localhost:5000/api/2.0/mlflow/users/update-password"
data = json.dumps({"username": "admin", "password": password}).encode('utf-8')

# Try with default password first, then target password
for old_pass in ["password1234", password]:
    try:
        credentials = base64.b64encode(f"admin:{old_pass}".encode()).decode()
        req = urllib.request.Request(
            url,
            data=data,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Basic {credentials}"
            },
            method="PATCH"
        )
        with urllib.request.urlopen(req, timeout=5) as resp:
            if resp.status == 200:
                print("Password synced successfully.")
                sys.exit(0)
    except urllib.error.HTTPError as e:
        if e.code == 401:
            continue  # Try next password
        print(f"HTTP error: {e.code}")
    except Exception as e:
        print(f"Error: {e}")

print("Password sync completed.")
PYTHON
}

# Run password update in background
update_password &

# Start MLflow server
exec "$@"
