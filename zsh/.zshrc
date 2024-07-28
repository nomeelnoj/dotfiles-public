# To time sourcing and issues therein, use zprof
zmodload zsh/zprof # Requires zprof at the end of file to be uncommented
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
#
# export PATH="$HOME/go/bin:$PATH"
# export PATH="/usr/local/go/bin:$PATH"
# export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
# export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
# export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
# export PATH="/opt/homebrew/bin:$PATH"
# export PATH="/Users/$USER/Library/Python/3.9/bin:$PATH"
export GOPATH="$HOME/src/go"
export GOROOT="/usr/local/go"
export GO111MODULE=''
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:${GOPATH}/bin:$PATH"
export REPO_ROOT="$HOME/src"
export GITHUB_REPO_ROOT="${REPO_ROOT}/github.com"
export BITBUCKET_REPO_ROOT="${REPO_ROOT}/bitbucket.org"

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

alias gam3="/usr/local/bin/gamadv-xtd3/gam"

# Custom Settings
zstyle ':completion:*' special-dirs true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
# POWERLEVEL9K_SHORTEN_DELIMITER=""
# POWERLEVEL9K_SHORTEN_STRATEGY="truncate-to-unique"
DEFAULT_USER="${USER}"
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(virtualenv kubecontext)
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
#POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON="\uE703"
function reset_terminal() {
  stty sane
}
function timeout() {
  perl -e 'alarm shift; exec @ARGV' "$@"
}

function truncate_lsp() {
  truncate -s 5M ~/.local/state/nvim/lsp.log
}
function cclip() {
  while read line; do
    echo 'echo '"$line"'' | pbcopy
  done
}

function git_file_size() {
  git ls-tree -r -l --abbrev --full-name HEAD | sort -n -r -k 4
}


