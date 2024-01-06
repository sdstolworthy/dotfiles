export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git iterm2 node zsh-autosuggestions)
source $HOME/.profile
source $ZSH/oh-my-zsh.sh
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
export PATH="$HOME/bin:$HOME/.toolbox/bin:$PATH"

# if you wish to use IMDS set AWS_EC2_METADATA_DISABLED=false

export AWS_EC2_METADATA_DISABLED=true


# Added by Amplify CLI binary installer
export PATH="$HOME/.amplify/bin:$PATH"
