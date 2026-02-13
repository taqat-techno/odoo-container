#!/bin/bash
set -e

# Install Odoo in editable mode (needed for Odoo 19 which has no __init__.py)
# --no-deps: dependencies already installed from requirements.txt
pip install --user --no-deps -e /opt/odoo/source 2>/dev/null

exec python /opt/odoo/source/setup/odoo "$@"
