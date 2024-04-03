export BACKUP_HOSTNAME=""
export BACKUP_PASSWORD=""
export BACKUP_PORT="5432"
export BACKUP_DATABASE=""
export BACKUP_USERNAME="postgres"

export RESTORE_HOSTNAME="localhost"
export RESTORE_PASSWORD="postgres"
export RESTORE_PORT="5432"
export RESTORE_DATABASE=""
export RESTORE_USERNAME="${USER}"

export PSQL_HOSTNAME="${RESTORE_HOSTNAME}"
export PSQL_PASSWORD="${RESTORE_PASSWORD}"
export PSQL_PORT="${RESTORE_PORT}"
export PSQL_DATABASE="${RESTORE_DATABASE}"
export PSQL_USERNAME="${RESTORE_USERNAME}"

export COMPRESSED_FILE_NAME="foobar" # it saved as foobar.tar.zst
export OUTPUT_S3_URL="s3://<bucket_name>/$(TZ=JST-9 date '+%Y%m%d')/${COMPRESSED_FILE_NAME}.tar.zst"
