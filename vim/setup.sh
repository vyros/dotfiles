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

# Installe un binaire depuis une release GitHub (tar.gz ou .deb)
# Usage : github_install <owner/repo> <grep_pattern> <binaire> [<deb|bin>]
github_install() {
    local repo="$1" pattern="$2" binary="$3" kind="${4:-deb}"
    if command -v "$binary" &>/dev/null; then
        info "$binary déjà installé"
        return
    fi
    info "Installation de $binary depuis GitHub ($repo)..."
    local url
    url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" \
        | grep "browser_download_url" | grep "$pattern" | head -1 | cut -d'"' -f4)
    if [[ -z $url ]]; then
        warning "$binary : asset introuvable (pattern: $pattern)" ; return
    fi
    if [[ $kind == deb ]]; then
        curl -sLo /tmp/_pkg.deb "$url"
        sudo dpkg -i /tmp/_pkg.deb
        rm /tmp/_pkg.deb
    else
        # binaire dans une archive tar.gz
        curl -sLo /tmp/_pkg.tar.gz "$url"
        tar -xzf /tmp/_pkg.tar.gz -C /tmp "$binary" 2>/dev/null \
            || tar -xzf /tmp/_pkg.tar.gz -C /tmp --wildcards "*/$binary" 2>/dev/null \
            || tar -xzf /tmp/_pkg.tar.gz -C /tmp
        install -m755 /tmp/"$binary" "$HOME/.local/bin/$binary"
        rm -f /tmp/_pkg.tar.gz /tmp/"$binary"
    fi
}

# ── Paquets système ───────────────────────────────────────────────────────────
info "Installation des paquets système..."

if [[ $PM == arch ]]; then
    sudo pacman -Syu --needed --noconfirm \
        ripgrep glow nodejs npm pipx curl \
        clang                          `# clangd` \
        rustup \
        fzf git-delta zoxide ruff lazygit bat fd \
        jq direnv eza btop \
        ttf-jetbrains-mono-nerd

elif [[ $PM == debian ]]; then
    sudo apt-get update -qq
    sudo apt-get install -y --no-install-recommends \
        ripgrep nodejs npm pipx curl \
        clangd \
        fzf bat fd-find jq direnv btop

    mkdir -p "$HOME/.local/bin"

    # bat s'installe comme 'batcat' sur Debian — créer un alias
    if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
        ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
        info "Symlink bat → batcat créé"
    fi

    # fd-find s'installe comme 'fdfind' sur Debian — créer un alias
    if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
        info "Symlink fd → fdfind créé"
    fi

    # glow
    if ! command -v glow &>/dev/null; then
        ARCH=$(dpkg --print-architecture)
        github_install "charmbracelet/glow" "linux_${ARCH}.deb" "glow"
    fi

    # eza
    github_install "eza-community/eza" "eza_x86_64-unknown-linux-musl" "eza" bin

    # delta
    github_install "dandavison/delta" "amd64.deb" "delta"

    # zoxide
    if ! command -v zoxide &>/dev/null; then
        info "Installation de zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    # lazygit
    github_install "jesseduffield/lazygit" "Linux_x86_64.tar.gz" "lazygit" bin

    # ruff (via pipx, disponible partout)
    if ! command -v ruff &>/dev/null; then
        pipx install ruff 2>/dev/null || pipx upgrade ruff
    fi

    # rustup
    if ! command -v rustup &>/dev/null; then
        info "Installation de rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    # JetBrains Mono Nerd Font
    if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
        info "Installation de JetBrainsMono Nerd Font..."
        _font_url=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" \
            | grep "browser_download_url" | grep "JetBrainsMono.tar.xz" | head -1 | cut -d'"' -f4)
        if [[ -n $_font_url ]]; then
            mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"
            curl -sLo /tmp/_JetBrainsMono.tar.xz "$_font_url"
            tar -xf /tmp/_JetBrainsMono.tar.xz -C "$HOME/.local/share/fonts/JetBrainsMono" '*.ttf' 2>/dev/null \
                || tar -xf /tmp/_JetBrainsMono.tar.xz -C "$HOME/.local/share/fonts/JetBrainsMono"
            rm /tmp/_JetBrainsMono.tar.xz
            fc-cache -f "$HOME/.local/share/fonts"
            info "JetBrainsMono Nerd Font installée"
        else
            warning "Impossible de récupérer l'URL de JetBrainsMono Nerd Font"
        fi
    else
        info "JetBrainsMono Nerd Font déjà installée"
    fi
fi

# ── rust-analyzer ─────────────────────────────────────────────────────────────
if command -v rustup &>/dev/null; then
    info "Installation de rust-analyzer..."
    rustup component add rust-analyzer 2>/dev/null || true
fi

# ── uv (Python package manager) ───────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
    info "Installation de uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
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
info "Police : configure ton terminal pour utiliser 'JetBrainsMono Nerd Font' afin d'activer les icônes."
