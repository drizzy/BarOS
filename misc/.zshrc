# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Powerlevel10k theme
source $HOME/.config/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Plugins
source $HOME/.plugins/zsh/zsh-sudo/sudo.plugin.zsh
source $HOME/.plugins/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.plugins/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# History settings
setopt histignorealldups sharehistory
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit && compinit

# Add PATHs
export PATH="$HOME/.local/bin:/snap/bin:/usr/local/bin:/usr/bin:/bin:/usr/sandbox"

# Aliases
alias ll="lsd -lh --group-dirs=first"
alias la="lsd -a --group-dirs=first"
alias lla="lsd -lha --group-dirs=first"
alias ls="lsd --group-dirs=first"
alias cat="bat"
alias icat="kitty +kitten icat"

function extractPorts() {
  ports="$(grep -oP '\d{1,5}/open' "$1" | awk -F'/' '{print $1}' | xargs | tr ' ' ',')"
  ip_address="$(grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' "$1" | sort -u | head -n 1)"
  echo -e "\n[*] Extracting information...\n"
  echo -e "\t[*] IP Address: $ip_address"
  echo -e "\t[*] Open ports: $ports\n"
  echo $ports | tr -d '\n' | xclip -sel clip
  echo -e "[*] Ports copied to clipboard\n"
}

# Set 'man' colors
function man() {
  env \
    LESS_TERMCAP_mb=$'\e[01;31m' \
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    man "$@"
}

# Finalize Powerlevel10k instant prompt
(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize