#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$ROOT_DIR/.venv"
LOCAL_DIR="$ROOT_DIR/.local"
PYTHON_BIN="${PYTHON:-python3}"
INSTALL_STAMP="$VENV_DIR/.adloop-installed"

cd "$ROOT_DIR"

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "Missing Python interpreter: $PYTHON_BIN" >&2
  exit 1
fi

mkdir -p "$LOCAL_DIR"

if [[ ! -f "$LOCAL_DIR/config.yaml" ]]; then
  cp "$ROOT_DIR/config.local.example.yaml" "$LOCAL_DIR/config.yaml"
  echo "Created $LOCAL_DIR/config.yaml from config.local.example.yaml"
fi

if [[ ! -x "$VENV_DIR/bin/python" ]]; then
  echo "Creating virtual environment in $VENV_DIR"
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

if [[ ! -f "$INSTALL_STAMP" || "$ROOT_DIR/pyproject.toml" -nt "$INSTALL_STAMP" ]]; then
  echo "Installing AdLoop and dependencies into $VENV_DIR"
  "$VENV_DIR/bin/pip" install --upgrade pip
  "$VENV_DIR/bin/pip" install -e .
  touch "$INSTALL_STAMP"
fi

echo "Local bootstrap complete."
