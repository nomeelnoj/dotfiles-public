#!/bin/bash

export DOTFILE_PATH="${HOME}/src/github.com/nomeelnoj/dotfiles"

usage() {
  echo "Usage: bootstrap.sh [[-g COMPANY_GIT_ORG] [-e EMAIL] | [-h]]"
  echo ""
  echo "Options:"
  echo "-g / --company-git-org [COMPANY_GIT_ORG]: The git org of the company, e.g. github.com/mycompany"
  echo "-e / --email [EMAIL]: Your company email address"
  echo "-d / --debug: Enable debug output"
  echo "-h / --help: Print this usage statement"
  echo ""
  exit 0
}

get_input_args() {

  POSITIONAL=()

  while [ $# -gt 0 ]; do
    key="$1"
    case $key in
    -g | --company-git-org)
      COMPANY_GIT_ORG="$2"
      shift # past argument
      shift # past value
      ;;
    -e | --email)
      COMPANY_EMAIL="$2"
      shift # past argument
      shift # past value
      ;;
    -d | --debug)
      # debug everything
      set -x
      shift # past argument
      ;;
    -h | --help)
      usage
      shift # past argument
      ;;
    *) # unknown option
      usage
      POSITIONAL+=("$1") # save it in an array for later
      shift              # past argument
      ;;
    esac
  done
}

verify_input_args() {
  : "${COMPANY_GIT_ORG:?COMPANY_GIT_ORG must be set as an env var or with -g when running to ensure proper git config}"
  : "${COMPANY_EMAIL:?COMPANY_EMAIL must be set as an env var or with -g when running to ensure proper git config}"
}

confirm() {
  # Confirmation command to verify with user that action is correct
  MSG=${1:-Are you sure you want to continue?}
  RED='\033[0;31m'
  NC='\033[0m' # no color
  PROMPT="${RED}${MSG} (y/n) ${NC}"
  read -p "$(echo -e $PROMPT)" choice
  case "$choice" in
  y | Y)
    echo "Confirmed.  Proceeding..."
    ;;
  n | N)
    echo "Confirmation not received.  Exiting..."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
    ;;
  *)
    echo "Invalid choice.  Please enter 'y' or 'n'"
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
  elif [ -d "${TO}" ] || [ -f "${TO}" ]; then
    echo "File: ${TO} is not a symbolic link"
    confirm "Are you sure you want to overwrite it? It will be backed up to ${TO}.bak"
    if [ "$?" -ne 0 ]; then
      exit 1
    else
      mv "${TO}" "${TO}.bak"
    fi
  fi
  ln -s "${FROM}" "${TO}"
}

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