prompt_context(){}

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options. This allows you to apply configuration changes without
  # restarting zsh. Edit ~/.p10k.zsh and type `source ~/.p10k.zsh`.
  unset -m 'e(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  autoload -Uz is-at-least && is-at-least 5.1 || return

  # The list of segments shown on the left. Fill it with the most important segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # =========================[ Line #1 ]=========================
    # os_icon               # os identifier
    dir                     # current directory
    vcs                     # git status
    # =========================[ Line #2 ]=========================
    # newline                 # \n
    # prompt_char             # prompt symbol
  )

  # The list of segments shown on the right. Fill it with less important segments.
  # Right prompt on the last prompt line (where you are typing your commands) gets
  # automatically hidden when the input line reaches it. Right prompt above the
  # last prompt line gets hidden if it would overlap with left prompt.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    # =========================[ Line #1 ]=========================
    status                  # exit code of the last command
    command_execution_time  # duration of the last command
    background_jobs         # presence of background jobs
    direnv                  # direnv status (https://direnv.net/)
    asdf                    # asdf version manager (https://github.com/asdf-vm/asdf)
    virtualenv              # python virtual environment (https://docs.python.org/3/library/venv.html)
    anaconda                # conda environment (https://conda.io/)
    pyenv                   # python environment (https://github.com/pyenv/pyenv)
    goenv                   # go environment (https://github.com/syndbg/goenv)
    nodenv                  # node.js version from nodenv (https://github.com/nodenv/nodenv)
    nvm                     # node.js version from nvm (https://github.com/nvm-sh/nvm)
    nodeenv                 # node.js environment (https://github.com/ekalinin/nodeenv)
    # node_version          # node.js version
    # go_version            # go version (https://golang.org)
    # rust_version          # rustc version (https://www.rust-lang.org)
    # dotnet_version        # .NET version (https://dotnet.microsoft.com)
    # php_version           # php version (https://www.php.net/)
    # laravel_version       # laravel php framework version (https://laravel.com/)
    # java_version          # java version (https://www.java.com/)
    # package               # name@version from package.json (https://docs.npmjs.com/files/package.json)
    rbenv                   # ruby version from rbenv (https://github.com/rbenv/rbenv)
    rvm                     # ruby version from rvm (https://rvm.io)
    fvm                     # flutter version management (https://github.com/leoafarias/fvm)
    luaenv                  # lua version from luaenv (https://github.com/cehoffman/luaenv)
    jenv                    # java version from jenv (https://github.com/jenv/jenv)
    plenv                   # perl version from plenv (https://github.com/tokuhirom/plenv)
    phpenv                  # php version from phpenv (https://github.com/phpenv/phpenv)
    scalaenv                # scala version from scalaenv (https://github.com/scalaenv/scalaenv)
    haskell_stack           # haskell version from stack (https://haskellstack.org/)
    kubecontext             # current kubernetes context (https://kubernetes.io/)
    terraform               # terraform workspace (https://www.terraform.io)
    terraform_version     # terraform version (https://www.terraform.io)
    aws                     # aws profile (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
    aws_eb_env              # aws elastic beanstalk environment (https://aws.amazon.com/elasticbeanstalk/)
    azure                   # azure account name (https://docs.microsoft.com/en-us/cli/azure)
    gcloud                  # google cloud cli account and project (https://cloud.google.com/)
    google_app_cred         # google application credentials (https://cloud.google.com/docs/authentication/production)
    toolbox                 # toolbox name (https://github.com/containers/toolbox)
    context                 # user@hostname
    nordvpn                 # nordvpn connection status, linux only (https://nordvpn.com/)
    # ranger                  # ranger shell (https://github.com/ranger/ranger)
    nnn                     # nnn shell (https://github.com/jarun/nnn)
    xplr                    # xplr shell (https://github.com/sayanarijit/xplr)
    vim_shell               # vim shell indicator (:sh)
    midnight_commander      # midnight commander shell (https://midnight-commander.org/)
    nix_shell               # nix shell (https://nixos.org/nixos/nix-pills/developing-with-nix-shell.html)
    # vpn_ip                # virtual private network indicator
    # load                  # CPU load
    # disk_usage            # disk usage
    # ram                   # free RAM
    # swap                  # used swap
    todo                    # todo items (https://github.com/todotxt/todo.txt-cli)
    timewarrior             # timewarrior tracking status (https://timewarrior.net/)
    taskwarrior             # taskwarrior task count (https://taskwarrior.org/)
    # time                  # current time
    # =========================[ Line #2 ]=========================
    # newline
    # ip                    # ip address and bandwidth usage for a specified network interface
    # public_ip             # public IP address
    # proxy                 # system-wide http/https/ftp proxy
    # battery               # internal battery
    # wifi                  # wifi speed
    vault                   # Vault environment address
    # example               # example user-defined segment (see prompt_example function below)
  )

  ###################[ command_execution_time: duration of the last command ]###################
  # Show duration of the last command if takes at least this many seconds.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  # Show this many fractional digits. Zero means round to seconds.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  # Execution time color.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=255
  # Duration format: 1d 2h 3m 4s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  # Custom icon.
  # typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # Custom prefix.
  # typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='%ftook '

  ################[ terraform: terraform workspace (https://www.terraform.io) ]#################
  # Don't show terraform workspace if it's literally "default".
  typeset -g POWERLEVEL9K_TERRAFORM_SHOW_DEFAULT=false
  # POWERLEVEL9K_TERRAFORM_CLASSES is an array with even number of elements. The first element
  # in each pair defines a pattern against which the current terraform workspace gets matched.
  # More specifically, it's P9K_CONTENT prior to the application of context expansion (see below)
  # that gets matched. If you unset all POWERLEVEL9K_TERRAFORM_*CONTENT_EXPANSION parameters,
  # you'll see this value in your prompt. The second element of each pair in
  # POWERLEVEL9K_TERRAFORM_CLASSES defines the workspace class. Patterns are tried in order. The
  # first match wins.
  #
  # For example, given these settings:
  #
  #   typeset -g POWERLEVEL9K_TERRAFORM_CLASSES=(
  #     '*prod*'  PROD
  #     '*test*'  TEST
  #     '*'       OTHER)
  #
  # If your current terraform workspace is "project_test", its class is TEST because "project_test"
  # doesn't match the pattern '*prod*' but does match '*test*'.
  #
  # You can define different colors, icons and content expansions for different classes:
  #
  #   typeset -g POWERLEVEL9K_TERRAFORM_TEST_FOREGROUND=28
  #   typeset -g POWERLEVEL9K_TERRAFORM_TEST_VISUAL_IDENTIFIER_EXPANSION='⭐'
  #   typeset -g POWERLEVEL9K_TERRAFORM_TEST_CONTENT_EXPANSION='> ${P9K_CONTENT} <'
  typeset -g POWERLEVEL9K_TERRAFORM_CLASSES=(
      # '*prod*'  PROD    # These values are examples that are unlikely
      # '*test*'  TEST    # to match your needs. Customize them as needed.
      '*'         OTHER)
  typeset -g POWERLEVEL9K_TERRAFORM_OTHER_FOREGROUND=38
  # typeset -g POWERLEVEL9K_TERRAFORM_OTHER_VISUAL_IDENTIFIER_EXPANSION='⭐'

  #############[ terraform_version: terraform version (https://www.terraform.io) ]##############
  # Terraform version color.
  typeset -g POWERLEVEL9K_TERRAFORM_VERSION_FOREGROUND=38
  # typeset -g POWERLEVEL9K_TERRAFORM_VERSION_BACKGROUND=238
  # Custom icon.
  typeset -g POWERLEVEL9K_TERRAFORM_VERSION_VISUAL_IDENTIFIER_EXPANSION=$(echo '\uE268') #'⭐'

  #############[ kubecontext: current kubernetes context (https://kubernetes.io/) ]#############
  # Show kubecontext only when the command you are typing invokes one of these tools.
  # Tip: Remove the next line to always show kubecontext.
  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern'

  # Kubernetes context classes for the purpose of using different colors, icons and expansions with
  # different contexts.
  #
  # POWERLEVEL9K_KUBECONTEXT_CLASSES is an array with even number of elements. The first element
  # in each pair defines a pattern against which the current kubernetes context gets matched.
  # More specifically, it's P9K_CONTENT prior to the application of context expansion (see below)
  # that gets matched. If you unset all POWERLEVEL9K_KUBECONTEXT_*CONTENT_EXPANSION parameters,
  # you'll see this value in your prompt. The second element of each pair in
  # POWERLEVEL9K_KUBECONTEXT_CLASSES defines the context class. Patterns are tried in order. The
  # first match wins.
  #
  # For example, given these settings:
  #
  #   typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
  #     '*prod*'  PROD
  #     '*test*'  TEST
  #     '*'       DEFAULT)
  #
  # If your current kubernetes context is "deathray-testing/default", its class is TEST
  # because "deathray-testing/default" doesn't match the pattern '*prod*' but does match '*test*'.
  #
  # You can define different colors, icons and content expansions for different classes:
  #
  #   typeset -g POWERLEVEL9K_KUBECONTEXT_TEST_FOREGROUND=28
  #   typeset -g POWERLEVEL9K_KUBECONTEXT_TEST_VISUAL_IDENTIFIER_EXPANSION='⭐'
  #   typeset -g POWERLEVEL9K_KUBECONTEXT_TEST_CONTENT_EXPANSION='> ${P9K_CONTENT} <'
  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
      # '*prod*'  PROD    # These values are examples that are unlikely
      # '*test*'  TEST    # to match your needs. Customize them as needed.
      '*'       DEFAULT)
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=255
  # typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # Use POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION to specify the content displayed by kubecontext
  # segment. Parameter expansions are very flexible and fast, too. See reference:
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion.
  #
  # Within the expansion the following parameters are always available:
  #
  # - P9K_CONTENT                The content that would've been displayed if there was no content
  #                              expansion defined.
  # - P9K_KUBECONTEXT_NAME       The current context's name. Corresponds to column NAME in the
  #                              output of `kubectl config get-contexts`.
  # - P9K_KUBECONTEXT_CLUSTER    The current context's cluster. Corresponds to column CLUSTER in the
  #                              output of `kubectl config get-contexts`.
  # - P9K_KUBECONTEXT_NAMESPACE  The current context's namespace. Corresponds to column NAMESPACE
  #                              in the output of `kubectl config get-contexts`. If there is no
  #                              namespace, the parameter is set to "default".
  # - P9K_KUBECONTEXT_USER       The current context's user. Corresponds to column AUTHINFO in the
  #                              output of `kubectl config get-contexts`.
  #
  # If the context points to Google Kubernetes Engine (GKE) or Elastic Kubernetes Service (EKS),
  # the following extra parameters are available:
  #
  # - P9K_KUBECONTEXT_CLOUD_NAME     Either "gke" or "eks".
  # - P9K_KUBECONTEXT_CLOUD_ACCOUNT  Account/project ID.
  # - P9K_KUBECONTEXT_CLOUD_ZONE     Availability zone.
  # - P9K_KUBECONTEXT_CLOUD_CLUSTER  Cluster.
  #
  # P9K_KUBECONTEXT_CLOUD_* parameters are derived from P9K_KUBECONTEXT_CLUSTER. For example,
  # if P9K_KUBECONTEXT_CLUSTER is "gke_my-account_us-east1-a_my-cluster-01":
  #
  #   - P9K_KUBECONTEXT_CLOUD_NAME=gke
  #   - P9K_KUBECONTEXT_CLOUD_ACCOUNT=my-account
  #   - P9K_KUBECONTEXT_CLOUD_ZONE=us-east1-a
  #   - P9K_KUBECONTEXT_CLOUD_CLUSTER=my-cluster-01
  #
  # If P9K_KUBECONTEXT_CLUSTER is "arn:aws:eks:us-east-1:123456789012:cluster/my-cluster-01":
  #
  #   - P9K_KUBECONTEXT_CLOUD_NAME=eks
  #   - P9K_KUBECONTEXT_CLOUD_ACCOUNT=123456789012
  #   - P9K_KUBECONTEXT_CLOUD_ZONE=us-east-1
  #   - P9K_KUBECONTEXT_CLOUD_CLUSTER=my-cluster-01
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION=
  # Show P9K_KUBECONTEXT_CLOUD_CLUSTER if it's not empty and fall back to P9K_KUBECONTEXT_NAME.
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${P9K_KUBECONTEXT_CLOUD_CLUSTER:-${P9K_KUBECONTEXT_NAME}}'
  # Append the current context's namespace if it's not "default".
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${${:-/$P9K_KUBECONTEXT_NAMESPACE}:#/default}'

  # Custom prefix.
  # typeset -g POWERLEVEL9K_KUBECONTEXT_PREFIX='%248Fat '

  #[ aws: aws profile (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) ]#
  # Show aws only when the command you are typing invokes one of these tools.
  # Tip: Remove the next line to always show aws.
  typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|awless'
  # typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|awless|terraform|pulumi|terragrunt'

  # POWERLEVEL9K_AWS_CLASSES is an array with even number of elements. The first element
  # in each pair defines a pattern against which the current AWS profile gets matched.
  # More specifically, it's P9K_CONTENT prior to the application of context expansion (see below)
  # that gets matched. If you unset all POWERLEVEL9K_AWS_*CONTENT_EXPANSION parameters,
  # you'll see this value in your prompt. The second element of each pair in
  # POWERLEVEL9K_AWS_CLASSES defines the profile class. Patterns are tried in order. The
  # first match wins.
  #
  # For example, given these settings:
  #
  #   typeset -g POWERLEVEL9K_AWS_CLASSES=(
  #     '*prod*'  PROD
  #     '*test*'  TEST
  #     '*'       DEFAULT)
  #
  # If your current AWS profile is "company_test", its class is TEST
  # because "company_test" doesn't match the pattern '*prod*' but does match '*test*'.
  #
  # You can define different colors, icons and content expansions for different classes:
  #
  #   typeset -g POWERLEVEL9K_AWS_TEST_FOREGROUND=28
  #   typeset -g POWERLEVEL9K_AWS_TEST_VISUAL_IDENTIFIER_EXPANSION='⭐'
  #   typeset -g POWERLEVEL9K_AWS_TEST_CONTENT_EXPANSION='> ${P9K_CONTENT} <'
  typeset -g POWERLEVEL9K_AWS_CLASSES=(
      # '*prod*'  PROD    # These values are examples that are unlikely
      # '*test*'  TEST    # to match your needs. Customize them as needed.
      '*'       DEFAULT)
  typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=14
  typeset -g POWERLEVEL9K_AWS_DEFAULT_BACKGROUND=0
  # typeset -g POWERLEVEL9K_AWS_DEFAULT_VISUAL_IDENTIFIER_EXPANSION=$(echo '\uE268') #'⭐'

  # AWS segment format. The following parameters are available within the expansion.
  #
  # - P9K_AWS_PROFILE  The name of the current AWS profile.
  # - P9K_AWS_REGION   The region associated with the current AWS profile.
  typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION='${P9K_AWS_PROFILE//\%/%%}${P9K_AWS_REGION:+ ${P9K_AWS_REGION//\%/%%}}'

  #[ aws_eb_env: aws elastic beanstalk environment (https://aws.amazon.com/elasticbeanstalk/) ]#
  # AWS Elastic Beanstalk environment color.
  typeset -g POWERLEVEL9K_AWS_EB_ENV_FOREGROUND=70
  # Custom icon.
  # typeset -g POWERLEVEL9K_AWS_EB_ENV_VISUAL_IDENTIFIER_EXPANSION='⭐'s

  typeset -g POWERLEVEL9K_VAULT_SHOW_ON_COMMAND='vault'
}

