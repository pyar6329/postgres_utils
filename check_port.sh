#!/bin/bash

SCRIPT_DIR=$(echo $(cd $(dirname $0) && pwd))
OUTPUT_FILE="${SCRIPT_DIR}/port_log.txt"

while (true); do
  echo "$(date '+%Y-%m-%d %H:%M:%S'): " | tr -d '\n' >> ${OUTPUT_FILE}
  pg_isready -U postgres -h ${CHECK_HOSTNAME} -p ${CHECK_PORT:-5432} >> ${OUTPUT_FILE} 2>&1
  tail -n 1 ${OUTPUT_FILE}
  sleep 1
done