install_brew_cask() {
  # I hate homebrew, so we use it as little as possible
  local TARGET_DIR=$(mktemp -d)

  requirements_check "jq,wget"

  for PACKAGE in $(cat "${DOTFILE_PATH}/installers/brew/casks.txt"); do
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

install_awscli() {
  if command -v aws &> /dev/null; then
    echo "You already have this tool installed.  Skipping"
  else
    local TARGET_DIR=$(mktemp -d)
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "${TARGET_DIR}/AWSCLIV2.pkg"
    install_pkg "${TARGET_DIR}/AWSCLIV2.pkg"
  fi
}

install_brave() {
  if ls "/Applications/Brave Browser.app"; then
    echo "Brave is already installed.  Skipping"
  else
    local TEMP_DIR=$(mktemp -d)
    requirements_check "wget"
    wget https://laptop-updates.brave.com/latest/osx -O "${TEMP_DIR}/brave.dmg"
    install_dmg "${TEMP_DIR}/brave.dmg"
    rm -r "${TEMP_DIR}"
  fi
}

install_go() {
  if command -v go &>/dev/null; then
    echo "Golang already installed.  Skipping"
  else
    local TARGET_DIR=$(mktemp -d)
    wget https://go.dev/dl/go1.20.darwin-arm64.pkg -O "${TARGET_DIR}/go.pkg"
    install_package "${TARGET_DIR}/go.pkg"
    rm -r "${TARGET_DIR}"
  fi
}

install_text_expander() {
  # I use an older version of textexpander, so a brew cask hack wont work
  requirements_check "wget"
  local TARGET_DIR=$(mktemp -d)
  wget https://cdn.textexpander.com/mac/TextExpander_5.1.7.zip -O "${TARGET_DIR}/textexpander.zip"
  install_package "${TARGET_DIR}/textexpander.zip"
  rm -r "${TARGET_DIR}"
  open -a "TextExpander"
  killall TextExpander
  defaults write "com.smileonmymac.textexpander" "Hide Dock Icon" -bool true
  defaults write "com.smileonmymac.textexpander" "Hide Main Window" -bool true
}

install_shell_environment() {
  # Install oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  # Install powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  # Install Fonts
  /opt/homebrew/bin/brew tap homebrew/cask-fonts
  /opt/homebrew/bin/brew install --cask font-hack-nerd-font
  /opt/homebrew/bin/brew install --cask font-fira-mono-nerd-font
  # Link .zshrc
  link "${DOTFILE_PATH}/zsh/.zshrc" "${HOME}/.zshrc"
  # Set iTerm to store/load settings from custom config path
  defaults write "com.googlecode.iterm2" "NoSyncNeverRemindPrefsChangesLostForFile" '1'
  # Load from file
  defaults write "com.googlecode.iterm2" "LoadPrefsFromCustomFolder" '1'
  # Set to file path
  defaults write "com.googlecode.iterm2" "PrefsCustomFolder" "${HOME}/src/github.com/nomeelnoj/dotfiles/iterm2_profile"
}

configure_system() {
  #####################
  ## SYSTEM SETTINGS ##
  #####################
  # Change permissions of local user
  # this was required a few OSes ago, leaving it here just in case, but commented out
  # sudo dseditgroup -o edit -a $USER -t user admin
  # sudo dseditgroup -o edit -a $USER -t user wheel

  # Save screenshots to Dropbox
  defaults write com.apple.screencapture location ~/Dropbox/Screenshots

  # Set system to keep windows when re-opening apps
  defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true
  # Dark mode ( requires logout )
  defaults write NSGlobalDomain AppleInterfaceStyle 'Dark'
  # Show scrollbars when scrolling
  defaults write NSGlobalDomain AppleShowScrollBars 'WhenScrolling'
  # Click scrollbar to jump to next page (not where the scrollbar was clicked)
  defaults write NSGlobalDomain AppleScrollerPagingBehavior -bool false

  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  # Disable iCloud as default save location
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  # Prevent Photos from opening automatically when a device is plugged in
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
  # Don't automatically sync connected devices
  defaults write com.apple.itunes dontAutomaticallySyncIPods -bool true
  # Don't prompt to start time machine on connection to new Hard Drives
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
  # Bluetooth
  # increase audio bitrate (better sound quality)
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
  # zoom.us
  # Disable Dual Screen
  defaults write /Library/Preferences/us.zoom.config.plist ZDualMonitorOn -bool false

  ##############
  ## KEYBOARD ##
  ##############
  # Set Key Repeat rate
  defaults write NSGlobalDomain "InitialKeyRepeat" -float '25'
  # Default is 2 (30ms), 1 is even faster!
  defaults write NSGlobalDomain "KeyRepeat" -float '1.5'
  # Disable globe key
  defaults delete com.apple.HIToolbox AppleFnUsageType
  defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0
  # Set globe key to control key
  # This works based on the make/model of the keyboard, so this is only for an M1 Max macbook pro builtin
  defaults -currentHost write -g "com.apple.keyboard.modifiermapping.1452-835-0" -array '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771300</integer><key>HIDKeyboardModifierMappingSrc</key><integer>1095216660483</integer></dict>' '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771296</integer><key>HIDKeyboardModifierMappingSrc</key><integer>280379760050179</integer></dict>'

  ############
  ## FINDER ##
  ############

  # Show hard drives on desktop
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  # Show network drives on desktop
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  # Show hidden files
  defaults write com.apple.finder AppleShowAllFiles -bool true
  # Show all file extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # Desktop view settings: info at right, show details, stack by kind by date added
  defaults write com.apple.finder DesktopViewSettings '{GroupBy=Kind;IconViewSettings={arrangeBy=dateAdded;backgroundColorBlue=1;backgroundColorGreen=1;backgroundColorRed=1;backgroundType=0;gridOffsetX=0;gridOffsetY=0;gridSpacing=82;iconSize=48;labelOnBottom=0;showIconPreview=1;showItemInfo=1;textSize=12;viewOptionsVersion=1;};}'
  # new window - use src
  defaults write com.apple.finder NewWindowTarget -string "PfLo"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/src"
  # full path in banner
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
  # Play feedback when changing volume
  defaults write NSGlobalDomain com.apple.sound.beep.feedback -int 1
  # Never open new windows in tabs
  defaults write NSGlobalDomain AppleWindowTabbingMode manual
  # Confirm changes when closing
  defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -bool true
  # Use column view in all Finder windows by default
  # Four-letter codes for the other view modes: `icnv`, `Nlsv`, `Flwv`
  defaults write com.apple.finder FXPreferredSearchViewStyle -string "clmv"
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true
  # Change spotlight shortcut to option+space, we use command+space in Alfred
  # For some reason, to get it to reload, we need to read back in the config and then activate the settings
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>524288</integer></array><key>type</key><string>standard</string></dict></dict>"
  defaults read com.apple.symbolichotkeys >/dev/null

  # Disable smart quotes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  # Disable smart dashes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  # Disable Dictation with fn key pressed twice
  defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0
  ### ALFRED ##
  defaults write "com.runningwithcrayons.Alfred-Preferences" "syncfolder" '"~/Dropbox/Alfred"'

  ##################
  ## VIEW OPTIONS ##
  ##################
  # Set screensaver hot corner
  defaults write com.apple.dock wvous-bl-corner -int 5
  defaults write com.apple.dock wvous-bl-modifier -int 0

  # Download mac app store updates in background
  # Download newly available App Store updates in the background
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true

  # Expand Save/Print Dialog Boxes by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Allow Handoff between this Mac and your iCloud devices
  defaults write ~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool true
  defaults write ~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool true

  #####################
  ## DOCK AND SPACES ##
  #####################
  # Don’t automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false
  # Group windows by application
  defaults write com.apple.dock "expose-group-apps" -bool true
  # Dock
  # Don’t show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false
  defaults write com.apple.dock "recent-apps" '()'
  # Autohide the dock
  defaults write com.apple.dock autohide -int 1
  # Set dock size
  defaults write com.apple.dock "tilesize" '45'
  # Set dock magnification
  defaults write com.apple.dock "magnification" -bool true
  defaults write com.apple.dock "largesize" '80'

  ###############
  ## TRACKPAD ##
  ###############
  # Speed up trackpad tracking (1 is the speed, not a boolean)
  defaults write NSGlobalDomain com.apple.trackpad.scaling '1'
  # Enable force touch
  defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool true
  # Enable natural scrolling
  defaults write NSGlobalDomain com.apple.swipescrolldirection '1'
  # Swipe between pages
  defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
  # Mission controll swipe up with 3 fingers
  defaults write com.apple.dock showMissionControlGestureEnabled -bool true
  # Enable expose down with 3 fingers
  defaults write com.apple.dock showAppExposeGestureEnabled -bool true
  # Show desktop with 4 finger spread
  defaults write com.apple.dock showDesktopGestureEnabled -bool true

  #############
  ## TASKBAR ##
  #############
  # Always show the date
  defaults write com.apple.menuextra.clock ShowDate -bool true
  # Don't flash date and time separators
  defaults write com.apple.menuextra.clock FlashDateSeparators -bool false
  # Show seconds on clock
  defaults write com.apple.menuextra.clock ShowSeconds -bool true
  # Never hide the menu bar
  defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool true
  # Show wifi in menu bar
  defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true
  # Show bluetooth in taskbar
  defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
  # Show sound in menu bar
  defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true
  # Dont show spotlight, we use alfred
  defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1
  # Enable battery Percent
  defaults write ${HOME}/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true
  # Time Machine
  defaults write "com.apple.systemuiserver" "NSStatusItem Visible com.apple.menuextra.TimeMachine" '1'
  defaults write "com.apple.systemuiserver" "NSStatusItem Preferred Position com.apple.menuextra.TimeMachine" '389'
  defaults write "com.apple.systemuiserver" "menuExtras" '("/System/Library/CoreServices/Menu Extras/TimeMachine.menu",)'

  # Disable Siri
  defaults write "com.apple.assistant.support" "Assistant Enabled" '0'
  defaults write "com.apple.Siri" "SiriPrefStashedStatusMenuVisible" '0'
  defaults write "com.apple.Siri" "VoiceTriggerUserEnabled" '0'

  # Many of the above settings wont actually take place ( like keyboard shortcut mapping and key speed ) until we
  # activate the settings:
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

  # Restart UI Elements after Changes
  for APP in \
    "Activity Monitor" \
    "SystemUIServer" \
    "Dock" \
    "Finder"; do
    killall "${APP}" &>/dev/null
  done
}

configure_sublime() {
  link '/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl' /usr/local/bin/sublime
  # To create the Application Support directory we need to launch the app
  open -a "Sublime Text"
  killall sublime_text
  link "${DOTFILE_PATH}/sublime_text/Installed Packages" "${HOME}/Library/Application Support/Sublime Text/Installed Packages"
  link "${DOTFILE_PATH}/sublime_text/Packages" "${HOME}/Library/Application Support/Sublime Text/Packages"
}

configure_brave() {
  requirements_check "jq,sponge"
  BRAVE_PATH="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"
  PREFERENCE_FILE="${BRAVE_PATH}/Default/Preferences"
  LOCAL_STATE_FILE="${BRAVE_PATH}/Local State"
  cat "${PREFERENCE_FILE}" | jq '.brave.location_bar_is_wide = true' | sponge "${PREFERENCE_FILE}"
  cat "${PREFERENCE_FILE}" | jq '.bookmark_bar.show_on_all_tabs = true' | sponge "${PREFERENCE_FILE}"
  cat "${LOCAL_STATE_FILE}" | jq '.browser.enabled_labs_experiments = ["password-import@1"]' | sponge "${LOCAL_STATE_FILE}"
  open -a "Brave Browser" --args --make-default-browser
  echo "There are some settings that cannot be easily set from the CLI"
  echo "Do not forget to import your bookmarks, passwords, and set the default search engine"
}

configure_better_snap_tool() {
  # echo "BetterSnapTool can only be downloaded from the MacAppStore"
  # read -p "Download BetterSnapTool, then press enter when ready"
  # defaults write "com.hegenberg.BetterSnapTool" "registeredHotkeys" '{0={keyCode=46;modifiers=6400;};1={keyCode="-1";modifiers=0;};10={keyCode="-1";modifiers=0;};100={keyCode="-1";modifiers=0;};102={keyCode="-1";modifiers=0;};104={keyCode="-1";modifiers=0;};105={keyCode="-1";modifiers=0;};106={keyCode="-1";modifiers=0;};11={keyCode="-1";modifiers=0;};12={keyCode="-1";modifiers=0;};13={keyCode="-1";modifiers=0;};14={keyCode="-1";modifiers=0;};15={keyCode=126;modifiers=8395008;};16={keyCode=125;modifiers=8395008;};17={keyCode="-1";modifiers=0;};18={keyCode="-1";modifiers=0;};19={keyCode="-1";modifiers=0;};2={keyCode=123;modifiers=8395008;};20={keyCode="-1";modifiers=0;};2001={keyCode="-1";modifiers=0;};2002={keyCode="-1";modifiers=0;};2003={keyCode="-1";modifiers=0;};2004={keyCode="-1";modifiers=0;};2005={keyCode="-1";modifiers=0;};2006={keyCode="-1";modifiers=0;};2007={keyCode="-1";modifiers=0;};2008={keyCode="-1";modifiers=0;};21={keyCode="-1";modifiers=0;};4={keyCode=124;modifiers=8395008;};5461={keyCode="-1";modifiers=0;};8={keyCode="-1";modifiers=0;};999={keyCode="-1";modifiers=0;};}'
  osascript -e 'tell application "System Events" to make login item at end with properties {name: "BetterSnapTool",path:"/Applications/BetterSnapTool.app", hidden:false}'
}

configure_copyq() {
  defaults write "com.copyq.copyq" "Theme.alt_bg" '"#073642"'
  defaults write "com.copyq.copyq" "Theme.bg" '"#002b36"'
  defaults write "com.copyq.copyq" "Theme.edit_bg" '"alt_bg"'
  defaults write "com.copyq.copyq" "Theme.edit_fg" '"#2aa198"'
  defaults write "com.copyq.copyq" "Theme.edit_font" '"Monospace,9,-1,5,50,0,0,0,0,0"'
  defaults write "com.copyq.copyq" "Theme.fg" '"#93a1a1"'
  defaults write "com.copyq.copyq" "Theme.find_bg" '"rgba(0,0,0,0)"'
  defaults write "com.copyq.copyq" "Theme.find_fg" '"#b58900"'
  defaults write "com.copyq.copyq" "Theme.find_font" '"Monospace,9,-1,5,50,0,0,0,0,0"'
  defaults write "com.copyq.copyq" "Theme.font" '"Monospace,9,-1,5,50,0,0,0,0,0"'
  defaults write "com.copyq.copyq" "Theme.notes_bg" 'bg'
  defaults write "com.copyq.copyq" "Theme.notes_fg" '"#ce4d17"'
  defaults write "com.copyq.copyq" "Theme.notes_font" '"Serif,10,-1,5,50,0,0,0,0,0"'
  defaults write "com.copyq.copyq" "Theme.num_fg" '"#586e75"'
  defaults write "com.copyq.copyq" "Theme.num_font" '"Monospace,7,-1,5,25,0,0,0,0,0"'
  defaults write "com.copyq.copyq" "Theme.sel_bg" 'fg'
  defaults write "com.copyq.copyq" "Theme.sel_fg" 'bg'
  defaults write "com.copyq.copyq" "Theme.show_scrollbars" '0'
  defaults write "com.copyq.copyq" "Options.tray_items" -int 20

  osascript -e 'tell application "System Events" to make login item at end with properties {name: "CopyQ",path:"/Applications/CopyQ.app", hidden:false}'
  open -a "CopyQ"
  killall CopyQ
  link "${DOTFILE_PATH}/copyq/copyq-commands.ini" "${HOME}/.config/copyq/copyq-commands.ini"
  open -a "CopyQ"
}

configure_istat_menus() {
  # UNTESTED
  open -a "iStat Menus"
  defaults write "com.bjango.istatmenus6.extras" "CPU_MenubarMode" '({key=100;uuid="5E5313E9-B7EE-42EE-A1CB-0A9571D2F1AF";},{key=2;uuid="B8CD3138-9084-441F-A556-D83CF89E613E";},)'
  defaults write "com.bjango.istatmenus6.extras" "CPU_CombineLogicalCores" '0'
  defaults write "com.bjango.istatmenus6.extras" "CPU_ProcessCount" '10'
  defaults write "com.bjango.istatmenus6.extras" "Memory_MenubarMode" '({key=3;uuid="4718330A-85EA-429F-B6FD-DA0907EA0AB8";},)'
  defaults write "com.bjango.istatmenus6.extras" "StatusItems-Order" '(1,2,)'
  defaults write "com.bjango.istatmenus6.extras" "CPU_MenubarMode" '({key=100;uuid="F7272301-4A87-4DD8-A16C-4BFEA34172BF";},{key=0;uuid="731B78D3-BF85-4810-BD10-ADD6C529C920";},{key=2;uuid="09AB52E6-9044-4660-985E-34564DCD695F";},)'
}

link_files() {
  link "${DOTFILE_PATH}/.ssh/config" "${HOME}/.ssh/config"

  link "${DOTFILE_PATH}/vim/.vim" "${HOME}/.vim"
  link "${DOTFILE_PATH}/vim/.vimrc" "${HOME}/.vimrc"

  link "${DOTFILE_PATH}/git/git-dyff" '/usr/local/bin/git-dyff'
  link "${DOTFILE_PATH}/git/.gitattributes" "${HOME}/.gitattributes"
  link "${DOTFILE_PATH}/git/.gitignore_global" "${HOME}/.gitignore_global"
  link "${DOTFILE_PATH}/git/.gitconfig" "${HOME}/.gitconfig"
  cp -n "${DOTFILE_PATH}/git/.gitcompany.tpl" "${HOME}/.gitcompany"
  link "${DOTFILE_PATH}/git/gh_install_release" '/usr/local/bin/gh_install_release'
  /opt/homebrew/opt/gnu-sed/libexec/gnubin/sed -i "s|COMPANY_EMAIL|${COMPANY_EMAIL}|g" "${HOME}/.gitcompany"
  /opt/homebrew/opt/gnu-sed/libexec/gnubin/sed -i "s|COMPANY_GIT_ORG|${COMPANY_GIT_ORG}|g" "${HOME}/.gitconfig"
}

install_all() {
  # In case the company sets the sudo timeout to 0, set it to 5 so we can install homebrew without needing to enter
  # our password like 500 times
  # Set sudo timeout to 5 min
  # echo "Defaults timestamp_timeout=5" > /private/etc/sudoers.d/$USER
  # # Set file permissions on /usr/local/bin
  # sudo chown -R $USER:staff /usr/local/bin/

  # # Install homebrew, then install the homebrew required packages.  I hate homebrew, so I avoid this at all costs
  # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # # Install wget, a prereq for everything else
  # /opt/homebrew/bin/brew install wget

  # # Install JQ, its a prereq for the rest
  # /opt/homebrew/bin/wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64 -O /usr/local/bin/jq
  # chmod +x /usr/local/bin/jq

  # # Install kubectl
  # curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
  # curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl.sha256"
  # if ! echo $(shasum -a 256 kubectl) | grep $(cat kubectl.sha256); then
  #     echo "Could not validate shasum for kubectl...not installing"
  # else
  #     chmod +x kubectl
  #     mv kubectl /usr/local/bin
  # fi
  # rm kubectl*

  # install_brave
  # install_brew_cask
  # install_brew_formulae
  # configure_sublime
  # install_shell_environment
  # gh_install_releases "${DOTFILE_PATH}/installers/github/releases.json"
  # install_go
  # install_awscli
  install_text_expander
  # configure_brave
  # configure_better_snap_tool
  # configure_sublime
  # configure_copyq
  # configure_system

  # # Install plistwatch to help with creating these scripts
  # /usr/local/go/bin/go install github.com/catilac/plistwatch@latest

  # # Install go-jira
  # /usr/local/go/bin/go install github.com/go-jira/jira/cmd/jira@latest

  # # Install hashicorp tools
  # ${DOTFILE_PATH}/installers/hashicorp/hashicorp.sh

  # Set up our symlinks
  # link_files
}

get_input_args $@
verify_input_args
# Ask for the administrator password upfront
# sudo -vB
source "${DOTFILE_PATH}/installers/github/gh_install_releases.sh"

install_all

echo "###########################################################"
echo "#####         AUTOMATED INSTALLATION COMPLETE         #####"
echo "###########################################################"
echo "There are still a few things to do to get your environment "
echo "setup properly:"
echo ""
echo "- Set slack sidebar theme:"
echo "#303E4D,#152A2D,#61AA9F,#FFFFFF,#4A5664,#FFFFFF,#AFCE76,#78AF8F,#31556E,#FFFFFF"
echo ""
echo "- Set brave search engine default to Google"
echo ""
echo "- Configure licenses for:"
echo "   - Alfred"
echo "   - Sublime Text"
echo "   - iStat Menus"
echo "   - TextExpander"
echo ""
read -p "Press enter when you are done"

# Logout to apply changes
launchctl bootout user/$(id -u $USER)