function prompt_vault() {
  local vaultEnv=$(echo ${VAULT_ADDR} | cut -d '.' -f 2)
  p10k segment -f blue -t "Vault: $vaultEnv"
}

# Setup shell integration
source $HOME/src/github.com/nomeelnoj/dotfiles/.iterm2_shell_integration.zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#606D6E'
 __git_files () {
     _wanted files expl 'local files' _files
}

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
ENABLE_CORRECTION="true"

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
plugins=(git fzf)

source $ZSH/oh-my-zsh.sh

# Custom overrides for oh-my-zsh
# History settings normally set in ~/.oh-my-zsh/lib/history.zsh
# History settings
export HISTFILESIZE=1000000
export HISTSIZE=1000000
export SAVEHIST=1000000

# export MANPATH="/usr/local/man:$MANPATH"
# gh copilot extension aliases
# eval "$(gh copilot alias -- zsh)"


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
#function chpwd() {
#  if [ -r $PWD/.zsh_config ]; then
#    source $PWD/.zsh_config
#  else
#    source $HOME/.zshrc
#  fi
#}

###############
## Functions ##
###############
function whitespace() {
 printf %q $@
}

function gdrive_download() {
  FILE_ID="${1}"
  FILE_NAME="${1}"

  wget \
    --load-cookies /tmp/cookies.txt \
    "https://drive.google.com/u/0/uc?export=download&confirm=$(
      wget \
        --quiet \
        --save-cookies /tmp/cookies.txt \
        --keep-session-cookies \
        --no-check-certificate \
        'https://drive.google.com/u/0/uc?export=download&id=${FILE_ID}' -O- |\
        sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p'
    )&id=${FILE_ID}" \
      -O "${FILE_NAME}" \
      && rm -rf /tmp/cookies.txt
}

