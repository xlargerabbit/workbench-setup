# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Search and open in editor
rgf() {
  local file
  file=$(rg --files-with-matches "$1" | fzf --preview "bat --color=always --highlight-line {2} {1}" --preview-window '~3:+{2}+3/2')
  [[ -n "$file" ]] && "$EDITOR" "$file"
}
