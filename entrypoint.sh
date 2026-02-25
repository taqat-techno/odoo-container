#!/bin/bash
set -e

export PYTHONPATH=/opt/odoo/source:${PYTHONPATH:-}

if [ "${DEV_MODE:-0}" = "1" ]; then
    set -- "$@" --dev=all
fi

if [ "${ENABLE_DEBUGGER:-0}" = "1" ]; then
    pip install --user --quiet debugpy 2>/dev/null
    exec python -m debugpy --listen 0.0.0.0:5678 --wait-for-client \
        /opt/odoo/source/setup/odoo "$@"
fi

exec python /opt/odoo/source/setup/odoo "$@"
