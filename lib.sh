#!/usr/bin/env bash
# Shared helpers for bootstrap.sh, doctor.sh, and extensions

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Logging ---
info()    { printf "\033[1;34m==> %s\033[0m\n" "$1"; }
success() { printf "\033[1;32m==> %s\033[0m\n" "$1"; }
skip()    { printf "\033[1;33m==> %s (already installed)\033[0m\n" "$1"; }

# --- Doctor helpers ---
_doctor_pass=0
_doctor_fail=0
_doctor_warn=0

ok()      { ((_doctor_pass++)); printf "\033[1;32m  ✓ %s\033[0m\n" "$1"; }
err()     { ((_doctor_fail++)); printf "\033[1;31m  ✗ %s\033[0m\n" "$1"; }
hint()    { ((_doctor_warn++)); printf "\033[1;33m  ! %s\033[0m\n" "$1"; }
section() { printf "\n\033[1;36m── %s ──\033[0m\n" "$1"; }

check_command() {
  local name="$1" cmd="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    ok "$name ($(command -v "$cmd"))"
  else
    err "$name not found"
  fi
}

check_symlink() {
  local src="$1" dest="$2" label="${3:-}"
  [[ -z "$label" ]] && label="$dest"
  if [[ ! -L "$dest" ]]; then
    if [[ -e "$dest" ]]; then
      err "$label exists but is not a symlink"
    else
      err "$label missing"
    fi
  elif [[ "$(readlink "$dest")" != "$src" ]]; then
    err "$label points to $(readlink "$dest"), expected $src"
  else
    ok "$label -> $src"
  fi
}

# --- Bootstrap helpers ---
link_config() {
  local src="$1" dest="$2"
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    return
  fi
  if [[ -e "$dest" ]]; then
    mv "$dest" "${dest}.backup.$(date +%s)"
    printf "  Backed up existing %s\n" "$dest"
  fi
  ln -sf "$src" "$dest"
  printf "  Linked %s -> %s\n" "$src" "$dest"
}

# --- Extension dispatch ---
run_extensions() {
  local script_name="$1"
  shift
  local extensions=("$@")

  for ext in "${extensions[@]}"; do
    local ext_dir="$DOTFILES_DIR/extensions/$ext"
    local ext_script="$ext_dir/$script_name"
    if [[ -f "$ext_script" ]]; then
      info "Running extension: $ext"
      source "$ext_script"
    else
      printf "\033[1;31mExtension '%s' not found at %s\033[0m\n" "$ext" "$ext_script"
      exit 1
    fi
  done
}

parse_extensions() {
  local extensions=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --ext)
        shift
        if [[ "${1:-}" == "all" ]]; then
          for ext_dir in "$DOTFILES_DIR"/extensions/*/; do
            [[ -d "$ext_dir" ]] && extensions+=("$(basename "$ext_dir")")
          done
        else
          extensions+=("${1:-}")
        fi
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
  if [[ ${#extensions[@]} -gt 0 ]]; then
    printf '%s\n' "${extensions[@]}"
  fi
}
