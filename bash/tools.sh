# shellcheck shell=bash
# Chargé depuis ~/.bashrc — configuration des outils CLI
# Compatible bash 4+

# ── PATH — binaires installés par setup.sh ────────────────────────────────────
# ~/.local/bin : binaires GitHub, pipx, uv, LSP npm ; ~/.cargo/bin : rustup.
# Arch ne les ajoute pas d'office, Ubuntu seulement au login (via ~/.profile,
# et uniquement si le répertoire existait déjà à ce moment-là).
for _dir in "$HOME/.local/bin" "$HOME/.cargo/bin"; do
    if [[ -d $_dir && ":$PATH:" != *":$_dir:"* ]]; then
        PATH="$_dir:$PATH"
    fi
done
unset _dir
export PATH

# ── zoxide (cd intelligent) ───────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# ── direnv (variables d'environnement par répertoire) ─────────────────────────
if command -v direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi

# ── fzf (fuzzy finder — raccourcis shell) ────────────────────────────────────
# Ctrl+R : historique   Ctrl+T : fichiers   Alt+C : répertoires
# --bash disponible depuis fzf 0.48 ; sinon fichiers fournis par la distro
if command -v fzf &>/dev/null; then
    if fzf --bash &>/dev/null; then
        eval "$(fzf --bash)"
    elif [[ -f /usr/share/fzf/key-bindings.bash ]]; then                  # Arch
        source /usr/share/fzf/key-bindings.bash
    elif [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]]; then     # Debian/Ubuntu
        source /usr/share/doc/fzf/examples/key-bindings.bash
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

# ── yazi (file manager — y pour changer de répertoire à la sortie) ───────────
if command -v yazi &>/dev/null; then
    y() {
        local tmp
        tmp=$(mktemp -t "yazi-cwd.XXXXX")
        yazi "$@" --cwd-file="$tmp"
        if cwd=$(cat -- "$tmp") && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd" || return
        fi
        rm -f -- "$tmp"
    }
fi

# ── Kubernetes ───────────────────────────────────────────────────────────────
if command -v kubectl &>/dev/null; then
    # shellcheck disable=SC1090  # process substitution, rien à suivre
    source <(kubectl completion bash)
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgpa='kubectl get pods -A'
    alias kgs='kubectl get svc'
    alias kgd='kubectl get deploy'
    alias kgn='kubectl get nodes'
    alias kl='kubectl logs -f'
    alias kex='kubectl exec -it'
    alias kaf='kubectl apply -f'
    alias kdf='kubectl delete -f'
    alias kdp='kubectl describe pod'
fi

command -v kubectx &>/dev/null && alias kctx='kubectx'
command -v kubens  &>/dev/null && alias kns='kubens'
command -v stern   &>/dev/null && alias st='stern'

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
# shellcheck disable=SC2120  # appelée par l'utilisateur, avec ou sans argument
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
                [[ "$(basename "$f")" == _* ]] && continue
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