function git_clone() {
  # if [[ "${1}" = *"git@github.com"* ]]; then
  #   URL="${1}"
  #   if ! [[ "${1}" = *".git"* ]]; then
  #     URL="${1}.git"
  #   fi
  URL="${1}"
  URL="${URL%.*}"
  CLEANED_URL=$(echo "${URL}" | awk -F ':' '{print $NF}')
  REPO=$(basename "${CLEANED_URL}")
  ORG=$(basename $(dirname "${CLEANED_URL}"))
  # TLD=$(basename $(dirname $(dirname "${1}")))
  DOMAIN=$(echo "${URL}" | awk -F '@' '{print $2}' | awk -F ':' '{print $1}s')
  # else
  #   REPO=$(basename "${1}")
  #   ORG=$(basename $(dirname "${1}"))
  #   DOMAIN="github.com"
  #   URL="git@github.com:${1}.git"
  # fi
  DIR="${HOME}/src/${DOMAIN}/${ORG}/${REPO}"
  if [ -d "${DIR}" ]; then
    echo "Repo ${1} already exists at '${DIR}'"
  else
    mkdir -p "${DIR}"
    git clone "${URL}" "${DIR}"
    if [ "$?" -ne 0 ]; then
      echo "Clone failed"
      rm -r "${DIR}"
    fi
  fi
  cd ${DIR}
}

