#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Aliases
alias ls='eza --color=auto --icons=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='grep --color=auto -E'
alias ll='eza -alF --icons'
alias la='eza -A --icons'
alias l='eza -F --icons'
alias fixcam='sudo usbreset 0c45:6d24 2>/dev/null || (CAM_BUS=$(grep -l -i "webcam" /sys/bus/usb/devices/*/product | cut -d/ -f6) && echo 0 | sudo tee /sys/bus/usb/devices/$CAM_BUS/authorized > /dev/null && sleep 1 && echo 1 | sudo tee /sys/bus/usb/devices/$CAM_BUS/authorized > /dev/null)'

# PATH. tmux panes are non-login shells, so this can't rely on ~/.profile.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
export PATH="$HOME/.local/bin:$HOME/.amp/bin:$PATH"   # .amp/bin: Amp CLI
export EDITOR=nvim

#export PYTHONPATH=$PYTHONPATH:$HOME/.local/lib/python3.13/site-packages/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.local/lib

# Shell tools. Each is skipped if it isn't installed.
command -v starship >/dev/null && eval "$(starship init bash)"
command -v fzf >/dev/null && eval "$(fzf --bash)"
command -v zoxide >/dev/null && eval "$(zoxide init bash --cmd cd)"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
command -v atuin >/dev/null && eval "$(atuin init bash)"

if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi
