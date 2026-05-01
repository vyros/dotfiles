#!/usr/bin/env bash
NAME="${1:-}"
SESSIONS_DIR="$HOME/.config/tmux/sessions"

# Génère un command-alias sans argument par layout (indices 100+).
# Appelé par run-shell au rechargement de la config tmux.
# Permet d'utiliser directement : C-a : ide
if [[ "$NAME" == "--init" ]]; then
    idx=100
    for script in "$SESSIONS_DIR"/*.sh; do
        [[ -f "$script" ]] || continue
        layout=$(basename "$script" .sh)
        tmux set-option -g "command-alias[$idx]" \
            "${layout}=run-shell 'MUX_WINDOW=1 bash $script'"
        ((idx++))
    done
    exit 0
fi

if [[ -z "$NAME" ]]; then
    layouts=$(ls "$SESSIONS_DIR"/*.sh 2>/dev/null \
        | xargs -n1 basename | sed 's/\.sh//' | tr '\n' ' ')
    tmux display-message "Layouts disponibles : ${layouts:-aucun}"
    exit 0
fi

SCRIPT="$SESSIONS_DIR/$NAME.sh"
if [[ ! -f "$SCRIPT" ]]; then
    tmux display-message "Layout '$NAME' introuvable dans $SESSIONS_DIR"
    exit 1
fi

MUX_WINDOW=1 bash "$SCRIPT"
