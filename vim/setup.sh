#!/usr/bin/env bash
# Installe les dépendances et les serveurs LSP pour la config Vim IDE.
# Usage : bash setup.sh
# Testé sur : Arch Linux, Debian 12+

set -euo pipefail

# ── Détection du gestionnaire de paquets ─────────────────────────────────────
if command -v pacman &>/dev/null; then
    PM=arch
elif command -v apt-get &>/dev/null; then
    PM=debian
else
    echo "Gestionnaire de paquets non supporté (ni pacman ni apt)." >&2
    exit 1
fi

info()    { echo "[+] $*"; }
warning() { echo "[!] $*"; }

# ── Paquets système ───────────────────────────────────────────────────────────
info "Installation des paquets système..."

if [[ $PM == arch ]]; then
    sudo pacman -Syu --needed --noconfirm \
        ripgrep glow nodejs npm pipx curl \
        clang                          `# clangd` \
        rustup \
        fzf git-delta zoxide ruff lazygit bat fd \
        jq direnv eza btop

elif [[ $PM == debian ]]; then
    sudo apt-get update -qq
    sudo apt-get install -y --no-install-recommends \
        ripgrep nodejs npm pipx curl \
        clangd \
        fzf bat fd-find jq direnv btop

    # eza, delta, zoxide, lazygit — non disponibles dans apt, via GitHub
    for tool in eza delta zoxide lazygit; do
        if ! command -v $tool &>/dev/null; then
            info "$tool non disponible via apt — installer manuellement (voir GitHub)"
        fi
    done

    # glow — non disponible dans les dépôts Debian, installation via .deb GitHub
    if ! command -v glow &>/dev/null; then
        info "Installation de glow depuis GitHub..."
        GLOW_VER=$(curl -s https://api.github.com/repos/charmbracelet/glow/releases/latest \
            | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
        ARCH=$(dpkg --print-architecture)
        curl -sLo /tmp/glow.deb \
            "https://github.com/charmbracelet/glow/releases/latest/download/glow_${GLOW_VER}_${ARCH}.deb"
        sudo dpkg -i /tmp/glow.deb
        rm /tmp/glow.deb
    fi

    # rust-analyzer via rustup
    if ! command -v rustup &>/dev/null; then
        info "Installation de rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
fi

# ── rust-analyzer ─────────────────────────────────────────────────────────────
if command -v rustup &>/dev/null; then
    info "Installation de rust-analyzer..."
    rustup component add rust-analyzer 2>/dev/null || true
fi

# ── LSP via npm ───────────────────────────────────────────────────────────────
info "Installation des serveurs LSP npm..."
npm install -g \
    dockerfile-language-server-nodejs \
    @microsoft/compose-language-service \
    --prefix "$HOME/.local"

# ── LSP via pipx ─────────────────────────────────────────────────────────────
info "Installation des serveurs LSP Python..."
pipx install python-lsp-server 2>/dev/null || pipx upgrade python-lsp-server
pipx install pyright            2>/dev/null || pipx upgrade pyright

# ── vim-plug ──────────────────────────────────────────────────────────────────
PLUG="$HOME/.vim/autoload/plug.vim"
if [[ ! -f $PLUG ]]; then
    info "Bootstrap de vim-plug..."
    curl -fLo "$PLUG" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# ── Plugins Vim ───────────────────────────────────────────────────────────────
if [[ -f $HOME/.vimrc ]]; then
    info "Installation des plugins Vim..."
    vim -es -u "$HOME/.vimrc" +PlugInstall +qall
else
    warning "~/.vimrc introuvable — copie-le avant de lancer ce script."
fi

info "Terminé. Lance vim pour vérifier."
