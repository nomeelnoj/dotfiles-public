#!/bin/bash

export DOTFILE_PATH="${HOME}/src/github.com/nomeelnoj/dotfiles"

source "${DOTFILE_PATH}/installers/generic/install_helpers.sh"

INSTALL_TRACKER_FILE="${DOTFILE_PATH}/installers/install_tracker.txt"

extract_tar_binary() {
  local TARGET_DIR="${1}"
  local TOOL="${2}"
  local DOWNLOADED_RELEASE="${3}"
  IFS=$'\n'
  for FILE in $(find $TARGET_DIR -type f | grep -v "${DOWNLOADED_RELEASE}"); do
    if [ $(file -bI "${FILE}" | cut -d ';' -f1) == "application/x-mach-binary" ]; then
      chmod +x "${FILE}"
      mv "${FILE}" "/usr/local/bin/${TOOL}"
    fi
  done
}

# extract_tar_binary() {
#     local TARGET_DIR="${1}"
#     local TOOL="${2}"
#     find $TARGET_DIR -type f -exec bash -c \"
#         for FILE do
#             echo \"FILE IS $FILE\"
#             echo \"TOOL IS $TOOL\"
#             [[ \"$( file -bI $FILE | cut -d \";\" -f1 )\" != \"application/x-mach-binary\" ]] && continue
#             chmod +x \"${FILE}\"
#             mv \"${TARGET_DIR}/${FILE}\" \"/usr/local/bin/${TOOL}\"
#         done\" bash {} +
# }



gh_install_releases() {
  requirements_check "jq,gh,sponge"
  get_input_args "$@"
  process_args
  if [ -f "${1}" ]; then
    RELEASES_FILE_CONTENTS=$(cat "${1}")
  else
    RELEASES_FILE_CONTENTS=$(
      jq --null-input \
      --arg tool $1 \
      --arg repo $2 \
      '{($tool): ($repo)}'
    )
  fi
  for TOOL in $(echo "${RELEASES_FILE_CONTENTS}" | jq -r '. | keys[]'); do
    if ! jq -r '. | keys[]' "${DOTFILE_PATH}/installers/github/releases.json" | grep -v "${TOOL}"; then
      echo "Adding tool to releases.json"
      jq --arg tool $1 --arg repo $2 '.[] += {($tool): ($repo)}' "${DOTFILE_PATH}/installers/github/releases.json" |\
         sponge "${DOTFILE_PATH}/installers/github/releases.json"
    fi
    if [ "${FORCE}" == "true" ]; then
      echo "Overriding check for existing installation"
    elif command -v "${TOOL}" &> /dev/null; then
      echo "Tool ${TOOL} is already installed.  Skipping"
      continue
    fi
    TARGET_DIR=$(mktemp -d)
    REPO=$(echo "${RELEASES_FILE_CONTENTS}" | jq -r --arg key "${TOOL}" '.[$key]')
    gh release download -R "${REPO}" --pattern '*[Dd]arwin*arm*' -D "${TARGET_DIR}"
    if [ "$?" -ne 0 ]; then
      echo "Could not find darwin arm64 version of ${PACKAGE}...downloading amd64"
      gh release download -R "${REPO}" --pattern '*[Dd]arwin*amd64*' -D "${TARGET_DIR}"
      if [ "$?" -ne 0 ]; then
        echo "Could not find darwin amd64 version of ${PACKAGE}...trying mac arm tar"
        gh release download -R "${REPO}" --pattern '*mac*arm*tar*' -D "${TARGET_DIR}"
        if [ "$?" -ne 0 ]; then
          echo "Could not find mac arm tar version of ${PACKAGE}...trying generic mac tar"
          gh release download -R "${REPO}" --pattern '*mac*tar*' -D "${TARGET_DIR}"
          if [ "$?" -ne 0 ]; then
            echo "---------- ERROR: Could not download ${TOOL}!!! ----------"
            continue
          fi
        fi
      fi
    fi
    # The gh release download filter will usually grab the shasums if they are unique assets,
    # but they are not standard across all repos and some are in a single file.
    # We try to use them, but do not fail if we cannot find them or we do not match
    # due to unpredictability in how shasums are handled for github releases
    gh release download -R "${REPO}" --pattern '*checksum*' -D "${TARGET_DIR}" || true
    CHECKSUMS_FILES=$(ls "${TARGET_DIR}" | grep 'checksum' || true)
    # Have to sort and grab the first one because some repos provide both a binary and a zip
    DOWNLOADED_RELEASE=$(ls "${TARGET_DIR}" | grep -vE "sha|sum" | sort | head -n 1)
    RELEASE_SHA_FILE=$(ls "${TARGET_DIR}" | grep "sha256" || true) # Sometimes we dont get the download

    pushd "${TARGET_DIR}"
    SHASUM=$(shasum -a 256 "${DOWNLOADED_RELEASE}")
    popd
    for CHECKSUMS_FILE in ${CHECKSUMS_FILES[@]}; do
      if ( ! grep -q "${SHASUM}" "${TARGET_DIR}/${RELEASE_SHA_FILE}" || true ) && ( ! grep -q "${SHASUM}" "${TARGET_DIR}/${CHECKSUMS_FILE}" ); then
        echo "Shasum for ${TOOL} could not be validated.  You might want to check it locally or proceed with caution"
      fi
    done

    # Some releases do not have extensions as they are just binaries, but
    # they have periods in them.
    local RELEASE_TYPE=$(file -bI "${TARGET_DIR}/${DOWNLOADED_RELEASE}" | cut -d ';' -f1)
    case $RELEASE_TYPE in
      application/gzip )
        tar -zxvf "${TARGET_DIR}/${DOWNLOADED_RELEASE}" -C "${TARGET_DIR}"
        # Packages often have LICENSE and README.  This will move only the binary
        extract_tar_binary "${TARGET_DIR}" "${TOOL}" "${DOWNLOADED_RELEASE}"
      ;;
      application/zip )
        unzip "${TARGET_DIR}/${DOWNLOADED_RELEASE}" -d "${TARGET_DIR}"
        extract_tar_binary "${TARGET_DIR}" "${TOOL}"
      ;;
      application/x-mach-binary ) # If there is no extension, we assume it is already a binary
        chmod +x "${TARGET_DIR}/${DOWNLOADED_RELEASE}"
        mv "${TARGET_DIR}/${DOWNLOADED_RELEASE}" "/usr/local/bin/${TOOL}"
        if ! grep "${TOOL}" "${INSTALL_TRACKER_FILE}"; then
          echo "${TOOL}" >> "${INSTALL_TRACKER_FILE}"
        fi
      ;;
      *)
        echo "Could not process ${TOOL}".
        echo "Download manually from https://github.com/${REPO}/releases".
      ;;
    esac
    echo "${TOOL} installed successfully"
    rm -rf "${TARGET_DIR}"
  done
}
