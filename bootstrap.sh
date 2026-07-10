#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf "\033[1;34m==> %s\033[0m\n" "$1"; }
success() { printf "\033[1;32m==> %s\033[0m\n" "$1"; }
skip() { printf "\033[1;33m==> %s (already installed)\033[0m\n" "$1"; }

# --- Homebrew ---
if command -v brew &>/dev/null; then
  skip "Homebrew"
else
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  success "Homebrew installed"
fi

# --- Brewfile packages ---
info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile" --no-upgrade
success "Brewfile packages installed"

# --- Symlinks ---
info "Creating config symlinks..."
mkdir -p "$HOME/.config/ghostty" \
         "$HOME/.config/zsh" \
         "$HOME/.config/git"

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

link_config "$DOTFILES_DIR/ghostty/config"   "$HOME/.config/ghostty/config"
link_config "$DOTFILES_DIR/starship.toml"    "$HOME/.config/starship.toml"
link_config "$DOTFILES_DIR/git/gitconfig"    "$HOME/.config/git/config"
link_config "$DOTFILES_DIR/git/gitignore_global" "$HOME/.config/git/gitignore_global"
link_config "$DOTFILES_DIR/zsh/zshrc"        "$HOME/.config/zsh/zshrc"
link_config "$DOTFILES_DIR/zsh/aliases.zsh"  "$HOME/.config/zsh/aliases.zsh"
link_config "$DOTFILES_DIR/zsh/exports.zsh"  "$HOME/.config/zsh/exports.zsh"
link_config "$DOTFILES_DIR/zsh/functions.zsh" "$HOME/.config/zsh/functions.zsh"
link_config "$DOTFILES_DIR/zsh/completions.zsh" "$HOME/.config/zsh/completions.zsh"

# Point zsh to the config directory
if ! grep -q 'ZDOTDIR' "$HOME/.zshenv" 2>/dev/null; then
  echo 'export ZDOTDIR="$HOME/.config/zsh"' >> "$HOME/.zshenv"
  printf "  Added ZDOTDIR to ~/.zshenv\n"
fi

success "Symlinks created"

# --- asdf plugins and runtimes ---
info "Setting up asdf runtimes..."

install_asdf_runtime() {
  local plugin="$1" asdf_plugin="${2:-$1}"

  if asdf plugin list 2>/dev/null | grep -q "^${plugin}$"; then
    skip "asdf plugin: $plugin"
  else
    info "Adding asdf plugin: $plugin"
    asdf plugin add "$plugin" || true
  fi

  if asdf list "$plugin" 2>/dev/null | grep -q .; then
    skip "asdf runtime: $plugin"
  else
    info "Installing $plugin latest..."
    asdf install "$plugin" latest
    asdf set --home "$plugin" latest
    success "$plugin installed"
  fi
}

install_asdf_runtime nodejs
install_asdf_runtime bun
install_asdf_runtime python
install_asdf_runtime golang
install_asdf_runtime rust

success "asdf runtimes configured"

# --- Zed extensions ---
if command -v zed &>/dev/null; then
  info "Checking Zed extensions..."

  installed_extensions=$(zed --list-extensions 2>/dev/null || true)

  install_extension() {
    if echo "$installed_extensions" | grep -qi "^${1}$"; then
      return
    fi
    zed --install-extension "$1"
  }

  install_extension "prettier"
  install_extension "eslint"
  install_extension "go"
  install_extension "python"
  install_extension "rust-analyzer"
  install_extension "tailwindcss"

  success "Zed extensions installed"
else
  skip "Zed CLI not found — install Zed first"
fi

echo ""
success "Setup complete! Open a new terminal to apply changes."
