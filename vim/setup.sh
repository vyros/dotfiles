#!/usr/bin/env bash
# Installe les dépendances et les serveurs LSP pour la config Vim IDE.
# Usage : bash setup.sh [--update] [--check]
# Testé sur : Arch Linux, Debian 12+ (x86_64 uniquement)

set -euo pipefail

# ── Options de ligne de commande ──────────────────────────────────────────────
FORCE_UPDATE=0
DO_CHECK=0
for arg in "$@"; do
    case "$arg" in
        --update) FORCE_UPDATE=1 ;;
        --check)  DO_CHECK=1 ;;
        -h|--help)
            echo "Usage : bash setup.sh [--update] [--check]"
            echo "  --update  réinstalle les binaires GitHub même s'ils sont déjà présents"
            echo "  --check   liste les outils présents/manquants puis quitte (n'installe rien)"
            exit 0 ;;
        *) echo "Option inconnue : $arg (voir --help)" >&2; exit 1 ;;
    esac
done

# ── Mode diagnostic (--check) : ne rien installer, juste lister ───────────────
if [[ $DO_CHECK == 1 ]]; then
    have() {  # have <label> <cmd…> : ✓ si l'une des commandes existe dans le PATH
        local label="$1"; shift
        local c
        for c in "$@"; do
            command -v "$c" &>/dev/null && { printf '  \033[32m✓\033[0m %s\n' "$label"; return; }
        done
        printf '  \033[31m✗\033[0m %s\n' "$label"
    }
    echo "Outils CLI :"
    have ripgrep rg;            have fzf fzf;        have delta delta
    have zoxide zoxide;         have uv uv;          have ruff ruff
    have lazygit lazygit;       have bat bat batcat
    have eza eza;               have fd fd fdfind;   have jq jq
    have direnv direnv;         have btop btop;      have yazi yazi
    have yq yq;                 have xh xh;          have dust dust
    have lazydocker lazydocker; have glow glow;      have presse-papier wl-copy xclip
    echo "Kubernetes :"
    have kubectl kubectl;  have k9s k9s;  have kubectx kubectx;  have kubens kubens;  have stern stern
    echo "Serveurs LSP :"
    have clangd clangd;                              have pylsp pylsp
    have pyright pyright-langserver;                 have rust-analyzer rust-analyzer
    have typescript-language-server typescript-language-server
    have gopls gopls;                                have lua-language-server lua-language-server
    have docker-langserver docker-langserver
    have docker-compose-langserver docker-compose-langserver
    echo "Runtime :"
    have node node;  have npm npm;  have pipx pipx;  have rustup rustup;  have vim vim
    exit 0
fi

# ── Vérification de l'architecture ────────────────────────────────────────────
# Les binaires téléchargés depuis GitHub (eza, delta, k9s, xh, dust, yazi…) sont
# en dur pour x86_64 ; les autres architectures ne sont pas (encore) supportées.
ARCH=$(uname -m)
if [[ $ARCH != x86_64 ]]; then
    echo "[!] Architecture '$ARCH' non supportée." >&2
    echo "    setup.sh installe des binaires x86_64 depuis GitHub ; sur ARM (aarch64)" >&2
    echo "    ou autre, les téléchargements échoueraient. Installe les outils à la main." >&2
    exit 1
