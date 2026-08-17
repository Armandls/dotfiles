#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --group-directories-first --git --header'
alias la='eza -la --icons=auto --group-directories-first --git --header'
alias lt='eza --tree --level=2 --icons=auto'
alias grep='grep --color=auto'

#Actual prompt 
PS1='\n\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '
