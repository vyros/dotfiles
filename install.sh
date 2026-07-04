#!/usr/bin/env bash
# Installe la config en créant des symlinks depuis ~ vers ce repo.
# Usage : bash install.sh [--link]

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Options ───────────────────────────────────────────────────────────────────
LINK_ALL=0
for arg in "$@"; do
    case "$arg" in
        --link) LINK_ALL=1 ;;
        -h|--help)
            echo "Usage : bash install.sh [--link]"
            echo "  --link   (re)pose tous les symlinks sans menu ni dépendances"
            exit 0 ;;
        *) echo "Option inconnue : $arg (voir --help)" >&2; exit 1 ;;
    esac
done

info()    { echo "[+] $*"; }
warning() { echo "[!] $*"; }
header()  { echo; echo "── $* ──────────────────────────────────────────"; }

symlink() {
    local src="$1" dst="$2"
    if [[ -e $dst && ! -L $dst ]]; then
        warning "Sauvegarde de $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sfn "$src" "$dst"          # -n : remplace un symlink de répertoire au lieu d'écrire dedans
    info "$dst → $src"
}

# Demande o/n, retourne 0 si oui
ask() {
    local prompt="$1" default="${2:-o}"
    local hint; [[ $default == o ]] && hint="[O/n]" || hint="[o/N]"
    read -rp "    $prompt $hint " answer
    answer="${answer:-$default}"
    [[ ${answer,,} == o ]]
}

# Détecte le gestionnaire de paquets système. Écho : arch | debian | (vide).
detect_pm() {
    if command -v pacman &>/dev/null; then
        echo arch
    elif command -v apt-get &>/dev/null; then
        echo debian
    fi
}

# Installe des paquets système (mêmes noms sur Arch et Debian/Ubuntu ici).
# N'interrompt pas le script en cas d'échec (réseau, sudo refusé) : avertit.
# pacman -S sans -y volontaire : évite un partial upgrade ; pour une machine à
# jour c'est suffisant, sinon lancer l'étape « Dépendances » (pacman -Syu).
pkg_install() {
    case "$(detect_pm)" in
        arch)
            sudo pacman -S --needed --noconfirm "$@" \
                || warning "Échec de l'installation : $*" ;;
        debian)
            sudo apt-get update -qq \
                && sudo apt-get install -y --no-install-recommends "$@" \
                || warning "Échec de l'installation : $*" ;;
        *)
            warning "Gestionnaire de paquets non reconnu (ni pacman ni apt) — installe à la main : $*" ;;
    esac
}

# ── Sélection des composants ──────────────────────────────────────────────────
do_vim=false
do_tmux=false
do_git=false
do_shell=false
do_bat=false
do_deps=false

CURRENT_SHELL=$(basename "${SHELL:-bash}")

if [[ $LINK_ALL == 1 ]]; then
    # Mode non-interactif : (re)pose tous les symlinks, sans dépendances
    do_vim=true; do_tmux=true; do_git=true; do_shell=true; do_bat=true
    info "Mode --link : (re)pose tous les symlinks (sans installer de dépendances)."
else
    header "Dotfiles — sélection des composants"
    echo
    ask "Vim"                                    && do_vim=true   || true
    ask "tmux"                                   && do_tmux=true  || true
    ask "Git"                                    && do_git=true   || true
    ask "Shell ($CURRENT_SHELL)"                 && do_shell=true || true
    ask "Bat"                                    && do_bat=true   || true
    ask "Dépendances (LSP, plugins vim/tmux)" n  && do_deps=true  || true

    echo
    echo "  Composants sélectionnés :"
    $do_vim   && echo "    • Vim"               || true
    $do_tmux  && echo "    • tmux"              || true
    $do_git   && echo "    • Git"               || true
    $do_shell && echo "    • Shell ($CURRENT_SHELL)" || true
    $do_bat   && echo "    • Bat"               || true
    $do_deps  && echo "    • Dépendances"       || true
    echo

    if ! $do_vim && ! $do_tmux && ! $do_git && ! $do_shell && ! $do_bat && ! $do_deps; then
        info "Rien à installer."
        exit 0
    fi

    ask "Confirmer l'installation ?" || exit 0
fi

