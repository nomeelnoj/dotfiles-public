# Measure performance, shell is slow
# zmodload zsh/zprof
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
#
export PATH="$HOME/go/bin:/usr/local/go/bin:/opt/homebrew/opt/grep/libexec/gnubin:/opt/homebrew/bin:$PATH"

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

# User configuration

# export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$HOME/go/bin:$PATH"

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
#function chpwd() {
#  if [ -r $PWD/.zsh_config ]; then
#    source $PWD/.zsh_config
#  else
#    source $HOME/.zshrc
#  fi
#}

#############
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
alias butler="cd $PROJECT_PATH && python butler.py"
alias login-ecr='$(aws ecr get-login --region us-west-2 --no-include-email)'
alias prod-rds="aws rds describe-db-snapshots --db-instance-identifier db-prod-01 --snapshot-type automated --query \"DBSnapshots[?SnapshotCreateTime>='`date +%Y-%m-%d`'].DBSnapshotIdentifier\""
alias docker-chrome="docker run -p 5900:5900 -e VNC_SERVER_PASSWORD=password --user apps --privileged local/chrome:0.0.1"
alias kc="kubectl"
alias kb="kustomize build"
alias kcn="kubectl config set-context --current --namespace"
alias update_kustomize='/usr/local/bin/update_kustomize.sh'
alias kustom="python3 kustom.py"
alias dc=docker-compose
alias gpush="git push -u"
alias vault-groups="vault list /auth/ldap/groups | tail -n +3 | xargs -I{} sh -c 'printf \"{}\": ; vault read --format json /auth/ldap/groups/{} | jq .data.policies -r'"
alias tf="terraform"
alias tfp="terraform plan"
alias tfi="terraform init --upgrade"
alias tfa="terraform apply"
alias gitcm="git checkout master"
alias gmp="git checkout master && git pull"
alias clip="pbcopy"
alias clipi="tee <(pbcopy)"
alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
alias fluxall="kubectl get kustomization,imageupdateautomation,imagepolicy,imagerepository,helmrelease,gitrepository,helmrepository"
alias cluster_auth="~/repo/personal/tools/bash_icauth.sh"
alias grep="grep --binary-file=without-match"
alias tu="traverse-upwards"
alias td="traverse"
alias ing="ingress.v1.networking.k8s.io"
alias cloudtrail_query="~/dotfiles/cloudtrail_query.sh"
alias gh='EDITOR="sublime --wait --new-window" gh'
alias colordiff="git diff --no-index $1 $2"
alias aws="aws --no-cli-pager"

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
export TF_PLUGIN_CACHE_DIR=~/.terraform
export ECR_IMAGE_REPO="${ECR_REGISTRY}.dkr.ecr.us-east-1.amazonaws.com"
export GODEBUG=asyncpreemptoff=1

###############
## Functions ##
###############
#function whitespace() {
#  printf %q $@
#}

function aws_decode() {
  aws sts \
    decode-authorization-message \
    --encoded-message \
    $@ |\
    jq -r '.DecodedMessage | fromjson'
}

