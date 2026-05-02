#!/usr/bin/env bash
# Boilerplate partagé par tous les layouts mux.
# À sourcer après avoir défini NAME et _build_layout().

if [[ "${MUX_WINDOW:-0}" == "1" ]]; then
    p0=$(tmux new-window -P -F '#{pane_id}' -n "$NAME")
    _build_layout "$p0"
else
    if tmux has-session -t "$NAME" 2>/dev/null; then
        [[ -z "$TMUX" ]] && tmux attach-session -t "$NAME" \
                         || tmux switch-client  -t "$NAME"
        exit 0
    fi
    tmux new-session -d -s "$NAME"
    p0=$(tmux display-message -t "$NAME" -p '#{pane_id}')
    _build_layout "$p0"
    [[ -z "$TMUX" ]] && tmux attach-session -t "$NAME" \
                     || tmux switch-client  -t "$NAME"
fi
