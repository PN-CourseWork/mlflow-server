#!/bin/bash
set -e

# Generate auth config from environment variable
cat > /tmp/auth.ini << EOF
[mlflow]
default_permission = READ
database_uri = sqlite:///data/auth.db
admin_username = admin
admin_password = ${MLFLOW_ADMIN_PASSWORD:-password1234}
authorization_function = mlflow.server.auth:authenticate_request_basic_auth
EOF

export MLFLOW_AUTH_CONFIG_PATH=/tmp/auth.ini
exec "$@"