function expand_aws_attribute(){
while read LINE
do
  # set -x
  DIR_PATH="${HOME}/repo/iann0036/iam-dataset"
  if [ -d "${DIR_PATH}" ]; then
    CLEAN=$( echo "${LINE}" | tr -d '*')
    RAW="-r"
    if [[ "${CLEAN}" =~ ^\".*\"$ ]]; then
      CLEAN=$(echo ${CLEAN} | cut -d \" -f2)
      RAW=""
    fi
    if [[ "${CLEAN}" =~ ^\".*\",$ ]]; then
      CLEAN=$(echo ${CLEAN} | cut -d \" -f2)
      RAW=""
    fi
    RESULTS=$(cat "${DIR_PATH}/map.json" |\
    jq \
      ${RAW} \
      --arg key "${CLEAN}" \
      '.sdk_method_iam_mappings[][] |
       select(.action | startswith($key)) |
       .action ' | sort | uniq
    )
    if [[ "${RAW}" == "" ]]; then
      echo "${RESULTS}" | sort | uniq | sed 's/$/,/'
    else
     echo "${RESULTS}" | sort | uniq
    fi
 else
   echo "Please Clone 'https://github.com/iann0036/iam-dataset'"
  fi
done < "${1:-/dev/stdin}"
}

function git_clone() {
  if [[ ! "${1}" == *"http"* ]]; then
    echo "Currently only http is supported"
    exit 10
  fi

  REPO=$(basename "${1}")
  ORG=$(basename $(dirname "${1}"))
  TLD=$(basename $(dirname $(dirname "${1}")))
  DOMAIN="${TLD/.*/}"
  DIR="${HOME}/src/${DOMAIN}/${ORG}/${REPO}"
  if [ -d "${DIR}" ]; then
    echo "Repo ${1} already exists at '${DIR}'"
  else
    mkdir -p "${DIR}"
    git clone "${1}" "${DIR}"
  fi
  cd ${DIR}
}

function awsp() {
  # Sets the AWS profile via environment variable
  if [ -z "$1" ]; then
    echo "FATAL: Enter a profile"
    return 1
  else
    export AWS_PROFILE=$1
  fi
}

function kcadmin() {
  if [ -z "$1" ]; then
    kubectl exec -it $(kubectl get pod --selector=release=admin-pod -o jsonpath='{.items[*].metadata.name}') -- bash
  else
    echo "Using context $1 for admin pod"
    kubectl --context $1 exec -it $(kubectl --context $1 get pod --selector=release=admin-pod -o jsonpath='{.items[*].metadata.name}') -- bash
  fi
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

function find_replace() {
    # Exclude dot files/folders
    perl -p -i -e "s|$1|$2|g" \
    $(find . -type f -not -path '*/\.*')
}

function find_replace_setup() {
    # Exclude dot files/folders
    perl -p -i -e "s|$1|$2|g" \
    $(find . -type f -not -path '*/\.*' -name 'setup.tf')
}

function find_replace_setup_json() {
    # Exclude dot files/folders
    perl -p -i -e "s|$1|$2|g" \
    $(find . -type f -not -path '*/\.*' -name 'setup.tf.json')
}

validate_aws_credentials() {
  if [[ -z ${1+x} ]]; then PROFILES=${AWS_PROFILE}; else PROFILES=${1}; fi
  echo "profiles list: $PROFILES"
  for PROFILE in ${PROFILES//,/ }
  do
    AWS_PROFILE=${PROFILE}
    echo "AWS Profile: ${AWS_PROFILE}"
    PAGER="cat" aws2 sts get-caller-identity --profile $AWS_PROFILE
  done
}

function restart_gp() {
  launchctl unload /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*
  launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*
}

function get_secret() {
  if [ -z "$1" ]; then
    echo "Must provide a secret name!"
    return 1
  fi
  if [ -z "$2" ]; then
    COMMAND="kubectl get secret $1 -o json | jq '.data | with_entries(.value |= (. | @base64d))'"
  else
    COMMAND="kubectl --context $2 get secret $1 -o json | jq '.data | with_entries(.value |= (. | @base64d))'"
  fi
  eval $COMMAND
}

function move_certs() {
  if [ -z "$1" ]; then
    echo "Must provide a cert CN name!"
    return 1
  fi
  if [ -z "$2" ]; then
    echo "Must provide an env name!"
  fi
  COMMAND="ls $1* | sed -e 'p;s/${1}/${1}-${2}/' | xargs -n2 mv"
  eval $COMMAND
}

function s3_import() {
 if [ -z "$1" ]; then
   echo "Must enter a bucket name!"
   return 1
 fi
 terraform import module.s3.aws_s3_bucket.s3_bucket "${1}"
 terraform import module.s3.aws_s3_bucket_policy.s3_bucket_policy "${1}"
 terraform import 'module.s3.aws_s3_bucket_public_access_block.s3_public_access_block[0]' "${1}"
}

okta_auth() {
  DUO_DEVICE="phone1"
  if [[ $(ioreg -p IOUSB -l -w 0 | grep '"USB Vendor Name" = "Yubico"') ]]; then
    DUO_DEVICE='u2f'
  fi
  if [[ -z ${1+x} ]]; then PROFILES=${AWS_PROFILE}; else PROFILES=${1}; fi
  for PROFILE in $(echo ${PROFILES//,/ });
  do
    echo "profile is: ${PROFILE}"
    aws-okta \
      --debug \
      --mfa-provider DUO \
      --mfa-duo-device ${DUO_DEVICE} \
      --mfa-factor-type web \
      --assume-role-ttl 12h \
      --session-ttl 12h \
      write-to-credentials \
      ${PROFILE} \
      ~/.aws/credentials
    EXPIRATION=$(
      aws-okta \
        cred-process \
        ${PROFILE} | \
      jq -r .Expiration)
    echo "Expiration: ${EXPIRATION}"
  done
}

# Auto complete
source <(stern --completion=zsh)

okta_auth_manual() {
    if [ -z "$1" ]; then
        echo "Must provide a profile name!"
        return 1
    fi
    aws-okta --debug --mfa-provider DUO --mfa-duo-device u2f --mfa-factor-type web write-to-credentials $1 ~/.aws/credentials
}

ldap_membership() {
  ldapsearch \
    -o ldif-wrap=no \
    -H ldaps://${DOMAIN_CONTROLLER}:636 \
    -D "${DOMAIN_DN}" \
    -w "${DOMAIN_PASSWORD}" \
    -b "${DOMAIN_ROOT}" "(&(cn=*)(sAMAccountName=$1))" 'memberOf' | \
  grep 'memberOf' | \
  awk '{print $2}'
}

function ldap_group() {
  ldapsearch \
    -o ldif-wrap=no \
    -H ldaps://${DOMAIN_CONTROLLER}:636 \
    -D "${DOMAIN_DN}" \
    -w "${DOMAIN_PASSWORD}" \
    -b "${DOMAIN_ROOT}" "(&(cn=$1))" 'member' | \
  grep -v 'requesting:' | \
  grep 'member' | \
  cut -d " " -f2-
}

ldap_profile() {
  ldapsearch \
    -o ldif-wrap=no \
    -H ldaps://${DOMAIN_CONTROLLER}:636 \
    -D "${DOMAIN_DN}" \
    -w "${DOMAIN_PASSWORD}" \
    -b "${DOMAIN_ROOT}" "(&(cn=*)(sAMAccountName=$1))" | \
  sed -n '/# requesting:/,/# search reference/p' |\
  grep -v '# search'
}

ldap_id() {
  ldapsearch \
    -o ldif-wrap=no \
    -H ldaps://${DOMAIN_CONTROLLER}:636 \
    -D "${DOMAIN_DN}" \
    -w "${DOMAIN_PASSWORD}" \
    -b "${DOMAIN_ROOT}" "(&(cn=*)(sAMAccountName=$1))" 'mail' 'sAMAccountName' 'name' | \
  grep -E 'mail|sAMAccountName|name'
}

ldap_email() {
  ldapsearch \
    -o ldif-wrap=no \
    -H ldaps://${DOMAIN_CONTROLLER}:636 \
    -D "${DOMAIN_DN}" \
    -w "${DOMAIN_PASSWORD}" \
    -b "${DOMAIN_ROOT}" "(&(cn=*)(mail=$1))" 'mail' 'sAMAccountName' 'name' | \
  grep -E 'mail|sAMAccountName|name'
}

ldap_public_key() {
  ldapsearch \
    -o ldif-wrap=no \
    -H ldaps://${DOMAIN_CONTROLLER}:636 \
    -D "${DOMAIN_DN}" \
    -w "${DOMAIN_PASSWORD}" \
    -b "${DOMAIN_ROOT}" "(&(cn=*)(sAMAccountName=$1))" 'sshPublicKey' | \
  grep -v 'requesting:' | \
  grep 'sshPublicKey' | \
  cut -d " " -f2-
}

function greb() {
    REMOTE=${1:-$(git_main_branch)}
    git fetch origin && git rebase origin/${REMOTE}
}

get_me_creds() {
  aws sso get-role-credentials \
    --account-id $(aws configure get sso_account_id --profile ${AWS_PROFILE}) \
    --role-name $(aws configure get sso_role_name --profile ${AWS_PROFILE}) \
    --access-token $(find ~/.aws/sso/cache -type f ! -name "botocore*.json" | xargs jq -r .accessToken) \
    --region $(aws configure get region --profile ${AWS_PROFILE}) |\
  jq -r '.roleCredentials |
      {
        "AWS_ACCESS_KEY_ID": .accessKeyId,
        "AWS_SECRET_ACCESS_KEY": .secretAccessKey,
        "AWS_SESSION_TOKEN": .sessionToken,
        "AWS_CREDENTIALS_EXPIRATION": (.expiration / 1000 | todate)
      } | keys[] as $k | "export \($k)=\(.[$k])"'
}

# Typora
function typora() {
  if [ "$#" -eq 0 ]; then
    open -a typora .
  else
    open -a typora $@
  fi
}

function tjira() {
  if [ -z "$2" ]; then
    QUERY="--query 'project IN (${1}) AND resolution = unresolved AND status != Closed ORDER BY created'"
  elif [ "$2" = "all" ]; then
    QUERY="--query 'project IN (${1}) ORDER BY created'"
  fi
}
export JIRA_PROJECTS="DATA"
function fjira() {
  if [ -z "$2" ]; then
    QUERY="project IN (${1}) AND resolution = unresolved AND status != Closed ORDER BY created"
  elif [ "$2" = "all" ]; then
    QUERY="project IN (${1}) ORDER BY created"
  fi
  local IFS=$'\n'
  jira list \
    --query "${QUERY}" \
    --template list |\
  fzf-tmux \
    --query="$1" \
    --multi \
    --select-1 \
    --preview  "echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c 'jira view %'" \
    --bind 'enter:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira edit % < /dev/tty"
      /,Ctrl-t:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira take %"
      /,Ctrl-C:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira transition --resolution=Done Resolved % < /dev/tty"
      /,Ctrl-c:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira transition --resolution=Done Done % < /dev/tty"
      /,Ctrl-s:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira transition \"In Dev\" % --noedit"
      /,Ctrl-S:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira transition \"In Progress\" % --noedit"
      /' \
    --exit-0
}

# My tickets
function mjira() {
  if [ -z "$2" ]; then
    QUERY="project IN (${1}) AND assignee = ${JIRA_USER_ID} AND resolution = unresolved AND status != Closed ORDER BY created"
  elif [ "$2" = "all" ]; then
    QUERY="project IN (${1}) AND assignee = ${JIRA_USER_ID} ORDER BY created"
  elif [ -z "$1" ]; then
    QUERY="assignee = ${JIRA_USER_ID} AND resolution = unresolved AND status != Closed ORDER BY created"
  fi
  local IFS=$'\n'
  jira list \
    --query "${QUERY}" \
    --template list |\
  fzf-tmux \
    --query="$1" \
    --multi \
    --select-1 \
    --preview  "echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c 'jira view %'" \
    --bind 'enter:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira edit % < /dev/tty"
      /,Ctrl-t:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira take %"
      /,Ctrl-C:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira transition --resolution=Done Accepted % < /dev/tty"
      /,Ctrl-c:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira transition --resolution=Done Done % < /dev/tty"
      /,Ctrl-s:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira transition \"In Dev\" % --noedit"
      /,Ctrl-S:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira transition \"In Progress\" % --noedit"
      /' \
    --exit-0
}

# Unresolved tickets in current sprint
function sjira() {
  QUERY="project = DATA AND assignee = ${JIRA_USER_ID} AND sprint in openSprints() AND resolution = unresolved AND status != Closed ORDER BY created"
  local IFS=$'\n'
  jira list \
    --query "${QUERY}" \
    --template list |\
  fzf-tmux \
    --query="$1" \
    --multi \
    --select-1 \
    --preview  "echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c 'jira view %'" \
    --bind 'enter:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira edit % < /dev/tty"
      /,Ctrl-c:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira transition --resolution=Done Accepted % < /dev/tty"
      /,Ctrl-s:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira transition \"In Dev\" % --noedit"
      /' \
    --exit-0
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


function tf_target() {
    local IFS=$'\n'
    local RETURN='terraform apply'
    while read -r line;
    do
        RETURN+=$(
          echo "${line}" | \
          cut \
            -d ' ' \
            -f 4 | \
          sed \
            -e "s/^/ --target='/" |\
          sed -e "s/$/'/"
        )
      done < <(fzf --multi --exit-0 --tac --no-sort)
    echo ${RETURN}
}

function tf_state_rm() {
    local IFS=$'\n'
    local RETURN='terraform state rm'
    while read -r line;
    do
        RETURN+=$(
          echo "${line}" | \
          cut \
            -d ' ' \
            -f 4 | \
          sed \
            -e 's/\"/\\\"/g'
        )
      done < <(fzf --multi --exit-0 --tac --no-sort)
    echo ${RETURN}
}

function tf_import() {
    local IFS=$'\n'
    local RETURN='terraform import'
    while read -r line;
    do
        RETURN+=$(
          echo "${line}" | \
          cut \
            -d ' ' \
            -f 4 | \
          sed \
            -e 's/^/ /' \
            -e 's/\[/\\\[/g' \
            -e 's/\]/\\\]/g'
        )
      done < <(fzf --multi --exit-0 --tac --no-sort)
    echo ${RETURN}
}

function tf_grep() {
  grep \
    -e '#' \
    -e ' + ' \
    -e ' - ' \
    -e ' ~ ' \
    -e '-/+'
}

function tf_list() {
    local IFS=$'\n'
    local RETURN='Items to be planned: \n'
    while read -r line;
    do
        RETURN+=$(
          echo "'\n${line}'" | \
          cut \
            -d ' ' \
            -f 4 # | \
          # sed \
          #   -e 's/\"/\\\"/g'
        )
      done < <(fzf --multi --exit-0 --tac --no-sort)
    echo ${RETURN}
}

# Vault Helper
function vault_auth() {
  URL="${VAULT_ADDR}/v1/auth/ldap/login/${DOMAIN_USERNAME}"
  echo "Requesting Auth from ${URL}"
  RESULTS=$(curl \
    -k \
    --request POST \
    --data "{\"password\": \"${DOMAIN_PASSWORD}\"}" \
    ${URL})
    # echo ${RESULTS}
    # echo ${RESULTS} | jq -r 'del(.auth.client_token)'
    echo ${RESULTS} | jq -r .auth.client_token > $HOME/.vault-token
}
export -f vault_auth &>/dev/null

function ecr() {
  if [ -z "$1" ]; then
    $(aws ecr get-login --no-include-email --registry-ids ${ECR_REGISTRY} --region us-east-1)
  else
    $(aws ecr get-login --no-include-email --registry-ids ${ECR_REGISTRY} --region us-east-1 --profile $1)
  fi
}

function assume_role() {
  if [ -z "$3" ]; then
    echo "No role session name provided in \$3, using 'default'"
  fi
  ROLE_SESSION_NAME=${3:-default}
  ASSUME_ROLE=$(aws sts assume-role --role-arn $1 --role-session-name ${ROLE_SESSION_NAME} --profile $2)
  export AWS_ACCESS_KEY_ID=$(echo $ASSUME_ROLE | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo $ASSUME_ROLE | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo $ASSUME_ROLE | jq -r '.Credentials.SessionToken')
}

function rename_msk() {
  if [ -z "$1" ]; then
    echo "Must provide app name!"
    return 1
  fi
  if [ -z "$2" ]; then
    echo "Must provide target env name!"
    return 1
  fi
  ls $1.* | sed "p;s/${1}/${1}-${2}/" | xargs -n2 mv
}

function kubectlgetall {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i
    kubectl get --ignore-not-found ${i} -A -o yaml >> $1
  done
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

##### NOTES #####
# TO find all files and add specific text at the beginning:
# perl -0777 -i -pe 's/(.*)/apiVersion: kustomize.config.k8s.io\/v1beta1\nkind: Kustomization\n\1/' path/to/kustomization.yaml
# find . -name 'kustomization.yaml' | xargs perl -0777 -i -pe 's/(.*)/apiVersion: kustomize.config.k8s.io\/v1beta1\nkind: Kustomization\n\1/'

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


# Completion
# source <(stern --completion=zsh)
command -v flux >/dev/null && . <(flux completion zsh) && compdef _flux flux

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
