#!/bin/bash

set -e

SCRIPT_DIR=$(echo $(cd $(dirname $0) && pwd))

# install aws-cli
if ! $(type aws > /dev/null 2>&1); then
  # for mac
  if $(type brew > /dev/null 2>&1); then
    brew install awscli

  # for ubuntu 22.04
  elif $(type apt-get > /dev/null 2>&1); then
    sudo apt-get install -y --no-install-recommends awscli

  # for arch linux
  elif $(type pacman > /dev/null 2>&1); then
    sudo pacman -S aws-cli-v2
  else
    echo "aws-cli is not found. Please install it"
    exit 1
  fi
fi

aws s3 cp ${OUTPUT_S3_URL} ${SCRIPT_DIR}/${COMPRESSED_FILE_NAME}.tar.zst

echo "backup data was downloaded to: ${COMPRESSED_FILE_NAME}.tar.zst"
