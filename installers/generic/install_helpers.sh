#!/bin/bash

requirements_check() {
  INPUT_ARGS="${1}"
  OLDIFS="${IFS}"
  IFS=","
  for ARG in ${INPUT_ARGS}; do
    if ! command -v $ARG &>/dev/null; then
      echo "You do not have $ARG installed.  Script cannot proceed.  Exiting"
      exit 1
    fi
  done
  IFS="${OLDIFS}"
}

install_dmg() {
  local DMG="${1}"
  ATTACHMENT_INFO=$(hdiutil attach "${DMG}" -nobrowse | grep '/Volumes')
  DEVICE_NAME=$(echo "${ATTACHMENT_INFO}" | awk -F '\t' '{print $1}')
  ATTACHMENT_PATH=$(echo "${ATTACHMENT_INFO}" | awk -F '\t' '{print $NF}')
  APPLICATION_NAME=$(ls "${ATTACHMENT_PATH}" | grep '.app$')
  cp -R "${ATTACHMENT_PATH}/${APPLICATION_NAME}" /Applications
  hdiutil detach $(echo "${DEVICE_NAME}" | awk '{print $1}')
}

install_pkg() {
  local PACKAGE="${1}"
  sudo installer -pkg "${PACKAGE}" -target /
}

install_package() {
  local PACKAGE="${1}"
  local TARGET_DIR=$(mktemp -d)
  local FILE_TYPE=$(file -bI "${PACKAGE}" | cut -d ';' -f1)
  case $FILE_TYPE in
  application/zip)
    unzip -q "${PACKAGE}" -d "${TARGET_DIR}"
    APP=$(ls "${TARGET_DIR}" | grep -E '(.app|.dmg)$')
    if [ ! -z "${APP}" ]; then
      install_package "${TARGET_DIR}/${APP}"
    fi
    ;;
  inode/directory)
    if ls /Applications | grep "$(echo "${PACKAGE}" | awk -F '/' '{print $NF}')"; then
      echo "Package ${PACKAGE} is already installed in /Applications"
      return 1
    elif echo "${PACKAGE}" | grep -q '.app'; then
      mv "${PACKAGE}" /Applications
    fi
    ;;
  application/x-mach-binary) # If there is no extension, we assume it is already a binary
    chmod +x "${TARGET_DIR}/${DOWNLOADED_RELEASE}"
    mv "${TARGET_DIR}/${DOWNLOADED_RELEASE}" "/usr/local/bin/${TOOL}"
    ;;
  application/zlib | application/octet-stream)
    install_dmg "${PACKAGE}"
    ;;
  application/x-xar)
    install_pkg "${PACKAGE}"
    ;;
  application/gzip)
    tar -zxvf "${PACKAGE}"

    ;;
  *)
    echo "Could not process ${TOOL}".
    echo "You might have to download it and configure it manually."
    ;;
  esac
  rm -r "${TARGET_DIR}"
}