function git_clone_backup() {
  set -x
  if [[ "${1}" = *"git@github.com"* ]]; then
    URL="${1}"
    if ! [[ "${URL}" = *".git"* ]]; then
      echo "entered second"
      URL="${URL}.git"
    fi
    URL="${URL%.*}"
    CLEANED_URL=$(echo "${URL}" | awk -F ':' '{print $NF}')
    REPO=$(basename "${CLEANED_URL}")
    ORG=$(basename $(dirname "${CLEANED_URL}"))
    # TLD=$(basename $(dirname $(dirname "${1}")))
    DOMAIN=$(echo "${URL}" | awk -F '@' '{print $2}' | awk -F ':' '{print $1}s')
  else
    REPO=$(basename "${1}")
    ORG=$(basename $(dirname "${1}"))
    DOMAIN="github.com"
    URL="git@github.com:${1}.git"
  fi
  DIR="${HOME}/src/${DOMAIN}/${ORG}/${REPO}"
  if [ -d "${DIR}" ]; then
    echo "Repo ${1} already exists at '${DIR}'"
  else
    mkdir -p "${DIR}"
    git clone "${URL}" "${DIR}"
    if [ "$?" -ne 0 ]; then
      echo "Clone failed"
      rm -r "${DIR}"
    fi
  fi
  cd ${DIR}
}

# function git_clone() {
#   if [[ ! "${1}" == *"http"* ]]; then
#     echo "Currently only http is supported"
#     exit 10
#   fi

#   REPO=$(basename "${1}")
#   ORG=$(basename $(dirname "${1}"))
#   TLD=$(basename $(dirname $(dirname "${1}")))
#   DOMAIN="${TLD/.*/}"
#   DIR="${HOME}/src/${DOMAIN}/${ORG}/${REPO}"
#   if [ -d "${DIR}" ]; then
#     echo "Repo ${1} already exists at '${DIR}'"
#   else
#     mkdir -p "${DIR}"
#     git clone "${1}" "${DIR}"
#   fi
#   cd ${DIR}
# }

function graph_png() {
  if [ -z "${1}" ]; then
    echo "FATAL: NO ARGS!!!"
    return 1
  fi

  /usr/local/bin/dot -Tpng ${1} > ${1}.png && open ${1}.png
}

function openpref() {
    if [ -z "$1" ]
    then
        echo "FATAL: Enter a preference pane"
        return 1
    else
        open -b com.apple.systempreferences /System/Library/PreferencePanes/$1.prefPane
    fi
}

