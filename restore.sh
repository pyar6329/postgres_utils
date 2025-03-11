#!/bin/bash

set -e

# set below environment variables
# RESTORE_HOSTNAME="database hostname"
# RESTORE_PASSWORD="database password"
# RESTORE_PORT="database port"
# RESTORE_DATABASE="database name"
# RESTORE_USERNAME="database username"

SCRIPT_DIR=$(echo $(cd $(dirname $0) && pwd))

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

OS_NAME=$(uname -s)

if [ "${OS_NAME}" = "Linux" ]; then
  IMAGE_NAME=$(cat "${SCRIPT_DIR}/run_server.sh" | grep 'IMAGE_NAME' | grep 'ghcr' | awk -F '=' '{print $2}' | tr -d '"' | tr -d '\n')

  docker run --rm \
    -e PGPASSWORD=${RESTORE_PASSWORD} \
    -e PGOPTIONS="-c statement_timeout=0" \
    -v ${SCRIPT_DIR}/${OUTPUT_DIR}:/restore_data \
    ${IMAGE_NAME} \
    pg_restore \
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
      /restore_data
else
  PGPASSWORD=${RESTORE_PASSWORD} \
  PGOPTIONS="-c statement_timeout=0" \
  pg_restore \
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
fi

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
