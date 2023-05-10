#!/bin/bash

export DOTFILE_PATH="${HOME}/src/github.com/nomeelnoj/dotfiles"

usage() {
  echo "Usage: bootstrap.sh [[-g COMPANY_GIT_DOMAIN] [-e EMAIL] | [-h]]"
  echo ""
  echo "Options:"
  echo "-g / --company-git-domain [COMPANY_GIT_DOMAIN]: The git domain of the company, e.g. github.com"
  echo "-o / --company-git-org [GIT_ORG]: The company git org (after the github.com), e.g. company-internal"
  echo "-e / --email [EMAIL]: Your company email address"
  echo "-d / --debug: Enable debug output"
  echo "-h / --help: Print this usage statement"
  echo ""
  exit 0
}

get_input_args() {

  POSITIONAL=()

  while [ $# -gt 0 ]; do
  case $key in
    -g|--company-git-domain)
    COMPANY_GIT_DOMAIN="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--company-git-org)
    GIT_ORG="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--email)
    COMPANY_EMAIL="$2"
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
  : "${COMPANY_GIT_DOMAIN:?COMPANY_GIT_DOMAIN (e.g. github.com) must be set as an env var or with -g when running to ensure proper git config}"
  : "${GIT_ORG:?GIT_ORG (e.g. company-internal) must be set as an env var or with -o when running to ensure proper git config}"
  : "${COMPANY_EMAIL:?COMPANY_EMAIL must be set as an env var or with -e when running to ensure proper git config}"
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
  ln -s "${FROM}" "${TO}"
}

find_replace() {
  perl -p -i -e "s|$1|$2|g" $3
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
  if command -v go &> /dev/null; then
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
}

configure_shell_environment() {
  # Link .zshrc
  # TODO: Convert to .zshrc.d
  for ZSH_FILE in $(ls -a ${DOTFILE_PATH}/zsh/.*); do
    RAW_FILE="${ZSH_FILE##*/}"
    link "${ZSH_FILE}" "${HOME}/${RAW_FILE}"
  done
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
  # https://support.zoom.us/hc/en-us/articles/115001799006-Mass-deploying-with-preconfigured-settings-for-macOS
  # Disable Dual Screen
  defaults write /Library/Preferences/us.zoom.config.plist zDualMonitorOn -int 0
  # Set Global Mute Key Command + Shift + A
  defaults write "us.zoom.xos.Hotkey" "[gHK@state]-HotkeyOnOffAudio" -bool true
  # Set Global Video on/off key Command + Shift + X
  defaults write "us.zoom.xos.Hotkey" "[gHK@state]-HotkeyOnOffVideo" -bool true
  defaults write "us.zoom.xos.HotKey" "[HK@combo]-HotkeyOnOffVideo" -array '<dict><key>hot key code</key><integer>7</integer><key>hot key modifier</key><integer>1179648</integer></dict>'
  # These are actually strings, not bools
  defaults write "ZoomChat" "ZoomShowIconInMenuBar" 'false'
  defaults write "ZoomChat" "ZoomEnterMaxWndWhenViewShare" 'false'
  defaults write "ZoomChat" "ZoomShouldShowSharingWithSplitView" 'true'
  defaults write "ZoomChat" "ZMEnableShowUserName" 'true'
  defaults write "ZoomChat" "ZoomStereo" 'true'
  defaults write "ZoomChat" "ZoomFitDock" 'false'
  defaults write "ZoomChat" "ZoomFitXPos" '3874'
  defaults write "ZoomChat" "ZoomFitYPos" '1412'


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
  defaults write com.apple.finder DesktopViewSettings '{GroupBy=Kind;IconViewSettings={arrangeBy=dateAdded;backgroundColorBlue=1;backgroundColorGreen=1;backgroundColorRed=1;backgroundType=0;gridOffsetX=0;gridOffsetY=0;gridSpacing=82;iconSize=48;labelOnBottom=0;showIconPreview=1;showItemInfo=1;textSize=11;viewOptionsVersion=1;};}'
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
  # Disable the "Are you sure you want to open this application?" dialog
  # defaults write com.apple.LaunchServices LSQuarantine -bool false

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
    "Finder"
  do
  killall "${APP}" &> /dev/null
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
  cat "${PREFERENCE_FILE}" | jq '.brave.new_tab_page.show_rewards = false' | sponge "${PREFERENCE_FILE}"
  cat "${PREFERENCE_FILE}" | jq '.download.prompt_for_download = true' | sponge "${PREFERENCE_FILE}"
  cat "${PREFERENCE_FILE}" | jq '.brave.wallet.show_wallet_icon_on_toolbar = false' | sponge "${PREFERENCE_FILE}"
  cat "${PREFERENCE_FILE}" | jq '.brave.enable_window_closing_confirm = false' | sponge "${PREFERENCE_FILE}"
  # Set defaults for opening URLs in apps
  cat "${PREFERENCE_FILE}" | jq '
  .protocol_handler.allowed_origin_protocol_pairs +=
  {
    "https://us02web.zoom.us": {"zoommtg": true},
    "https://us06web.zoom.us": {"zoommtg": true},
    "https://www.dropbox.com": {"dropbox-client": true}
  }' |\
    sponge "${PREFERENCE_FILE}"

  cat "${LOCAL_STATE_FILE}" | jq '.browser.confirm_to_quit = false' | sponge "${LOCAL_STATE_FILE}"
  cat "${LOCAL_STATE_FILE}" | jq '.browser.enabled_labs_experiments = ["password-import@1"]' | sponge "${LOCAL_STATE_FILE}"
  open -a "Brave Browser" --args --make-default-browser
  echo "There are some settings that cannot be easily set from the CLI"
  echo "Do not forget to import your bookmarks, passwords, and set the default search engine"
}