function kms_file() {
    if [ -z "$1" ]
    then
        echo "FATAL: Enter a key alias the first arg (starting with alias)"
        return 1
    fi
    if [ -z "$2" ]
    then
        echo "FATAL: Enter a secret value as the second arg"
        return 1
    fi
    aws kms encrypt --key-id "${1}" --plaintext fileb://"$2" --output text --query CiphertextBlob | clip
}


function kms_secret() {
    if [ -z "$1" ]
    then
        echo "FATAL: Enter a key alias the first arg (starting with alias)"
        return 1
    fi
    if [ -z "$2" ]
    then
        echo "FATAL: Enter a secret value as the second arg"
        return 1
    fi
    aws kms encrypt --key-id "${1}" --plaintext fileb://<(echo -n "$2") --output text --query CiphertextBlob | clip
}

function kms_decrypt {
    if [ -z "$1" ]
    then
        echo "FATAL: Enterciphertext as the first arg"
        return 1
    fi
    aws kms decrypt --ciphertext-blob fileb://<(echo "$1" | base64 -d) --output text --query Plaintext | base64 -d
}

find_files() {
	# Exclude dot files/folders
  set -x
	find "${1:-.}" -type f -not -path '*/\.*' |\
	fzf \
		--multi \
		--bind "ctrl-a:toggle-all" \
		--header='(toggle-all:ctrl-a)'
}

find_replace() {
  set -x
	# Single Line Match
	# Exclude dot files/folders
  FILES=($(find_files))
	[[ $FILES ]] && perl -p -i -e "s|${1}|${2}|g" ${FILES}
}

find_replace_string() {
	# File is String with \n as line return
	# Exclude dot files/folders
	# s == "dot matches new line"
  FILES=($(find_files))
	[[ ${FILES} ]] && perl -0 -p -i -e "s|${1}|${2}|gs" ${FILES}
}

function restart_gp() {
  launchctl unload /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*
  launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*
}

# Auto complete
source <(stern --completion=zsh)

function greb() {
    REMOTE=${1:-$(git_main_branch)}
    git fetch origin && git rebase origin/${REMOTE}
}

function confirm() {
    RED='\033[0;31m'
    NC='\033[0m' # no color
    PROMPT="${RED}Are you sure you want to continue (y/n)? ${NC}"
    echo -e $PROMPT
    read choice
    case "$choice" in
      y|Y )
        echo "Confirmed.  Proceeding..."
        ;;
      n|N )
        echo "Confirmation not received.  Exiting..."
        return 1
        ;;
      * ) echo "Invalid choice.  Please enter 'y' or 'n'"
        confirm
        ;;
    esac
}

export -f confirm &> /dev/null

  #jira list \
    #--query "project IN (${JIRA_PROJECTS}) AND resolution = unresolved AND status != Closed ORDER BY created" \

# Typora
function typora() {
  if [ "$#" -eq 0 ]; then
    open -a typora .
  else
    open -a typora $@
  fi
}


fjq() {
  local TEMP QUERY
  TEMP=$(mktemp -t fjq)
  cat > "$TEMP"
  QUERY=$(
    jq -C . "$TEMP" |
      fzf \
      --reverse \
      --ansi \
      --prompt 'jq> ' --query '.' \
      --preview "set -x; jq -C {q} \"$TEMP\"" \
      --header 'Press CTRL-Y to copy expression to the clipboard and quit' \
      --bind 'ctrl-y:execute-silent(echo -n {q} | pbcopy)+abort' \
      --print-query | head -1
  )
  [ -n "$QUERY" ] && jq "$QUERY" "$TEMP"
}

function b64gzip {
  if [ "$1" == "-d" ]; then
    echo "$2" | base64 -d | gunzip
  else
    echo "$1" | gzip | base64
  fi
}

