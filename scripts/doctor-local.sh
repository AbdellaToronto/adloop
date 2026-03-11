#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_PATH="$ROOT_DIR/.local/config.yaml"

cd "$ROOT_DIR"

"$ROOT_DIR/scripts/bootstrap-local.sh" >/dev/null

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "Missing config file: $CONFIG_PATH" >&2
  exit 1
fi

"$ROOT_DIR/.venv/bin/python" - <<'PY'
from pathlib import Path
import sys

import yaml

root = Path.cwd()
config_path = root / ".local" / "config.yaml"
config = yaml.safe_load(config_path.read_text()) or {}

def get(path: str) -> str:
    value = config
    for key in path.split("."):
        value = value.get(key, "") if isinstance(value, dict) else ""
    return value or ""

required = {
    "google.project_id": "Google Cloud project ID",
    "ga4.property_id": "GA4 property ID",
    "ads.developer_token": "Google Ads developer token",
    "ads.customer_id": "Google Ads customer ID",
    "ads.login_customer_id": "Google Ads MCC login customer ID",
}

missing = [label for key, label in required.items() if not get(key)]

credentials_path = Path(get("google.credentials_path") or ".local/credentials.json")
if not credentials_path.is_absolute():
    credentials_path = root / credentials_path

if not credentials_path.exists():
    missing.append(f"OAuth/Desktop or service account credentials file at {credentials_path}")

if missing:
    print("AdLoop is not ready yet. Missing:")
    for item in missing:
        print(f"- {item}")
    sys.exit(1)

print("AdLoop local setup looks ready.")
PY
