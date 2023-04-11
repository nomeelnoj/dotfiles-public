#!/bin/bash

export DOTFILE_PATH="${HOME}/src/github.com/nomeelnoj/dotfiles"

source "${DOTFILE_PATH}/installers/generic/install_helpers.sh"

BREW_CASK_INSTALLS="${DOTFILE_PATH}/installers/brew/casks.txt"
BREW_FORMULAE_INSTALLS="${DOTFILE_PATH}/installers/brew/formulae.txt"

install_brew_cask() {
  # I hate homebrew, so we use it as little as possible
  local TARGET_DIR=$(mktemp -d)

  requirements_check "jq,wget"

  for PACKAGE in ${@}; do
    # If we install manually using this function, add it to our list for future runs of bootstrap.sh
    if ! grep "${PACKAGE}" "${BREW_CASK_INSTALLS}"; then
      echo "${PACKAGE}" >> "${INSTALL_TRACKER_FILE}"
    fi
    DOWNLOAD_INFO=$(curl -s "https://formulae.brew.sh/api/cask/${PACKAGE}.json" |\
      jq -r '[.url, .sha256, (.artifacts[].app | select(. != null)[])] | @tsv'
    )
    URL=$(echo "${DOWNLOAD_INFO}" | awk -F '\t' '{print $1}')
    SHASUM=$(echo "${DOWNLOAD_INFO}" | awk -F '\t' '{print $2}')
    FILE_NAME=$(echo "${DOWNLOAD_INFO}" | awk -F '\t' '{print $NF}')
    if [ -d "/Applications/${FILE_NAME}" ]; then
      echo "${FILE_NAME} is already installed...skipping"
      continue
    fi
    # Download the package and validate the shasum
    wget "${URL}" -O "${TARGET_DIR}/${PACKAGE}"
    if [ "${SHASUM}" != "no_check" ] && ! shasum -a 256 "${TARGET_DIR}/${PACKAGE}" | grep -q "${SHASUM}"; then
      echo "Shasum for ${TARGET_DIR}/${PACKAGE} could not be validated.  You will have to install it manually."
      return 1
    fi
    install_package "${TARGET_DIR}/${PACKAGE}"
  done
  rm -r "${TARGET_DIR}"
}

install_brew_formulae() {
  if [ -z "${1}" ]; then
    pushd "${BREW_FORMULAE_INSTALLS%/*}"
    cat "${BREW_FORMULAE_INSTALLS##*/}" | xargs -I {} bash -c "brew list {} || brew install {}"
    popd
  else
    for PACKAGE in "${@}"; do
      brew list "${PACKAGE}" || brew install "${PACKAGE}"
        if ! grep "${PACKAGE}" "${BREW_FORMULAE_INSTALLS}"; then
          echo "${PACKAGE}" >> "${INSTALL_TRACKER_FILE}"
        fi
    done
  fi
}