traverse-upwards() {
  local dir=$(
    [ $# = 1 ] && [ -d "$1" ] && cd "$1"
    while true; do
      find "$PWD" -mindepth 1 -maxdepth 1 -type d
      echo "$PWD"
      [ $PWD = / ] && break
      cd ..
    done | fzf --tiebreak=end --height 50% --reverse --preview 'tree -C {} | head -200'
  ) && cd "$dir"
}

traverse() {
  local dir=$(
    [ $# = 1 ] && [ -d "$1" ] && cd "$1"
    while true; do
      find "$PWD" -type d -not -path '*/\.*'
      # if [[ "$(file -b --mime-encoding "$file")" = binary ]];
      #       { echo "Skipping   $file."; continue; }
      echo "$PWD"
      [ $PWD = / ] && break
      cd ..
    done | fzf --tiebreak=end --height 50% --reverse --preview 'tree -C {} | head -200'
  ) && cd "$dir"
}

function kubectlgetall {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i
    kubectl get --ignore-not-found ${i} -A -o yaml >> $1
  done
}

function s3_import(){
    while [ $# -gt 0 ];
    do
        key="$1"
        case $key in
            -b)
            local BUCKET=$2
            shift # past argument
            shift
            ;;
            -a)
            local ACL="true"
            shift # past argument
            ;;
            -l)
            local LIFECYCLE="true"
            shift # past argument
            ;;
            -log)
            # debug everything
            local LOGGING="true"
            shift # past argument
            ;;
            -v)
            local VERSIONING="true"
            shift # past argument
            ;;
            -w)
            local WEBSITE="true"
            shift # past argument
            ;;
            *)    # unknown option
            echo "unknown arg supplied"
            return 1
            shift # past argument
            ;;
        esac
    done
    if [ "${ACL}" = "true" ]; then
        terraform import 'module.s3.aws_s3_bucket_acl.default[0]' $BUCKET
    fi
    if [ "${LIFECYCLE}" = "true" ]; then
        terraform import 'module.s3.aws_s3_bucket_lifecycle_configuration.default[0]' $BUCKET
    fi
    if [ "${LOGGING}" = "true" ]; then
        terraform import 'module.s3.aws_s3_bucket_logging.default[0]' $BUCKET
    fi
    terraform import 'module.s3.aws_s3_bucket_server_side_encryption_configuration.default' $BUCKET
    if [ "${VERSIONING}" = "true" ]; then
        terraform import 'module.s3.aws_s3_bucket_versioning.default' $BUCKET
    fi
    if [ "${WEBSITE}" = "true" ]; then
        terraform import 'module.s3.aws_s3_bucket_website_configuration.default[0]' $BUCKET
    fi
}

# Recursive function that will
# - List all the secrets in the given $path
# - Call itself for all path values in the given $path
function traverse_vault_helper {
    if [ -z "$1" ]; then
      echo "You must provide a vault addr as the first arg!"
      return 1
    else
      local VAULT_ADDR="${1}"
    fi
    local readonly VAULT_TRAVERSE_PATH="$2"

    RESULT=$(VAULT_ADDR=${VAULT_ADDR} vault kv list -format=json "${VAULT_TRAVERSE_PATH}" 2>&1)

    STATUS=$?
    if [ ! $STATUS -eq 0 ];
    then
      if [[ $RESULT =~ "permission denied" ]]; then
        return
      fi
      >&2 echo "${RESULT}"
    fi

    for SECRET in $(echo "${RESULT}" | jq -r '.[]'); do
        if [[ "${SECRET}" == */ ]]; then
            traverse_vault_helper "${VAULT_TRAVERSE_PATH}${SECRET}"
        else
            echo "${VAULT_TRAVERSE_PATH}${SECRET}"
        fi
    done
}

function traverse_vault {
  if [ -z "$1" ]; then
    echo "You must provide a vault addr as the first arg!"
    return 1
  else
    local VAULT_ADDR="${1}"
  fi

  if [[ "$2" ]]; then
      # Make sure the path always end with '/'
      VAULTS=("${2%"/"}/")
  else
      VAULTS=$(VAULT_ADDR="${VAULT_ADDR}" vault secrets list -format=json | jq -r 'to_entries[] | select(.value.type =="kv") | .key')
  fi

  for VAULT in $VAULTS; do
      traverse_vault_helper ${VAULT_ADDR} ${VAULT}
  done
}


function dc_trace_cmd() {
  local parent=`docker inspect -f '{{ .Parent }}' $1` 2>/dev/null
  declare -i level=$2
  echo ${level}: `docker inspect -f '{{ .ContainerConfig.Cmd }}' $1 2>/dev/null`
  level=level+1
  if [ "${parent}" != "" ]; then
    echo ${level}: $parent
    dc_trace_cmd $parent $level
  fi
}

