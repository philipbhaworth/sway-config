# ====================
# Ubuntu Homelab .zshrc
# Complete but focused for infrastructure work
# ====================

# ~~~~~~~~~~~~~~~ Path Configuration ~~~~~~~~~~~~~~~~~~~~~~~~
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Load all executable scripts from dotfiles/scripts and subdirs
export PATH="$HOME/dotfiles/scripts:$PATH"
for dir in "$HOME/dotfiles/scripts"/*; do
  [ -d "$dir" ] && export PATH="$dir:$PATH"
done

# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export LS_COLORS='di=34:ln=36:so=35:pi=33:ex=31:bd=34;46:cd=34;43:su=37;41:sg=30;43:tw=30;42:ow=30;43'
export EDITOR=vim
export VISUAL=vim
export PAGER=less

# Tool customization
export BAT_THEME="Nord"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# ~~~~~~~~~~~~~~~ History Configuration ~~~~~~~~~~~~~~~~~~~~~~~~
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

# ~~~~~~~~~~~~~~~ Completion System ~~~~~~~~~~~~~~~~~~~~~~~~
autoload -Uz compinit
compinit

# Better completions
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# ~~~~~~~~~~~~~~~ Prompt Configuration ~~~~~~~~~~~~~~~~~~~~~~~~
# Use Starship if available, otherwise use custom prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  # Custom prompt with colors (like your Mac version)
  setopt PROMPT_SUBST

  # Define colors
  typeset -A colors
  colors[username]="%F{green}"
  colors[hostname]="%F{yellow}"
  colors[reset]="%f"
  colors[prompt]="%F{white}"
  colors[info]="%F{blue}"
  colors[vcs]="%F{red}"

  # SSH detection
  [[ -n "$SSH_CLIENT" ]] && ssh_message="-ssh_session" || ssh_message=""

  # Set prompt
  PROMPT="
  ${colors[prompt]}${colors[username]}%n ${colors[reset]}@ ${colors[hostname]}%m ${colors[vcs]}${ssh_message} ${colors[prompt]}in ${colors[info]}%~ ${colors[reset]}
  ${colors[prompt]}❯${colors[reset]} "
  RPROMPT="${colors[prompt]}[%@]${colors[reset]}"
fi

# ~~~~~~~~~~~~~~~ Man Page Colors ~~~~~~~~~~~~~~~~~~~~~~~~
export LESS='-R'
export MANPAGER='less -s'
export LESS_TERMCAP_mb=$(printf '\e[01;31m')
export LESS_TERMCAP_md=$(printf '\e[01;38;5;74m')
export LESS_TERMCAP_me=$(printf '\e[0m')
export LESS_TERMCAP_se=$(printf '\e[0m')
export LESS_TERMCAP_so=$(printf '\e[38;5;246m')
export LESS_TERMCAP_ue=$(printf '\e[0m')
export LESS_TERMCAP_us=$(printf '\e[04;38;5;146m')

# ~~~~~~~~~~~~~~~ Functions ~~~~~~~~~~~~~~~~~~~~~~~~
# Navigation helper
up() {
  cd $(printf "%0.0s../" $(seq 1 ${1:-1}))
}

# Reload configuration
zsh_reload() {
  source ~/.zshrc
  echo "ZSH config reloaded!"
}

# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~
# Modern ls with lsd, fallback to regular ls
if command -v lsd >/dev/null 2>&1; then
    alias ls='lsd --group-dirs first'
    alias ll='lsd -alh --group-dirs first'
    alias la='lsd -a --group-dirs first'
    alias l='lsd -lah --group-dirs first'
    alias lt='lsd --tree -a -I ".git|__pycache__|.mypy_cache|.ipynb_checkpoints"'
    alias ltt='lsd --tree -a -I ".git|__pycache__|.mypy_cache|.ipynb_checkpoints" --depth 2'
else
    # Fallback to regular ls with colors
    alias ls='ls --color=auto'
    alias ll='ls -alh --color=auto'
    alias la='ls -a --color=auto'
    alias l='ls -lah --color=auto'
fi

# Navigation shortcuts
alias dot='cd ~/dotfiles/ && ll'
alias repo='cd ~/repos && ll'
alias config='cd ~/.config && ll'
alias logs='cd /var/log && ll'
alias systemd='cd /etc/systemd/system && ll'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Utilities
alias grep='grep --color=auto'
alias tree='tree -C'
alias h='history'
alias c='clear'
alias path='echo -e ${PATH//:/\\n}'
alias reload='zsh_reload'

# Config editing shortcuts
alias edzsh='vim ~/.zshrc'
alias edvim='vim ~/.vimrc'
alias edstarship='vim ~/.config/starship.toml'

# Git shortcuts
alias gs='git status'
if command -v lazygit >/dev/null 2>&1; then
    alias lg='lazygit'
fi

# Homelab-specific aliases
alias ans='ansible-playbook -i inventory.yml'
alias ap='ansible-playbook -i inventory.yml playbooks/'
alias dc='docker-compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlog='docker logs -f'

# System shortcuts
alias sys='systemctl'
alias sysuser='systemctl --user'

# Kubernetes (when available)
if command -v kubectl >/dev/null 2>&1; then
    alias k='kubectl'
fi

# Notification for long commands (if notify-send available)
if command -v notify-send >/dev/null 2>&1; then
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]+\s*//;s/[;&|]\s*alert$//'\'')"'
fi

# ~~~~~~~~~~~~~~~ Plugins ~~~~~~~~~~~~~~~~~~~~~~~~
# Load zsh-autosuggestions
if [ -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Load zsh-syntax-highlighting (must be last)
if [ -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Ansible completions
if command -v ansible >/dev/null 2>&1 && command -v register-python-argcomplete >/dev/null 2>&1; then
    eval $(register-python-argcomplete ansible)
    eval $(register-python-argcomplete ansible-playbook)
    eval $(register-python-argcomplete ansible-vault)
fi

# ~~~~~~~~~~~~~~~ Local Customizations ~~~~~~~~~~~~~~~~~~~~~~~~
# Source local customizations if they exist
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ~~~~~~~~~~~~~~~ End of .zshrc ~~~~~~~~~~~~~~~~~~~~~~~~

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
