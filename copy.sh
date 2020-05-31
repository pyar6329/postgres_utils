#!/bin/bash

set -e

# set below environment variables
# BACKUP_HOSTNAME="database hostname"
# BACKUP_PASSWORD="database password"
# BACKUP_PORT="database port"
# BACKUP_DATABASE="database name"
# BACKUP_USERNAME="database username"

OUTPUT_DIR="${BACKUP_DATABASE}"

case "$(uname -s)" in
  ("Darwin") CPU_CORES=$(sysctl -n hw.ncpu);;
  ("Linux") CPU_CORES=$(grep -c processor /proc/cpuinfo);;
esac

BEGIN_SECOND=${SECONDS}

PGPASSWORD=${BACKUP_PASSWORD} pg_dump \
  -h ${BACKUP_HOSTNAME} \
  -p ${BACKUP_PORT} \
  -U ${BACKUP_USERNAME} \
  -w \
  -d ${BACKUP_DATABASE} \
  -v \
  -j ${CPU_CORES} \
  -F d \
  -Z 0 \
  -f ${OUTPUT_DIR}

echo "pg_dump is finished"

tar -I "pzstd -19" -cvf ${OUTPUT_DIR}.tar.zst ${OUTPUT_DIR}
rm -rf ${OUTPUT_DIR}

echo "compress is finished"

END_SECOND=${SECONDS}
TOTAL_SECOND=$(( ${END_SECOND} - ${BEGIN_SECOND} ))
RESULT_HOUR=$(eval "echo $(date -ud "@${TOTAL_SECOND}" +'$((%s/3600/24)) days %H hours %M minutes %S seconds')")
echo "total: ${RESULT_HOUR}"