configure_better_snap_tool() {
  echo "BetterSnapTool can only be downloaded from the MacAppStore"
  read -p "Download BetterSnapTool, then press enter when ready"
  defaults write "com.hegenberg.BetterSnapTool" "registeredHotkeys" '{0={keyCode=46;modifiers=6400;};1={keyCode="-1";modifiers=0;};10={keyCode="-1";modifiers=0;};100={keyCode="-1";modifiers=0;};102={keyCode="-1";modifiers=0;};104={keyCode="-1";modifiers=0;};105={keyCode="-1";modifiers=0;};106={keyCode="-1";modifiers=0;};11={keyCode="-1";modifiers=0;};12={keyCode="-1";modifiers=0;};13={keyCode="-1";modifiers=0;};14={keyCode="-1";modifiers=0;};15={keyCode=126;modifiers=8395008;};16={keyCode=125;modifiers=8395008;};17={keyCode="-1";modifiers=0;};18={keyCode="-1";modifiers=0;};19={keyCode="-1";modifiers=0;};2={keyCode=123;modifiers=8395008;};20={keyCode="-1";modifiers=0;};2001={keyCode="-1";modifiers=0;};2002={keyCode="-1";modifiers=0;};2003={keyCode="-1";modifiers=0;};2004={keyCode="-1";modifiers=0;};2005={keyCode="-1";modifiers=0;};2006={keyCode="-1";modifiers=0;};2007={keyCode="-1";modifiers=0;};2008={keyCode="-1";modifiers=0;};21={keyCode="-1";modifiers=0;};4={keyCode=124;modifiers=8395008;};5461={keyCode="-1";modifiers=0;};8={keyCode="-1";modifiers=0;};999={keyCode="-1";modifiers=0;};}'
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
  defaults write "com.copyq.copyq" "Theme.style_main_window" '1'

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

configure_flux() {
  defaults write org.herf.Flux SUHasLaunchedBefore -bool true
  defaults write org.herf.Flux dayColorTemp -int 4600
  defaults write org.herf.Flux lateColorTemp -float 2900
  echo "f.Lux needs your location."
  read -p "Enter your latitude (e.g. 10.2): " LAT
  read -p "Enter your longitued (e.g. 100.4): " LONG
  if [ -z "$LAT" ] || [ -z "$LONG" ]; then
    echo "No location entered. Please configure manually."
    return 0
  fi
  defaults write org.herf.Flux location "${LAT}00000,${LONG}00000"
  defaults write org.herf.Flux locationTextField "${LAT},${LONG}"
  defaults write org.herf.Flux locationType "L"
  defaults write org.herf.Flux wakeNotifyDisable -int 1
  defaults write org.herf.Flux wakeTime -int 510
}

link_files() {

  # Setup VIM
  link "${DOTFILE_PATH}/vim/.vim" "${HOME}/.vim"
  link "${DOTFILE_PATH}/vim/.vimrc" "${HOME}/.vimrc"
  git clone https://github.com/hashivim/vim-terraform.git ~/.vim/pack/plugins/start/vim-terraform
  git clone https://github.com/b4b4r07/vim-hcl ~/.vim/pack/plugins/start/vim-hcl
  git clone https://tpope.io/vim/surround.git ~/.vim/pack/plugins/start/surround

  # Set up git config and helpers
  link "${DOTFILE_PATH}/git/git-dyff" '/usr/local/bin/git-dyff'
  link "${DOTFILE_PATH}/git/.gitattributes" "${HOME}/.gitattributes"
  link "${DOTFILE_PATH}/git/.gitignore_global" "${HOME}/.gitignore_global"
  link "${DOTFILE_PATH}/git/.gitconfig" "${HOME}/.gitconfig"
  cp -n "${DOTFILE_PATH}/git/.gitcompany.tpl" "${HOME}/.gitcompany"
  # Allow for easy installation of gh releases
  link "${DOTFILE_PATH}/git/gh_install_release" '/usr/local/bin/gh_install_release'
  # Custom brew cask installer
  link "${DOTFILE_PATH}/installers/brew/brew_install_cask" '/usr/local/bin/brew_install_cask'
  # Custom brew formulae installer
  link "${DOTFILE_PATH}/installers/brew/brew_install_formulae" '/usr/local/bin/brew_install_formulae'
  find_replace COMPANY_EMAIL "${COMPANY_EMAIL}" "${HOME}/.gitcompany"
  find_replace COMPANY_GIT_DOMAIN "${COMPANY_GIT_DOMAIN}" "${HOME}/.gitconfig"
  find_replace '(includeIf "gitdir:~/src/)[^"]+' "\1${COMPANT_GIT_DOMAIN}/${GIT_ORG}"
  /opt/homebrew/opt/gnu-sed/libexec/gnubin/sed -i "s|COMPANY_EMAIL|${COMPANY_EMAIL}|g" "${HOME}/.gitcompany"
  /opt/homebrew/opt/gnu-sed/libexec/gnubin/sed -i "s|COMPANY_GIT_ORG|${COMPANY_GIT_ORG}|g" "${HOME}/.gitconfig"
}

install_all() {
  # In case the sudo timeout is set to 0, set it to 5 so we can install homebrew without needing to enter
  # our password like 500 times
  # Set sudo timeout to 5 min
  sudo echo "Defaults timestamp_timeout=5" | sudo tee /private/etc/sudoers.d/$USER
  # # Set file permissions on /usr/local/bin
  sudo chown -R $USER:admin /usr/local/bin/

  # # Install homebrew, then install the homebrew required packages.  I hate homebrew, so I avoid this at all costs
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # # Install wget, a prereq for everything else
  /opt/homebrew/bin/brew install wget

  # # Install JQ, its a prereq for the rest
  /opt/homebrew/bin/wget https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-arm64 -O /usr/local/bin/jq
  chmod +x /usr/local/bin/jq

  # # Install kubectl
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl.sha256"
  if ! echo $(shasum -a 256 kubectl) | grep $(cat kubectl.sha256); then
    echo "Could not validate shasum for kubectl...not installing"
  else
    chmod +x kubectl
    mv kubectl /usr/local/bin
  fi
  rm kubectl*

  # Install Krew
  (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
  )

  # Install Docker
  wget https://desktop.docker.com/mac/main/arm64/Docker.dmg -O docker.dmg
  install_dmg docker.dmg
  rm docker.dmg

  install_brave
  install_brew_cask $(cat "${DOTFILE_PATH}/installers/brew/casks.txt")
  install_brew_formulae
  install_brew_file "${DOTFILE_PATH}/installers/brew/Brewfile"
  configure_sublime
  install_shell_environment
  gh_install_releases "${DOTFILE_PATH}/installers/github/releases.json"
  install_go
  install_awscli
  install_text_expander
  configure_brave
  configure_better_snap_tool
  configure_copyq
  configure_system

  # # Install plistwatch to help with creating these scripts
  /usr/local/go/bin/go install github.com/catilac/plistwatch@latest

  # # Install go-jira
  /usr/local/go/bin/go install github.com/go-jira/jira/cmd/jira@latest

  # # Install hashicorp tools
  ${DOTFILE_PATH}/installers/hashicorp/hashicorp.sh

  # Set up our symlinks
  link_files

  # Now that our files are set and linked, we can clone and set private dotfiles
  clone_private_dotfiles_and_run
}

clone_private_dotfiles_and_run() {
  git clone git@github.com:nomeelnoj/dotfiles-private.git "${HOME}/src/github.com/nomeelnoj/dotfiles-private"
  bash "${HOME}/src/github.com/nomeelnoj/dotfiles-private/bootstrap.sh"
}

get_input_args $@
verify_input_args
# Ask for the administrator password upfront
sudo -vB
source "${DOTFILE_PATH}/installers/generic/install_helpers.sh"
source "${DOTFILE_PATH}/installers/github/gh_install_releases.sh"
source "${DOTFILE_PATH}/installers/brew/brew_installer.sh"

install_all

echo "###########################################################"
echo "#####         AUTOMATED INSTALLATION COMPLETE         #####"
echo "###########################################################"
echo "There are still a few things to do to get your environment "
echo "setup properly:"
echo ""
echo "- Set slack sidebar theme:"
echo "#303E4D,#31556E,#61aa9f,#FFFFFF,#4A5664,#FFFFFF,#afce76,#78AF8F,#31556E,#FFFFFF"
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
