#!/usr/bin/env bash
# Extension: AI Engineering Tools (herdr, pi)
# Sourced by the main bootstrap.sh — do not run directly

EXT_DIR="$DOTFILES_DIR/extensions/ai"

# --- Brewfile packages ---
info "Installing AI extension packages..."
brew bundle --file="$EXT_DIR/Brewfile" --no-upgrade
success "AI extension packages installed"

# --- Herdr config ---
info "Configuring herdr..."
mkdir -p "$HOME/.config/herdr"
link_config "$EXT_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"
success "Herdr configured"

# --- Pi extensions ---
info "Installing pi extensions..."
pi install npm:pi-annotate 2>/dev/null || true
pi install npm:@tmustier/pi-files-widget 2>/dev/null || true
success "Pi extensions installed"
