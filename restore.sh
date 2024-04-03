#!/bin/bash

set -e

# set below environment variables
# RESTORE_HOSTNAME="database hostname"
# RESTORE_PASSWORD="database password"
# RESTORE_PORT="database port"
# RESTORE_DATABASE="database name"
# RESTORE_USERNAME="database username"

OUTPUT_DIR="${COMPRESSED_FILE_NAME}"

case "$(uname -s)" in
  ("Darwin") CPU_CORES=$(sysctl -n hw.ncpu);;
  ("Linux") CPU_CORES=$(grep -c processor /proc/cpuinfo);;
esac

BEGIN_SECOND=${SECONDS}

if ! [ -e "${OUTPUT_DIR}" ]; then
  mkdir -p ${OUTPUT_DIR}
fi
tar -I pzstd -xf ${OUTPUT_DIR}.tar.zst -C ${OUTPUT_DIR} --strip-components 1
echo "extract is finished"

PGPASSWORD=${RESTORE_PASSWORD} pg_restore \
  -h ${RESTORE_HOSTNAME} \
  -p ${RESTORE_PORT} \
  -U ${RESTORE_USERNAME} \
  -w \
  -d ${RESTORE_DATABASE} \
  -v \
  -j ${CPU_CORES} \
  -F d \
  -x \
  -O \
  ${OUTPUT_DIR}

echo "pg_restore is finished"
rm -rf ${OUTPUT_DIR}

# -Jはdead lock発生するので外す
PGPASSWORD=${RESTORE_PASSWORD} vacuumdb \
  -h ${RESTORE_HOSTNAME} \
  -p ${RESTORE_PORT} \
  -U ${RESTORE_USERNAME} \
  -d ${RESTORE_DATABASE} \
  -w \
  -z \
  -f \
  -v

END_SECOND=${SECONDS}
TOTAL_SECOND=$(( ${END_SECOND} - ${BEGIN_SECOND} ))
RESULT_HOUR=$(eval "echo $(date -ud "@${TOTAL_SECOND}" +'$((%s/3600/24)) days %H hours %M minutes %S seconds')")
echo "total: ${RESULT_HOUR}"

echo "run SQL: ANALYZE VERBOSE;"

PGPASSWORD=${RESTORE_PASSWORD} psql \
  -h ${RESTORE_HOSTNAME} \
  -p ${RESTORE_PORT} \
  -U ${RESTORE_USERNAME} \
  -d ${RESTORE_DATABASE} \
  -w \
  -c "ANALYZE VERBOSE;"

echo "completed run SQL: ANALYZE VERBOSE;"
