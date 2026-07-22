# eza (ls replacement)
alias ls="eza"
alias ll="eza -lah --git"
alias la="eza -a"
alias lt="eza --tree --level=2"

# bat (cat replacement)
alias cat="bat --paging=never"

# git
alias g="git"
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline -20"
alias lg="lazygit"

# navigation
alias ..="cd .."
alias ...="cd ../.."

# safety
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

# workspace
alias ws="z ~/workspace"
