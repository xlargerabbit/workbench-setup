#!/usr/bin/env bash
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/lib.sh"

# ─────────────────────────────────────────────
section "Homebrew"
# ─────────────────────────────────────────────

if command -v brew &>/dev/null; then
  ok "Homebrew installed ($(brew --prefix))"

  missing_formulae=()
  for formula in fzf zoxide lazygit ripgrep fd eza bat jq yq delta atuin starship asdf; do
    if ! brew list "$formula" &>/dev/null; then
      missing_formulae+=("$formula")
    fi
  done
  if [[ ${#missing_formulae[@]} -eq 0 ]]; then
    ok "All Brewfile formulae installed"
  else
    err "Missing formulae: ${missing_formulae[*]}"
  fi

  missing_casks=()
  for cask in ghostty zed font-fira-code-nerd-font font-jetbrains-mono-nerd-font; do
    if ! brew list --cask "$cask" &>/dev/null; then
      missing_casks+=("$cask")
    fi
  done
  if [[ ${#missing_casks[@]} -eq 0 ]]; then
    ok "All Brewfile casks installed"
  else
    err "Missing casks: ${missing_casks[*]}"
  fi
else
  err "Homebrew not installed"
fi

# ─────────────────────────────────────────────
section "Shell (Zsh)"
# ─────────────────────────────────────────────

if [[ "$SHELL" == */zsh ]]; then
  ok "Default shell is zsh"
else
  hint "Default shell is $SHELL, expected zsh"
fi

if [[ -f "$HOME/.zshenv" ]] && grep -q 'ZDOTDIR' "$HOME/.zshenv"; then
  ok "ZDOTDIR configured in ~/.zshenv"
else
  err "ZDOTDIR not set in ~/.zshenv"
fi

for init_tool in starship zoxide fzf atuin; do
  check_command "$init_tool"
done

# ─────────────────────────────────────────────
section "Symlinks"
# ─────────────────────────────────────────────

check_symlink "$DOTFILES_DIR/ghostty/config"                  "$HOME/.config/ghostty/config"
check_symlink "$DOTFILES_DIR/ghostty/themes/catppuccin-mocha"  "$HOME/.config/ghostty/themes/catppuccin-mocha"
check_symlink "$DOTFILES_DIR/starship.toml"                   "$HOME/.config/starship.toml"
check_symlink "$DOTFILES_DIR/git/gitconfig"                   "$HOME/.config/git/config"
check_symlink "$DOTFILES_DIR/git/gitignore_global"            "$HOME/.config/git/gitignore_global"
check_symlink "$DOTFILES_DIR/zsh/zshrc"                       "$HOME/.config/zsh/.zshrc"
check_symlink "$DOTFILES_DIR/zsh/aliases.zsh"                 "$HOME/.config/zsh/aliases.zsh"
check_symlink "$DOTFILES_DIR/zsh/exports.zsh"                 "$HOME/.config/zsh/exports.zsh"
check_symlink "$DOTFILES_DIR/zsh/functions.zsh"               "$HOME/.config/zsh/functions.zsh"
check_symlink "$DOTFILES_DIR/zsh/completions.zsh"             "$HOME/.config/zsh/completions.zsh"

# ─────────────────────────────────────────────
section "Git"
# ─────────────────────────────────────────────

check_command "git"
check_command "delta"

if git config --global user.name &>/dev/null; then
  ok "git user.name = $(git config --global user.name)"
else
  err "git user.name not set"
fi

if git config --global user.email &>/dev/null; then
  ok "git user.email = $(git config --global user.email)"
else
  err "git user.email not set"
fi

if [[ "$(git config --global core.pager)" == "delta" ]]; then
  ok "git pager set to delta"
else
  hint "git pager is '$(git config --global core.pager)', expected 'delta'"
fi

# ─────────────────────────────────────────────
section "Runtime Managers (asdf)"
# ─────────────────────────────────────────────

if command -v asdf &>/dev/null; then
  ok "asdf installed ($(asdf --version 2>&1 | head -1))"

  for plugin in nodejs bun python golang rust; do
    if asdf plugin list 2>/dev/null | grep -q "^${plugin}$"; then
      version=$(asdf current "$plugin" 2>/dev/null | awk 'NR==2{print $2}')
      if [[ -n "$version" && "$version" != "______" ]]; then
        ok "$plugin $version"
      else
        hint "$plugin plugin installed but no version set"
      fi
    else
      err "$plugin plugin not installed"
    fi
  done
else
  err "asdf not installed"
fi

# ─────────────────────────────────────────────
section "CLI Tools"
# ─────────────────────────────────────────────

check_command "fzf"
check_command "zoxide"
check_command "lazygit"
check_command "ripgrep" "rg"
check_command "fd"
check_command "eza"
check_command "bat"
check_command "jq"
check_command "yq"

# ─────────────────────────────────────────────
section "Editor"
# ─────────────────────────────────────────────

check_command "zed"

if command -v zed &>/dev/null; then
  zed_settings="$HOME/.config/zed/settings.json"
  if [[ -f "$zed_settings" ]] && grep -q '"auto_install_extensions"' "$zed_settings"; then
    ok "auto_install_extensions configured in settings"
    for ext in prettier eslint go python rust-analyzer tailwindcss; do
      if grep -q "\"$ext\"" "$zed_settings"; then
        ok "Zed extension: $ext"
      else
        hint "Zed extension not in auto_install_extensions: $ext"
      fi
    done
  else
    err "auto_install_extensions not configured in $zed_settings"
  fi
fi

# ─────────────────────────────────────────────
section "Terminal (Ghostty)"
# ─────────────────────────────────────────────

if command -v ghostty &>/dev/null || [[ -d "/Applications/Ghostty.app" ]]; then
  ok "Ghostty installed"
else
  err "Ghostty not found"
fi

if [[ -f "$HOME/.config/ghostty/themes/catppuccin-mocha" ]]; then
  ok "Catppuccin Mocha theme present"
else
  err "Catppuccin Mocha theme missing"
fi

# ─────────────────────────────────────────────
# Extensions
# ─────────────────────────────────────────────

extensions=()
while IFS= read -r line; do
  [[ -n "$line" ]] && extensions+=("$line")
done < <(parse_extensions "$@")
if [[ ${#extensions[@]} -gt 0 ]]; then
  run_extensions "doctor.sh" "${extensions[@]}"
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────

printf "\n\033[1m── Summary ──\033[0m\n"
printf "  \033[1;32m%d passed\033[0m" "$_doctor_pass"
[[ $_doctor_warn -gt 0 ]] && printf "  \033[1;33m%d warnings\033[0m" "$_doctor_warn"
[[ $_doctor_fail -gt 0 ]] && printf "  \033[1;31m%d failed\033[0m" "$_doctor_fail"
printf "\n"

if [[ $_doctor_fail -gt 0 ]]; then
  printf "\nRun \033[1m./bootstrap.sh\033[0m to fix failed checks.\n"
  exit 1
fi
