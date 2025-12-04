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

# Function to update password after server starts
update_password() {
    sleep 5  # Wait for server to be ready

    # Try updating with default password first, then with target password (idempotent)
    for OLD_PASS in "password1234" "${PASSWORD}"; do
        curl -s -X PATCH -u "admin:${OLD_PASS}" \
            "http://localhost:5000/api/2.0/mlflow/users/update-password" \
            -H "Content-Type: application/json" \
            -d "{\"username\": \"admin\", \"password\": \"${PASSWORD}\"}" \
            2>/dev/null && echo "Password synced." && break
    done
}

# Run password update in background
update_password &

# Start MLflow server
exec "$@"
