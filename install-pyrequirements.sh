#!/bin/bash
set -x #echo on

python3 -m venv venv
source /venv/bin/activate
python3 -m pip install --no-cache-dir cython
python3 -m pip install --no-cache-dir -r /app/python/requirements.txt
rm -f /venv/lib/python3.9/site-packages/pyspark/jars/log4j-1.2.17.jar
