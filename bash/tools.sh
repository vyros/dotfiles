# Chargé depuis ~/.bashrc — configuration des outils CLI
# Compatible bash 4+

# ── zoxide (cd intelligent) ───────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# ── fzf (fuzzy finder — raccourcis shell) ────────────────────────────────────
# Ctrl+R : historique   Ctrl+T : fichiers   Alt+C : répertoires
if command -v fzf &>/dev/null; then
    if fzf --bash &>/dev/null 2>&1; then
        eval "$(fzf --bash)"
    elif [[ -f /usr/share/fzf/key-bindings.bash ]]; then
        source /usr/share/fzf/key-bindings.bash
    fi
fi

# ── bat (pager pour man) ──────────────────────────────────────────────────────
# Debian installe 'batcat', les autres distros 'bat'
if command -v bat &>/dev/null; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export GROFF_NO_SGR=1
elif command -v batcat &>/dev/null; then
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
    export GROFF_NO_SGR=1
fi

# ── eza (ls amélioré) ─────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
    alias ll='eza -l --icons --git'
    alias la='eza -la --icons --git'
    alias lt='eza --tree --icons -L 2'
    alias lta='eza --tree --icons -L 3'
fi

# ── lazygit ───────────────────────────────────────────────────────────────────
if command -v lazygit &>/dev/null; then
    alias lzg='lazygit'
fi

# ── uv (Python) ───────────────────────────────────────────────────────────────
if command -v uv &>/dev/null; then
    alias venv='uv venv'
    alias pipi='uv pip install'
fi

# ── Docker ───────────────────────────────────────────────────────────────────
if command -v docker &>/dev/null; then
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias dimg='docker images'
    alias dex='docker exec -it'
    alias dlf='docker logs -f'
    alias dprune='docker system prune -f'
    alias dcu='docker compose up -d'
    alias dcd='docker compose down'
    alias dcl='docker compose logs -f'
    alias dcr='docker compose restart'
fi

if command -v lazydocker &>/dev/null; then
    alias lzd='lazydocker'
fi

# ── mux (layouts tmux prédéfinis) ────────────────────────────────────────────
mux() {
    local sessions_dir="$HOME/.config/tmux/sessions"
    local name="" mode="auto"

    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -w|--window)  mode="window"  ;;
            -s|--session) mode="session" ;;
            *) name="$1" ;;
        esac
        shift
    done

    # Sans argument : lister les layouts
    if [[ -z "$name" ]]; then
        if compgen -G "$sessions_dir/*.sh" &>/dev/null; then
            echo "Layouts disponibles :"
            for f in "$sessions_dir"/*.sh; do
                echo "  mux $(basename "$f" .sh)"
            done
            echo
            echo "Options : -w (fenêtre) -s (session)"
        else
            echo "Aucun layout trouvé dans $sessions_dir"
        fi
        return 0
    fi

    local script="$sessions_dir/$name.sh"
    if [[ ! -f "$script" ]]; then
        echo "Layout '$name' introuvable." >&2
        mux
        return 1
    fi

    # Auto-détection : fenêtre si déjà dans tmux, session sinon
    if [[ "$mode" == "auto" ]]; then
        [[ -n "${TMUX:-}" ]] && mode="window" || mode="session"
    fi

    MUX_WINDOW=$([[ "$mode" == "window" ]] && echo 1 || echo 0) bash "$script"
}
