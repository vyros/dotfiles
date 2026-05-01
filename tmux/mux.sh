#!/usr/bin/env bash
# Dispatcher appelé par l'alias tmux : C-a : mux <layout>
NAME="${1:-}"
SESSIONS_DIR="$HOME/.config/tmux/sessions"

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
