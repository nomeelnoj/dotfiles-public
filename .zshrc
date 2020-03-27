# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
#
# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Custom Settings
zstyle ':completion:*' special-dirs true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(virtualenv)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(virtualenv kubecontext)
POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON="\uE703"

prompt_context(){}

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#606D6E'
# __git_files () {
#     _wanted files expl 'local files' _files
# }

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git per-directory-history)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
########################
# Per Directory Config #
########################
function chpwd() {
  if [ -r $PWD/.zsh_config ]; then
    source $PWD/.zsh_config
  else
    source $HOME/.zshrc
  fi
}

##############
# Aliases
#############
alias gam="python ${HOME}/src/GAM/GAM-3.65/src/gam.py"
alias mirror="${HOME}/src/GAM/mirror_user.sh"
alias newgroup="${HOME}/src/GAM/newgroup.sh"
alias newhire="${HOME}/src/GAM/newhire.sh"
alias terminate="${HOME}/src/GAM/term_user.sh"
alias remove="${HOME}/src/GAM/remove_groups.sh"
alias patent="${HOME}/src/GAM/patent.sh"
alias updategroup="${HOME}/src/GAM/groupadd.sh"
alias membership="${HOME}/src/GAM/members_can_view.sh"
alias assettags="${HOME}/src/Casper/update_computer_info.sh"
alias dc="cd $PROJECT_PATH && docker-compose"
alias butler="cd $PROJECT_PATH && python butler.py"
alias login-ecr='$(aws ecr get-login --region us-west-2 --no-include-email)'
alias prod-rds="aws rds describe-db-snapshots --db-instance-identifier db-prod-01 --snapshot-type automated --query \"DBSnapshots[?SnapshotCreateTime>='`date +%Y-%m-%d`'].DBSnapshotIdentifier\""
alias docker-chrome="docker run -p 5900:5900 -e VNC_SERVER_PASSWORD=password --user apps --privileged local/chrome:0.0.1"
alias kc="kubectl"
alias kb="kustomize build"
alias kcn="kubectl config set-context --current --namespace"
alias update_kustomize='/usr/local/bin/update_kustomize.sh'
alias kustom="python3 kustom.py"

############
# Sourcing #
############
#source ~/.fonts/*.sh

#################
# Env Variables #
#################
export PS1="\W \$ "
export DELETE_ES_INDICES="1"
export DISABLE_LAUNCH_DARKLY="0"
export DISABLE_PHANTOMJS_DOWNLOADS="1"
export MIGRATE_ON_EDITOR_START=1
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_171.jdk/Contents/Home
export GROOVY_HOME=/usr/local/bin/groovy
export GPG_TTY=$(tty)
export GOBIN="/Users/jleemon/go/bin"

#############
# Functions #
#############
function openpref() {
    if [ -z "$1" ]
    then
        echo "FATAL: Enter a preference pane"
        return 1
    else
        open -b com.apple.systempreferences /System/Library/PreferencePanes/$1.prefPane
    fi
}

function secretseal() {
    if [ -z "$1" ]
    then
        echo "FATAL: Enter a secret name"
        return 1
    fi
    if [ -z "$2" ]
    then
        echo "FATAL: Enter a secret key name"
        return 1
    fi
    if [ -z "$3" ]
    then
        echo "FATAL: Enter a file name to pull the secret from"
        return 1
    fi
    if [ -z "${4}" ]
    then
        echo "FATAL: Enter an environment"
        return 1
    fi

    kubectl --context=${4} create secret generic ${1} --dry-run --from-file=${2}=${3} -o json | kubeseal --cert sealed-secrets-${4}.crt --format yaml > ${1}.yaml
}

okta_auth() {
  DUO_DEVICE="phone1"
  if [[ $(ioreg -p IOUSB -l -w 0 | grep '"USB Vendor Name" = "Yubico"') ]]; then
    DUO_DEVICE='u2f'
  fi
  if [[ -z ${1+x} ]]; then PROFILES=${AWS_PROFILE}; else PROFILES=${1}; fi
  for PROFILE in ${PROFILES//,/ }
  do
    validate_aws_credentials ${PROFILE}
    if [[ $? -ne 0 ]]; then
      aws-okta \
        --debug \
        --mfa-provider DUO \
        --mfa-duo-device ${DUO_DEVICE} \
        --mfa-factor-type web \
        --assume-role-ttl 10h \
        --session-ttl 10h \
        write-to-credentials \
        ${PROFILE} \
        ~/.aws/credentials
      EXPIRATION=$(
        aws-okta \
          cred-process \
          ${PROFILE} | \
        jq -r .Expiration)
      echo "Expiration: ${EXPIRATION}"
    fi
  done
}


# Auto complete
source <(stern --completion=zsh)

# added by travis gem
[ -f "${HOME}/.travis/travis.sh" ] && source "${HOME}/.travis/travis.sh"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="${HOME}/.sdkman"
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

export PATH="/usr/local/Cellar/yarn/1.9.4/bin:$PATH"

