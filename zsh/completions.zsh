autoload -Uz compinit
if [[ -f "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump" ]] && \
   [[ "$(find "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump" -mtime -1 2>/dev/null)" ]]; then
  compinit -C -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"
else
  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
