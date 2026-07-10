export EDITOR="zed --wait"
export VISUAL="$EDITOR"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
