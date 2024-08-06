#!/bin/bash

set -e

ARGS="$@"
SCRIPT_DIR=$(echo $(cd $(dirname $0) && pwd))

POSTGRES_DATA="${SCRIPT_DIR}/data"
POSTGRES_INITDB="${SCRIPT_DIR}/initdb"

IMAGE_NAME="ghcr.io/pyar6329/postgres:14.11-2"

OS_NAME="$(uname -s)"

if ! [ -e "${POSTGRES_DATA}" ]; then
  mkdir -p ${POSTGRES_DATA}
fi

function run_postgres {
  # it create network when network is not found
  if ! $(docker network ls | grep ${DOCKER_NETWORK_NAME:-postgres} > /dev/null 2>&1); then
    docker network create ${DOCKER_NETWORK_NAME:-postgres}
    echo "postgres network () was created. Please check 'docker network ls'"
  fi

  if $(docker ps -a | grep postgres > /dev/null 2>&1); then
    echo "postgres container was already running."
  else
    case "${OS_NAME}" in
      "Darwin" )
        docker run -it \
          -d \
          --name "postgres" \
          --restart always \
          --cpus="2" \
          --memory=1024mb \
          --network "${DOCKER_NETWORK_NAME:-postgres}" \
          -p "${POSTGRES_PORT:-5432}:5432" \
          -e "POSTGRES_DB=${POSTGRES_DATABASE:-dsf_api}" \
          -e "POSTGRES_USER=${USER}" \
          -e "POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}" \
          -e "TZ=UTC" \
          -e "LANG=C.UTF-8" \
          -e "LC_ALL=C.UTF-8" \
          -e "PGDATA=/data" \
          -v "${POSTGRES_INITDB}:/docker-entrypoint-initdb.d" \
          -v "${POSTGRES_DATA}:/data" \
          ${IMAGE_NAME} postgres \
          -c log_destination=stderr \
          -c log_statement=all \
          -c log_connections=on \
          -c log_disconnections=on \
          -c shared_preload_libraries='auto_explain' \
          -c auto_explain.log_min_duration=0 \
          -c auto_explain.log_analyze=on \
          -c auto_explain.log_buffers=on \
          -c auto_explain.log_format=text \
          -c auto_explain.log_verbose=on \
          -c auto_explain.log_triggers=on
        ;;
      * )
        docker run -it \
          -d \
          --name "postgres" \
          --restart always \
          --cpus="2" \
          --memory=1024mb \
          --network "${DOCKER_NETWORK_NAME:-postgres}" \
          -p "${POSTGRES_PORT:-5432}:5432" \
          -e "POSTGRES_DB=${POSTGRES_DATABASE:-dsf_api}" \
          -e "POSTGRES_USER=${USER}" \
          -e "POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}" \
          -e "TZ=UTC" \
          -e "LANG=C.UTF-8" \
          -e "LC_ALL=C.UTF-8" \
          -e "PGDATA=/data" \
          -u $(id -u ${USER}):$(id -g ${USER}) \
          -v /etc/passwd:/etc/passwd:ro \
          -v /etc/group:/etc/group:ro \
          -v "${POSTGRES_INITDB}:/docker-entrypoint-initdb.d" \
          -v "${POSTGRES_DATA}:/data" \
          ${IMAGE_NAME} postgres \
          -c log_destination=stderr \
          -c log_statement=all \
          -c log_connections=on \
          -c log_disconnections=on \
          -c shared_preload_libraries='auto_explain' \
          -c auto_explain.log_min_duration=0 \
          -c auto_explain.log_analyze=on \
          -c auto_explain.log_buffers=on \
          -c auto_explain.log_format=text \
          -c auto_explain.log_verbose=on \
          -c auto_explain.log_triggers=on
        ;;
    esac
    # log_destination: ログの出力先
    # log_statement: クエリをログに出力する
    # log_connections: コネクション接続時にログを出力する
    # log_disconnections: コネクション切断時にログを出力する
  fi
}

function shutdown_postgres {
  # The process is killed if process exists
  if $(docker ps -a | grep postgres > /dev/null 2>&1); then
    docker rm -vf postgres
  else
    echo "postgres server was already downed"
  fi

  # The network is removed if network exists
  if $(docker network ls | grep ${DOCKER_NETWORK_NAME:-postgres} > /dev/null 2>&1); then
    docker network rm -f ${DOCKER_NETWORK_NAME:-postgres}
  else
    echo "postgres network (${DOCKER_NETWORK_NAME:-postgres}) was already deleted"
  fi
}

function into_shell {
  # The process is killed if process exists
  if $(docker ps -a | grep postgres > /dev/null 2>&1); then
    docker exec -it postgres bash
  else
    echo "postgres server was already downed"
  fi
}

function run_psql {
  # The process is killed if process exists
  if $(docker ps -a | grep postgres > /dev/null 2>&1); then
    docker exec -it postgres psql "host=localhost port=5432 sslmode=disable dbname=${POSTGRES_DATABASE:-dsf_api} user=${USER} password=${POSTGRES_PASSWORD:-postgres}"
  else
    echo "postgres server was already downed"
  fi
}

case "${ARGS}" in
  "--up" )
    run_postgres
    ;;
  "--down" )
    shutdown_postgres
    ;;
  "--shell" )
    into_shell
    ;;
  "--psql" )
    run_psql
    ;;
  * )
    echo "argument is required. Please set '--up' or '--down'"
    ;;
esac
