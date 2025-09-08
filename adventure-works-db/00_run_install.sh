#!/usr/bin/env bash
set -euo pipefail

echo "Ejecutando 01_install.sql en la base ${POSTGRES_DB}..."

psql -v ON_ERROR_STOP=1 \
     -U "$POSTGRES_USER" \
     -d "${POSTGRES_DB}" \
     -f "/data/01_install.sql"
