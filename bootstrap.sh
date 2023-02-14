#!/bin/bash

export DOTFILE_PATH="${HOME}/src/github.com/nomeelnoj/dotfiles"

get_input_args() {
    if [ -z "$1" ]; then
        echo "no args"
        usage
    fi

    POSITIONAL=()

    while [ $# -gt 0 ];
    do
    key="$1"
    case $key in
        -n|--company-name)
        COMPANY_NAME="$2"
        shift # past argument
        shift # past value
        ;;
        -d|--debug)
        # debug everything
        set -x
        shift # past argument
        ;;
        -h|--help)
        usage
        shift # past argument
        ;;
        *)    # unknown option
        usage
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
  done
}

verify_input_args() {
    : "${COMPANY_NAME:?COMPANY_NAME must be set as an env var or with -n when running to ensure proper git config}"
}

confirm() {
    # Confirmation command to verify with user that action is correct
    RED='\033[0;31m'
    NC='\033[0m' # no color
    PROMPT="${RED}Are you sure you want to continue (y/n)? ${NC}"
    read -p "$(echo -e $PROMPT)" choice
    case "$choice" in
      y|Y )
        echo "Confirmed.  Proceeding..."
        ;;
      n|N )
        echo "Confirmation not received.  Exiting..."
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
        ;;
      * ) echo "Invalid choice.  Please enter 'y' or 'n'"
        confirm
        ;;
    esac
}

link() {
  FROM="$1"
  TO="$2"
  echo "Linking '${FROM}' to '${TO}'"
  if [ -L "${TO}" ]; then
    rm -f "${TO}"
  else
    echo "File: ${TO} is not a symbolic link"
    exit
  fi
  ln -s "${FROM}" "${TO}"
}

requirements_check() {
    INPUT_ARGS="${1}"
    OLDIFS="${IFS}"
    IFS=","
    for ARG in ${INPUT_ARGS}; do
        if ! command -v $ARG &> /dev/null; then
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
        application/zip )
            unzip -q "${PACKAGE}" -d "${TARGET_DIR}"
            APP=$(ls "${TARGET_DIR}" | grep '.app')
            if [ ! -z "${APP+x}" ]; then
                install_package "${TARGET_DIR}/${APP}"
            fi
        ;;
        inode/directory )
            if ls /Applications | grep $(echo "${PACKAGE}" | awk -F '/' '{print $NF}'); then
                echo "Package ${PACKAGE} is already installed in /Applications"
                return 1
            elif echo "${PACKAGE}" | grep -q '.app'; then
                mv "${PACKAGE}" /Applications
            fi
        ;;
        application/x-mach-binary ) # If there is no extension, we assume it is already a binary
            chmod +x "${TARGET_DIR}/${DOWNLOADED_RELEASE}"
            mv "${TARGET_DIR}/${DOWNLOADED_RELEASE}" "/usr/local/bin/${TOOL}"
        ;;
        application/x-bzip2 )
            install_dmg "${PACKAGE}"
        ;;
        application/x-xar )
            install_pkg "${PACKAGE}"
        ;;
        *)
            echo "Could not process ${TOOL}".
            echo "Download manually from https://github.com/${REPO}/releases".
    esac
    rm -r "${TARGET_DIR}"
}

brew_cask_install() {
    # I hate homebrew, so we use it as little as possible
    local TARGET_DIR=$(mktemp -d)

    requirements_check "jq,wget"

    for PACKAGE in $(cat "${DOTFILE_PATH}/installers/brew/casks.txt"); do
        DOWNLOAD_INFO=$(curl "https://formulae.brew.sh/api/cask/${PACKAGE}.json" | jq -r '[.url, .sha256] | @tsv')
        URL=$(echo "${DOWNLOAD_INFO}" | awk '{print $1}')
        SHASUM=$(echo "${DOWNLOAD_INFO}" | awk '{print $2}')
        # Download the package and validate the shasum
        wget "${URL}" -O "${TARGET_DIR}/${PACKAGE}"
        if ! shasum -a 256 "${TARGET_DIR}/${PACKAGE}" | grep -q "${SHASUM}"; then
            echo "Shasum for ${TARGET_DIR}/${PACKAGE} could not be validated.  You will have to install it manually."
            return 1
        fi
        install_package "${TARGET_DIR}/${PACKAGE}"
    done
    rm -r "${TARGET_DIR}"
}

install_brave() {
    local TEMP_DIR=$(mktemp -d)
    requirements_check "wget"
    wget https://laptop-updates.brave.com/latest/osx -O "${TEMP_DIR}/brave.dmg"
    install_dmg "${TEMP_DIR}/brave.dmg"
}

install_go() {
    local TARGET_DIR=$(mktemp -d)
    wget https://go.dev/dl/go1.20.darwin-arm64.pkg -O "${TARGET_DIR}/go.pkg"
    install_package "${TARGET_DIR}/go.pkg"
    rm -r "${TARGET_DIR}"
}

install_shell_environment() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    brew tap homebrew/cask-fonts
    brew install --cask font-hack-nerd-font
    brew install --cask font-firamono-nerd-font
}

configure_iterm() {
    defaults write "Apple Global Domain" "NSQuitAlwaysKeepsWindows" '1'
}

# https://formulae.brew.sh/api/cask/iterm2.json

# echo "Set slack sidebar theme:"
# echo "{\"column_bg\":\"#303E4D\",\"menu_bg\":\"#31556E\",\"active_item\":\"#61aa9f\",\"active_item_text\":\"#FFFFFF\",\"hover_item\":\"#4A5664\",\"text_color\":\"#FFFFFF\",\"active_presence\":\"#afce76\",\"badge\":\"#78AF8F\"}"

# link "${DOTFILE_PATH}/git/git-dyff" '/usr/local/bin/git-dyff'
# link "${DOTFILE_PATH}/git/.gitattributes" "${HOME}/.gitattributes"
# link "${DOTFILE_PATH}/git/.gitignore" "${HOME}/.gitignore"
# link "${DOTFILE_PATH}/git/.gitconfig" "${HOME}/.gitconfig"
# cp -n "${DOTFILE_PATH}/git/.gitcompany.tmpl" "${HOME}/.gitcompany"

install_all() {

    # Install homebrew, then install the homebrew required packages.  I hate homebrew, so I avoid this at all costs
    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Install JQ, its a prereq for the rest
    # wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64 -O /usr/local/bin/jq

    # brew_cask_install
    # install_brave
    install_go
}

get_input_args $@
install_all