function gh_get_org_users() {
  local QUERY=$(cat <<EOF
  query(\$endCursor: String) {
    organization(login: "${GITHUB_ORG}") {
      samlIdentityProvider {
        ssoUrl
        externalIdentities (first: 100, after: \$endCursor) {
          edges {
            node {
              guid
              samlIdentity {
                nameId
              }
              user {
                login
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
  }
EOF
  )
  gh api graphql --paginate -f query="${QUERY}"
}


function gam_user_groups() {
  local EMAIL="${1}"
  if [ -z "${EMAIL}" ]; then
    echo "No user email provided."
    return 1
  fi
  gam3 print groups member $1
}

function disable_umbrella() {
  sudo launchctl unload /Library/LaunchDaemons/com.cisco.secureclient.vpnagentd.plist
}

# Add the called command to zsh history
# BASH VERSION: function log_command() { history -s ${@} && ${@} || return; }
function log_command() {
  print -s -- "$*"
  zsh -ic "$*"
}

function fvim() {
  # set -x
  #local IFS=$'\n'
  if [ -f ".terraform/modules/modules.json" ]; then
    local CUSTOM_DIRS=($(
      cat '.terraform/modules/modules.json' |
      jq -r '.Modules[].Dir' | sort | uniq
    ))
  fi

  FILES=$(
    find "${CUSTOM_DIRS[@]:-.}" -not -path './.*' -type f -print 2>/dev/null |
      fzf-tmux \
        --query="$1" \
        --multi \
        --select-1 \
        --exit-0 \
        --print0
  )
  FILES=($(echo "$FILES" | tr '\0' '\n'))
  if [[ -n "${FILES}" ]]; then
    log_command ${EDITOR:-vi} "${FILES[@]}"
  fi
  # eval 'fc -R'
  # builtin fc -R
}

zle -N fvim

bindkey '^P' fvim

#This section fixes the "my keyboard and mouse dont work on server 2022" in AWS SSM
#aws tools for powershell
#powershell -c "$null = Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false"
#powershell -c "$null = Save-Module -Name PowerShellGet -Path 'C:\Program Files\WindowsPowerShell\Modules' -Force -Confirm:$false"
#powershell -c "$null = Install-Module -Name PSReadLine -Scope AllUsers -Force -Confirm:$false"
#
#
#$null = Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
#$null = Save-Module -Name PowerShellGet -Path "C:\Program Files\WindowsPowerShell\Modules" -Force -Confirm:$false
#powershell -c '$null = Install-Module -Name PSReadLine -Scope AllUsers -Force -Confirm:$false'

# #function expand-multiple-dots() {
#    local MATCH
#    if [[ $LBUFFER =~ '(^| )\.\.\.+' ]]; then
#        LBUFFER=$LBUFFER:fs%\.\.\.%../..%
#    fi
#}
#
#function expand-multiple-dots-then-expand-or-complete() {
#    zle expand-multiple-dots
#    zle expand-or-complete
#}
#
#function expand-multiple-dots-then-accept-line() {
#    zle expand-multiple-dots
#    zle accept-line
#}
#
#zle -N expand-multiple-dots
#zle -N expand-multiple-dots-then-expand-or-complete
#zle -N expand-multiple-dots-then-accept-line
#bindkey '^I' expand-multiple-dots-then-expand-or-complete
#bindkey '^M' expand-multiple-dots-then-accept-line
# autoload -Uz manydots-magic
# manydots-magic

### SOURCE OTHER ZSHRC FILES ###
# awk 'BEGIN{srand(); print srand() "." int(rand()*1000000000)}'
# TODO: replace with https://github.com/mattmc3/zshrc.d
ZSH_DIR="$(dirname $(readlink -f "${(%):-%N}"))"
# awk 'BEGIN{srand(); print srand() "." int(rand()*1000000000)}'
for FILE in $(ls -a "${ZSH_DIR}"/.* | grep -vE '.zshrc$'); do
  # awk 'BEGIN{srand(); print srand() "." int(rand()*1000000000)}'
  # echo "${FILE}"
  source "${FILE}"
done
# awk 'BEGIN{srand(); print srand() "." int(rand()*1000000000)}'

# Completion
#source <(kubectl completion zsh)
#source <(stern --completion=zsh)
#command -v flux >/dev/null && . <(flux completion zsh) && compdef _flux flux
# Make sure PATH is not duplicated
typeset -U path

# added by travis gem
[ -f "${HOME}/.travis/travis.sh" ] && source "${HOME}/.travis/travis.sh"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="${HOME}/.sdkman"
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

export PATH="/usr/local/Cellar/yarn/1.9.4/bin:$PATH"

export PATH="$HOME/go/bin:/usr/local/go/bin:/opt/homebrew/opt/grep/libexec/gnubin:/opt/homebrew/bin:$PATH"

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# ^^^ This file looks like this:
# Setup fzf
# ---------
# if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
#   export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
# fi

# # Auto-completion
# # ---------------
# [[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

# # Key bindings
# # ------------
# source "/usr/local/opt/fzf/shell/key-bindings.zsh"
# END SETUP FZF

#zprof
#
#
# HELPER JQ FUNCTIONS
# # .module | to_entries[] | .key as $key | .value[] | select(.source | endswith("iam_role")) | {key: $key, value: .assume_role_policies}
# # .module | to_entries[] | .key as $key | .value[] | select(.source | endswith("iam_role")) | {($key): has("assume_role_policies")}

# The next line updates PATH for the Google Cloud SDK.
if [ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]; then . "${HOME}/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]; then . "${HOME}/google-cloud-sdk/completion.zsh.inc"; fi
