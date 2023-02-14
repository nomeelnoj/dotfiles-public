#!/bin/bash

get_package() {
    TEMP_DIR=$(mktemp -d)
    PACKAGE="${1}"
    VERSION="${2:-latest}" # Default to latest if no version provided
    API_URL="https://api.releases.hashicorp.com/v1/releases/${PACKAGE}/latest"
    ARCH=$(arch)
    PACKAGE_URL=$(curl -s "${API_URL}" |\
      jq -r --arg arch "${ARCH}" \
      '.builds[] | select(.arch == $arch and (.os |startswith("darwin"))) | .url'
    )
    SHASUMS=$(curl -s $(curl -s "${API_URL}" | jq -r .url_shasums))
    wget "${PACKAGE_URL}" -P "${TEMP_DIR}"
    pushd "${TEMP_DIR}"
    PACKAGE_FILE=$(echo "${PACKAGE_URL}" | awk -F '/' '{print $NF}')
    PACKAGE_SHASUM=$(shasum -a 256 "${PACKAGE_FILE}")
    if [[ $(echo "${SHASUMS}" | grep "${PACKAGE_FILE}") != "${PACKAGE_SHASUM}" ]]; then
        echo "Shasum for ${PACKAGE} does not match.  You will have to install it manually."
        exit 1
    else
        unzip "${TEMP_DIR}/${PACKAGE_FILE}" -d /usr/local/bin/
    fi
    rm -rf "${TEMP_DIR}"
}

# CURRENT_DIR=$(pwd)
# echo "Current dir is ${CURRENT_DIR}"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
OLDIFS=$IFS
IFS=$'\n'
PACKAGES=$(cat "${SCRIPT_DIR}/hashicorp_packages.txt")

for PACKAGE in ${PACKAGES}; do
    IFS=$OLDIFS
    get_package $PACKAGE
done