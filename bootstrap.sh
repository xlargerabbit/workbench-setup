#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/lib.sh"

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

# --- Verify fonts ---
info "Verifying font installation..."
for font_cask in font-jetbrains-mono-nerd-font font-fira-code-nerd-font; do
  if ! brew list --cask "$font_cask" &>/dev/null; then
    info "Installing $font_cask (missed by bundle)..."
    brew install --cask "$font_cask"
  fi
done
success "Fonts verified"

# --- Symlinks ---
info "Creating config symlinks..."
mkdir -p "$HOME/.config/ghostty/themes" \
         "$HOME/.config/zsh" \
         "$HOME/.config/git"

link_config "$DOTFILES_DIR/ghostty/config"   "$HOME/.config/ghostty/config"
link_config "$DOTFILES_DIR/ghostty/themes/catppuccin-mocha" "$HOME/.config/ghostty/themes/catppuccin-mocha"
link_config "$DOTFILES_DIR/starship.toml"    "$HOME/.config/starship.toml"
link_config "$DOTFILES_DIR/git/gitconfig"    "$HOME/.config/git/config"
link_config "$DOTFILES_DIR/git/gitignore_global" "$HOME/.config/git/gitignore_global"
link_config "$DOTFILES_DIR/zsh/zshrc"        "$HOME/.config/zsh/.zshrc"
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
  info "Configuring Zed auto-install extensions..."
  zed_settings="$HOME/.config/zed/settings.json"

  if [[ -f "$zed_settings" ]]; then
    if grep -q '"auto_install_extensions"' "$zed_settings"; then
      skip "auto_install_extensions already configured"
    else
      # Insert auto_install_extensions after the opening brace
      tmp="${zed_settings}.tmp.$$"
      sed '1,/{/s/{/{\
  "auto_install_extensions": {\
    "prettier": true,\
    "eslint": true,\
    "go": true,\
    "python": true,\
    "rust-analyzer": true,\
    "tailwindcss": true\
  },/' "$zed_settings" > "$tmp" && mv "$tmp" "$zed_settings"
      success "Added auto_install_extensions to Zed settings"
    fi
  else
    mkdir -p "$(dirname "$zed_settings")"
    cat > "$zed_settings" <<'ZED_EOF'
{
  "auto_install_extensions": {
    "prettier": true,
    "eslint": true,
    "go": true,
    "python": true,
    "rust-analyzer": true,
    "tailwindcss": true
  }
}
ZED_EOF
    success "Created Zed settings with auto_install_extensions"
  fi
else
  skip "Zed CLI not found — install Zed first"
fi

# --- Extensions ---
extensions=()
while IFS= read -r line; do
  [[ -n "$line" ]] && extensions+=("$line")
done < <(parse_extensions "$@")
if [[ ${#extensions[@]} -gt 0 ]]; then
  run_extensions "bootstrap.sh" "${extensions[@]}"
fi

echo ""
success "Setup complete! Open a new terminal to apply changes."
