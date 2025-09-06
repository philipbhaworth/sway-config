#!/bin/bash
# shellcheck shell=bash
# ====================
# Homelab .bashrc - Optimized
# ====================

# ~~~~~~~~~~~~~~~ Core Settings ~~~~~~~~~~~~~~~~~~~~~~~~
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ~~~~~~~~~~~~~~~ Path Configuration ~~~~~~~~~~~~~~~~~~~~~~~~
# Add paths without recursive scanning
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~
export CLICOLOR=1
export LS_COLORS='di=34:ln=36:so=35:pi=33:ex=31:bd=34;46:cd=34;43:su=37;41:sg=30;43:tw=30;42:ow=30;43'
export EDITOR=vim

# ~~~~~~~~~~~~~~~ History Configuration ~~~~~~~~~~~~~~~~~~~~~~~~
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=10000
shopt -s histappend

# ~~~~~~~~~~~~~~~ Prompt Configuration ~~~~~~~~~~~~~~~~~~~~~~~~
# Use Starship if available
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
else
    # Simple fallback prompt
    PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '
fi

# ~~~~~~~~~~~~~~~ Core Aliases ~~~~~~~~~~~~~~~~~~~~~~~~
# Modern ls with lsd fallback
if command -v lsd >/dev/null 2>&1; then
    alias ls='lsd --group-dirs first'
    alias ll='lsd -alh --group-dirs first'
    alias lt='lsd --tree -a -I ".git|__pycache__|.mypy_cache|.ipynb_checkpoints"'
else
    alias ls='ls --color=auto'
    alias ll='ls -alh --color=auto'
fi

# Navigation
alias ansi='cd ~/repos/ansible-homelab/ && ll'
alias repo='cd ~/repos/ && ll'
alias dot='cd ~/dotfiles && ll'
alias compose='cd ~/repos/ansible-homelab/files/docker-compose && ll'

# Utilities
alias c='clear'
alias grep='grep --color=auto'
alias tree='tree -C'
alias reload='source ~/.bashrc && echo "Reloaded!"'

# Git
alias gs='git status'
if command -v lazygit >/dev/null 2>&1; then
    alias lg='lazygit'
fi

# Ansible shortcuts (if you use bash for ansible work)
alias ap='ansible-playbook -i inventory.yml playbooks/'
alias aping='ansible all -i inventory.yml -m ping'

# ~~~~~~~~~~~~~~~ Bash Completion ~~~~~~~~~~~~~~~~~~~~~~~~
# Load completion if available (fast check)
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi