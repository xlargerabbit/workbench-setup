#!/usr/bin/env bash
# Extension: AI Engineering Tools health checks
# Sourced by the main doctor.sh — do not run directly

EXT_DIR="$DOTFILES_DIR/extensions/ai"

section "AI Engineering Tools"

check_command "herdr"
check_command "pi"

check_pi_extension() {
  local ext="$1"
  if pi list 2>/dev/null | grep -q "$ext"; then
    ok "pi extension: $ext"
  else
    err "pi extension $ext not installed"
  fi
}

check_pi_extension "pi-annotate"
check_pi_extension "@tmustier/pi-files-widget"

check_symlink "$EXT_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"
