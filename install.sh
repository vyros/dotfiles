#!/usr/bin/env bash
# Installe la config en créant des symlinks depuis ~ vers ce repo.
# Usage : bash install.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()    { echo "[+] $*"; }
warning() { echo "[!] $*"; }

symlink() {
    local src="$1" dst="$2"
    if [[ -e $dst && ! -L $dst ]]; then
        warning "Sauvegarde de $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sf "$src" "$dst"
    info "$dst → $src"
}

# ── Vim ───────────────────────────────────────────────────────────────────────
info "Configuration Vim..."
mkdir -p "$HOME/.vim"
symlink "$DOTFILES/vim/vimrc"     "$HOME/.vimrc"
symlink "$DOTFILES/vim/setup.sh"  "$HOME/.vim/setup.sh"
symlink "$DOTFILES/vim/README.md" "$HOME/.vim/README.md"

# ── tmux ──────────────────────────────────────────────────────────────────────
info "Configuration tmux..."
symlink "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
symlink "$DOTFILES/tmux/README.md" "$HOME/.tmux-README.md"

# TPM (Tmux Plugin Manager)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    info "Bootstrap de TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# ── Git ───────────────────────────────────────────────────────────────────────
info "Configuration git..."
git config --global include.path "$DOTFILES/git/gitconfig"

# ── Dépendances + plugins ─────────────────────────────────────────────────────
read -rp "[?] Installer les dépendances et les plugins ? [o/N] " answer
if [[ ${answer,,} == "o" ]]; then
    bash "$DOTFILES/vim/setup.sh"
fi

info "Terminé. Dans tmux, appuie sur C-a I pour installer les plugins tmux."