# ── Vim ───────────────────────────────────────────────────────────────────────
if $do_vim; then
    header "Vim"
    mkdir -p "$HOME/.vim"
    symlink "$DOTFILES/vim/vimrc"     "$HOME/.vimrc"
    symlink "$DOTFILES/vim/setup.sh"  "$HOME/.vim/setup.sh"
    symlink "$DOTFILES/vim/README.md" "$HOME/.vim/README.md"
fi

# ── tmux ──────────────────────────────────────────────────────────────────────
if $do_tmux; then
    header "tmux"
    symlink "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
    symlink "$DOTFILES/tmux/README.md" "$HOME/.tmux-README.md"
    mkdir -p "$HOME/.config/tmux"
    symlink "$DOTFILES/tmux/sessions" "$HOME/.config/tmux/sessions"
    symlink "$DOTFILES/tmux/mux.sh"   "$HOME/.config/tmux/mux.sh"
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        info "Bootstrap de TPM..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
    # Presse-papier système du mode copie (touche « y » / souris). Sans
    # wl-clipboard (Wayland) ou xclip (X11), la sélection ne quitte pas tmux.
    # Ignoré en --link (contrat « sans dépendances ») ; noms partagés avec
    # vim/setup.sh, source de vérité pour la CI « paquets ».
    if [[ $LINK_ALL == 0 ]]; then
        if command -v wl-copy &>/dev/null || command -v xclip &>/dev/null; then
            info "Presse-papier système déjà présent (wl-copy/xclip)."
        elif ask "Installer wl-clipboard + xclip (presse-papier tmux) ?"; then
            pkg_install wl-clipboard xclip
        fi
    fi
fi

# ── Git ───────────────────────────────────────────────────────────────────────
if $do_git; then
    header "Git"
    # --add (et non set) pour ne pas écraser d'autres include.path éventuels ;
    # guard grep pour éviter les doublons si on relance le script.
    if git config --global --get-all include.path 2>/dev/null | grep -qxF "$DOTFILES/git/gitconfig"; then
        info "$HOME/.gitconfig inclut déjà $DOTFILES/git/gitconfig"
    else
        git config --global --add include.path "$DOTFILES/git/gitconfig"
        info "$HOME/.gitconfig ← include $DOTFILES/git/gitconfig"
    fi
    # delta : pager de diff du gitconfig (rendu side-by-side/gruvbox). Non
    # bloquant — le gitconfig retombe sur less sans lui. Paquet « git-delta »
    # (fournit la commande « delta ») : présent sur Arch, Ubuntu 24.04+ et
    # Debian 13+ ; absent de Debian 12 (bookworm), où il reste couvert par
    # l'étape « Dépendances » (setup.sh, .deb GitHub).
    if [[ $LINK_ALL == 0 ]]; then
        if command -v delta >/dev/null 2>&1; then
            info "delta déjà présent."
        elif ask "Installer delta (pager de diff git) ?"; then
            pkg_install git-delta
        fi
    fi
fi

# ── Shell ─────────────────────────────────────────────────────────────────────
if $do_shell; then
    header "Shell ($CURRENT_SHELL)"
    case "$CURRENT_SHELL" in
        fish)
            mkdir -p "$HOME/.config/fish/conf.d"
            symlink "$DOTFILES/fish/conf.d/tools.fish" "$HOME/.config/fish/conf.d/tools.fish"
            ;;
        bash)
            local_line="source $DOTFILES/bash/tools.sh"
            if ! grep -qF "$local_line" "$HOME/.bashrc" 2>/dev/null; then
                echo "$local_line" >> "$HOME/.bashrc"
                info "Ajouté à ~/.bashrc"
            else
                info "$HOME/.bashrc déjà configuré"
            fi
            ;;
        *)
            warning "Shell '$CURRENT_SHELL' non supporté (fish et bash uniquement)"
            ;;
    esac
fi

# ── Bat ───────────────────────────────────────────────────────────────────────
if $do_bat; then
    header "Bat"
    mkdir -p "$HOME/.config/bat"
    symlink "$DOTFILES/bat/config" "$HOME/.config/bat/config"
fi

# ── Dépendances ───────────────────────────────────────────────────────────────
if $do_deps; then
    header "Dépendances"
    bash "$DOTFILES/vim/setup.sh"
fi

# ── Fin ───────────────────────────────────────────────────────────────────────
echo
info "Terminé."
$do_tmux && info "Dans tmux : C-a I pour installer les plugins." || true
$do_vim  && info "Dans vim  : :PlugInstall si les plugins ne sont pas installés." || true
