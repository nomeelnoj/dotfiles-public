# Measure performance, shell is slow
# zmodload zsh/zprof
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
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
#POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON="\uE703"

prompt_context(){}

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#606D6E'
# __git_files () {
#     _wanted files expl 'local files' _files
#}

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
plugins=(git fzf)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$HOME/go/bin:$PATH"

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
    aws kms encrypt --key-id "${1}" --plaintext "$2" --output text --query CiphertextBlob | clip
}

function find_replace() {
    # Exclude dot files/folders
    perl -p -i -e "s|$1|$2|g" \
    $(find . -type f -not -path '*/\.*')
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

okta_auth() {
  DUO_DEVICE="phone1"
  if [[ $(ioreg -p IOUSB -l -w 0 | grep '"USB Vendor Name" = "Yubico"') ]]; then
    DUO_DEVICE='u2f'
  fi
  if [[ -z ${1+x} ]]; then PROFILES=${AWS_PROFILE}; else PROFILES=${1}; fi
  for PROFILE in ${PROFILES//,/ }
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
    REMOTE=${1:-master}
    git fetch origin && git rebase origin/${REMOTE}
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
            -e 's/^/ --target=/'
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
          echo "\n${line}" | \
          cut \
            -d ' ' \
            -f 4 | \
          sed \
            -e 's/\"/\\\"/g'
        )
      done < <(fzf --multi --exit-0 --tac --no-sort)
    echo ${RETURN}
}


# Vault Helper
function vault_auth() {
  URL="${VAULT_ADDR}/v1/auth/ldap/login/${DOMAIN_USERNAME}"
  echo "Requesting Auth from ${URL}"
    # -s \
  RESULTS=$(curl \
    -k \
    --request POST \
    --data "{\"password\": \"${DOMAIN_PASSWORD}\"}" \
    ${URL})
    echo ${RESULTS}
    echo ${RESULTS} | jq -r 'del(.auth.client_token)'
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

# Auto complete
source <(kubectl completion zsh)

# added by travis gem
[ -f "${HOME}/.travis/travis.sh" ] && source "${HOME}/.travis/travis.sh"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="${HOME}/.sdkman"
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

export PATH="/usr/local/Cellar/yarn/1.9.4/bin:$PATH"

#  Is this causing the slow down?
#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#zprof
