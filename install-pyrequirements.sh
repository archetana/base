#!/bin/bash
set -x #echo on

python3 -m venv venv
source /venv/bin/activate
python3 -m pip install --no-cache-dir cython
python3 -m pip install --no-cache-dir -r /app/python/requirements.txt
