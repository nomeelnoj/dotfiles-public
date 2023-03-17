#!/bin/bash

export DOTFILE_PATH="${HOME}/src/github.com/nomeelnoj/dotfiles"

source "${DOTFILE_PATH}/installers/generic/install_helpers.sh"

install_brew_cask() {
  # I hate homebrew, so we use it as little as possible
  local TARGET_DIR=$(mktemp -d)

  requirements_check "jq,wget"

  for PACKAGE in ${@}; do
    DOWNLOAD_INFO=$(
      curl -s "https://formulae.brew.sh/api/cask/${PACKAGE}.json" |
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
  pushd "${DOTFILE_PATH}/installers/brew"
  cat formulas.txt | xargs -I {} bash -c "brew list {} || brew install {}"
  popd
}
