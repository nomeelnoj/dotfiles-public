----------------------
# github/releases.json
{
  "hcl2json": "tmccombs/hcl2json",
  "hcledit": "minamijoyo/hcledit",
  "json2hcl": "kvz/json2hcl",
  "aws-iam-authenticator": "kubernetes-sigs/aws-iam-authenticator",
  "dyff": "homeport/dyff",
  "iam-policy-json-to-terraform": "flosell/iam-policy-json-to-terraform",
  "jira": "go-jira/jira",
  "jwt": "mike-engel/jwt-cli",
  "watch": "sachaos/viddy"
}
---------------------
# And then the functions that handle it.  Just call `gh_install_releases`
---------------------
# instal..sh
extract_gh_release() {
  local TARGET_DIR="${1}"
  local TOOL="${2}"
  for FILE in $(ls $TARGET_DIR); do
    if [ $(file -bI "${TARGET_DIR}/${FILE}" | cut -d ';' -f1) == "application/x-mach-binary" ]; then
      chmod +x "${TARGET_DIR}/${FILE}"
      mv "${TARGET_DIR}/${FILE}" "/usr/local/bin/${TOOL}"
    fi
  done
}

gh_install_releases() {
  RELEASES_FILE="${DOTFILE_PATH}/github/releases.json"
  for TOOL in $(jq -r '. | keys[]' "${RELEASES_FILE}"); do
    mkdir target
    TARGET_DIR=$(mktemp -d)
    REPO=$(jq -r --arg key "${TOOL}" '.[$key]' "${RELEASES_FILE}")
    gh release download -R "${REPO}" --pattern '*[Dd]arwin*arm*' -D "${TARGET_DIR}"
    if [ "$?" -ne 0 ]; then
      echo "Could not find darwin arm64 version of ${PACKAGE}...downloading amd64"
      gh release download -R "${REPO}" --pattern '*[Dd]arwin*amd64*' -D "${TARGET_DIR}"
      if [ "$?" -ne 0 ]; then
        echo "Could not find darwin amd64 version of ${PACKAGE}...trying mac tar"
        gh release download -R "${REPO}" --pattern '*mac*tar*' -D "${TARGET_DIR}"
        if [ "$?" -ne 0 ]; then
          echo "---------- ERROR: Could not download ${TOOL}!!! ----------"
        fi
      fi
    fi
    # The gh release download filter will usually grab the shasums if they are unique assets,
    # but they are not standard across all repos and some are in a single file.
    # We try to use them, but do not fail if we cannot find them or we do not match
    # due to unpredictability in how shasums are handled for github releases
    gh release download -R "${REPO}" --pattern '*checksum*' -D "${TARGET_DIR}" || true
    CHECKSUMS_FILE=$(ls "${TARGET_DIR}" | grep 'checksum' || true)
    DOWNLOADED_RELEASE=$(ls "${TARGET_DIR}" | grep -vE "sha|sum")
    RELEASE_SHA_FILE=$(ls "${TARGET_DIR}" | grep "sha256" || true) # Sometimes we dont get the download

    pushd "${TARGET_DIR}"
    SHASUM=$(shasum -a 256 "${DOWNLOADED_RELEASE}")
    popd
    if ! grep -q "${SHASUM}" "${TARGET_DIR}/${RELEASE_SHA_FILE}" && ! grep -q "${SHASUM}" "${TARGET_DIR}/${CHECKSUMS_FILE}"; then
      echo "Shasum for ${TOOL} could not be validated.  You might want to check it locally or proceed with caution"
    fi

    # Some releases do not have extensions as they are just binaries, but
    # they have periods in them.
    local RELEASE_TYPE=$(file -bI "${TARGET_DIR}/${DOWNLOADED_RELEASE}" | cut -d ';' -f1)
    case $RELEASE_TYPE in
    application/gzip)
      tar -zxvf "${TARGET_DIR}/${DOWNLOADED_RELEASE}" -C "${TARGET_DIR}"
      # Packages often have LICENSE and README.  This will move only the binary
      extract_gh_release "${TARGET_DIR}" "${TOOL}"
      ;;
    application/zip)
      unzip "${TARGET_DIR}/${DOWNLOADED_RELEASE}" -d "${TARGET_DIR}"
      extract_gh_release "${TARGET_DIR}" "${TOOL}"
      ;;
    application/x-mach-binary) # If there is no extension, we assume it is already a binary
      chmod +x "${TARGET_DIR}/${DOWNLOADED_RELEASE}"
      mv "${TARGET_DIR}/${DOWNLOADED_RELEASE}" "/usr/local/bin/${TOOL}"
      ;;
    *)
      echo "Could not process ${TOOL}".
      echo "Download manually from https://github.com/${REPO}/releases".
      ;;
    esac
    rm -rf "${TARGET_DIR}"
  done
}
