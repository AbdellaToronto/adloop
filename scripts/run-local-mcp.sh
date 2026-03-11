#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

"$ROOT_DIR/scripts/bootstrap-local.sh"

if ! "$ROOT_DIR/scripts/doctor-local.sh"; then
  cat <<'EOF' >&2

Finish these manual steps before starting AdLoop:
1. Put your OAuth Desktop credentials JSON at .local/credentials.json
   or update google.credentials_path in .local/config.yaml.
2. Fill in .local/config.yaml with:
   - google.project_id
   - ga4.property_id
   - ads.developer_token
   - ads.customer_id
   - ads.login_customer_id
3. Run this command again. The first successful auth run will open a browser
   and create .local/token.json automatically.
EOF
  exit 1
fi

export ADLOOP_CONFIG="$ROOT_DIR/.local/config.yaml"

exec "$ROOT_DIR/.venv/bin/python" -m adloop
