#
# .zshrc
#
# @author Jeff Geerling
#
autoload -Uz compinit
compinit

# Colors.
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

# Don't require escaping globbing characters in zsh.
unsetopt nomatch

# Nicer prompt.
export PS1=$'\n'"%F{green} %*%F{blue} %3~ %F{white}$ "

# Enable plugins.
plugins=(git brew history kubectl history-substring-search)

# Custom $PATH with extra locations.
export PATH=/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/go/bin:/usr/local/git/bin:$HOME/.composer/vendor/bin:$HOME/.asdf/shims:/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/:$HOME/Library/Python/3.8/bin:$PATH

# Bash-style time output.
export TIMEFMT=$'\nreal\t%*E\nuser\t%*U\nsys\t%*S'

# Include alias file (if present) containing aliases for ssh, etc.
if [ -f ~/.aliases ]
then
  source ~/.aliases
fi

#export ASDF_DIR=$(brew --prefix asdf)
export ASDF_DIR='/usr/local/opt/asdf/libexec'
# Allow history search via up/down keys.
#source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
#bindkey "^[[A" history-substring-search-up
#bindkey "^[[B" history-substring-search-down


function linux() {
  container_name=linux-on-mac
  container_id=$(docker ps -aqf "name=$container_name")
  if [[ -z "$container_id" ]]; then
    container_id=$(docker run -dit --rm -w /root/src \
      -v /Users/$(whoami)/.vimrc:/root/.vimrc \
      -v /Users/$(whoami)/.kube:/root/.kube \
      -v /Users/$(whoami)/.ssh:/root/.ssh \
      -v /Users/$(whoami)/.aliases:/root/.bash_aliases \
      -v /Users/$(whoami)/src:/root/src\
      --name $container_name \
      mathewfleisch/docker-dev-env:v1.1.2)
  fi
  docker exec -it $container_id bash
}
function linuxrm() { 
  container_name=linux-on-mac
  container_id=$(docker ps -aqf "name=$container_name")
  if [[ -n "$container_id" ]]; then
    echo "Removing container: $(docker rm -f $container_id)"
  fi
}

# Completions.
autoload -Uz compinit && compinit
# Case insensitive.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Git upstream branch syncer.
# Usage: gsync master (checks out master, pull upstream, push origin).
function gsync() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a branch."
     return 0
 fi

 BRANCHES=$(git branch --list $1)
 if [ ! "$BRANCHES" ] ; then
    echo "Branch $1 does not exist."
    return 0
 fi

 git checkout "$1" && \
 git pull upstream "$1" && \
 git push origin "$1"
}

# Tell homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Super useful Docker container oneshots.
# Usage: dockrun, or dockrun [centos7|fedora27|debian9|debian8|ubuntu1404|etc.]
dockrun() {
 docker run -it geerlingguy/docker-"${1:-ubuntu1604}"-ansible /bin/bash
}

# Enter a running Docker container.
function denter() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a container ID or name."
     return 0
 fi

 docker exec -it $1 bash
 return 0
}

# Delete a given line number in the known_hosts file.
knownrm() {
 re='^[0-9]+$'
 if ! [[ $1 =~ $re ]] ; then
   echo "error: line number missing" >&2;
 else
   sed -i '' "$1d" ~/.ssh/known_hosts
 fi
}

getent() {
  [ "$1" == "hosts" ] && shift
  for x
  do
    echo $x $(dscacheutil -q host -a name $x | awk '/^ip_address/{print $NF}')
  done
}
# Allow Composer to use almost as much RAM as Chrome.
export COMPOSER_MEMORY_LIMIT=-1

# Ask for confirmation when 'prod' is in a command string.
#prod_command_trap () {
#  if [[ $BASH_COMMAND == *prod* ]]
#  then
#    read -p "Are you sure you want to run this command on prod [Y/n]? " -n 1 -r
#    if [[ $REPLY =~ ^[Yy]$ ]]
#    then
#      echo -e "\nRunning command \"$BASH_COMMAND\" \n"
#    else
#      echo -e "\nCommand was not run.\n"
#      return 1
#    fi
#  fi
#}
#shopt -s extdebug
#trap prod_command_trap DEBUG
# Added by https://ghe.megaleo.com/INFServices/scripts/
export PATH=$PATH:$HOME/.local/bin
# Added by https://ghe.megaleo.com/INFServices/scripts/
export VAULT_TLS_SERVER_NAME="vault.services.wd"
# Added by https://ghe.megaleo.com/INFServices/scripts/
export VAULT_ADDR="https://$VAULT_TLS_SERVER_NAME"
# Added by https://ghe.megaleo.com/INFServices/scripts/
export CONSUL_HTTP_ADDR="https://consul-api.services.wd"
# Added by https://ghe.megaleo.com/INFServices/scripts/
export CONSUL_ADDR="$CONSUL_HTTP_ADDR"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/mathew.fleisch/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/mathew.fleisch/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/mathew.fleisch/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/mathew.fleisch/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
#eval "$(atuin init zsh --disable-up-arrow)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#for filename in $(find ~/.shell.d -name '*.sh' | sort); do source $filename; done