fi

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
    if [[ $FORCE_UPDATE != 1 ]] && command -v "$binary" &>/dev/null; then
        info "$binary déjà installé"
        return
    fi
    info "Installation de $binary depuis GitHub ($repo)..."
    local url
    url=$(curl -fsS "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null \
        | grep "browser_download_url" | grep -E "$pattern" | head -1 | cut -d'"' -f4)
    if [[ -z $url ]]; then
        warning "$binary : asset introuvable (pattern: $pattern)" ; return
    fi

    local tmpd; tmpd=$(mktemp -d)
    if ! curl -fsSLo "$tmpd/pkg" "$url"; then
        warning "$binary : téléchargement échoué" ; rm -rf "$tmpd" ; return
    fi

    case "$kind" in
        deb)
            sudo dpkg -i "$tmpd/pkg" || warning "$binary : dpkg a échoué (dépendances ?)"
            ;;
        raw)
            install -m755 "$tmpd/pkg" "$HOME/.local/bin/$binary"
            ;;
        *)  # archive (tar.* ou .zip) de structure inconnue : on localise le binaire
            if [[ $url == *.zip ]]; then
                unzip -qo "$tmpd/pkg" -d "$tmpd" 2>/dev/null
            else
                tar -xf "$tmpd/pkg" -C "$tmpd" 2>/dev/null
            fi
            local found
            found=$(find "$tmpd" -type f -name "$binary" -perm -u+x -print -quit 2>/dev/null)
            [[ -z $found ]] && found=$(find "$tmpd" -type f -name "$binary" -print -quit 2>/dev/null)
            if [[ -n $found ]]; then
                install -m755 "$found" "$HOME/.local/bin/$binary"
            else
                warning "$binary introuvable dans l'archive"
            fi
            ;;
    esac
    rm -rf "$tmpd"
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
        xclip wl-clipboard            `# presse-papier tmux (X11 + Wayland)` \
        ttf-hack-nerd \
        kubectl k9s kubectx \
        go-yq yazi xh dust

    # stern non disponible dans les dépôts officiels
    github_install "stern/stern" "linux_amd64.tar.gz" "stern" bin

elif [[ $PM == debian ]]; then
    sudo apt-get update -qq
    sudo apt-get install -y --no-install-recommends \
        ripgrep nodejs npm pipx curl \
        clangd \
        fzf bat fd-find jq direnv btop \
        xclip wl-clipboard unzip

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

    # Kubernetes
    if ! command -v kubectl &>/dev/null; then
        info "Installation de kubectl..."
        _kube_ver=$(curl -sL https://dl.k8s.io/release/stable.txt)
        curl -sLo /tmp/kubectl "https://dl.k8s.io/release/${_kube_ver}/bin/linux/amd64/kubectl"
        install -m755 /tmp/kubectl "$HOME/.local/bin/kubectl"
        rm /tmp/kubectl
    fi
    github_install "derailed/k9s"    "k9s_Linux_amd64.tar.gz"  "k9s"      bin
    github_install "ahmetb/kubectx"  "kubectx.*linux_x86_64"   "kubectx"  bin
    github_install "ahmetb/kubectx"  "kubens.*linux_x86_64"    "kubens"   bin
    github_install "stern/stern"     "linux_amd64.tar.gz"      "stern"    bin

    # yq, yazi, xh, dust
    github_install "mikefarah/yq"    "yq_linux_amd64\""                      "yq"   raw
    github_install "sxyazi/yazi"     "yazi-x86_64-unknown-linux-musl.zip"    "yazi" bin
    github_install "ducaale/xh"      "x86_64-unknown-linux-musl.tar.gz"      "xh"   bin
    github_install "bootandy/dust"   "x86_64-unknown-linux-musl.tar.gz"      "dust" bin

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

    # Hack Nerd Font
    if ! fc-list | grep -qi "Hack Nerd"; then
        info "Installation de Hack Nerd Font..."
        _font_url=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" \
            | grep "browser_download_url" | grep "Hack.tar.xz" | head -1 | cut -d'"' -f4)
        if [[ -n $_font_url ]]; then
            mkdir -p "$HOME/.local/share/fonts/HackNerd"
            curl -sLo /tmp/_HackNerd.tar.xz "$_font_url"
            tar -xf /tmp/_HackNerd.tar.xz -C "$HOME/.local/share/fonts/HackNerd" '*.ttf' 2>/dev/null \
                || tar -xf /tmp/_HackNerd.tar.xz -C "$HOME/.local/share/fonts/HackNerd"
            rm /tmp/_HackNerd.tar.xz
            fc-cache -f "$HOME/.local/share/fonts"
            info "Hack Nerd Font installée"
        else
            warning "Impossible de récupérer l'URL de Hack Nerd Font"
        fi
    else
        info "Hack Nerd Font déjà installée"
    fi
fi

# ── lazydocker (TUI Docker — non disponible dans les dépôts officiels) ───────
github_install "jesseduffield/lazydocker" "Linux_x86_64.tar.gz" "lazydocker" bin

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
    warning "$HOME/.vimrc introuvable — copie-le avant de lancer ce script."
fi

info "Terminé. Lance vim pour vérifier."
info "Police : configure ton terminal pour utiliser 'Hack Nerd Font' afin d'activer les icônes."
