#!/usr/bin/env bash
# Layout IDE : vim (gauche) | btop (haut droite) | lazygit (bas droite)
#
# +---------------------------+------------------+
# |                           |      btop        |
# |           vim             +------------------+
# |                           |    lazygit       |
# +---------------------------+------------------+

NAME="ide"

_build_layout() {
    local p0="$1"
    tmux send-keys -t "$p0" "vim" Enter
    local p1; p1=$(tmux split-window -h -t "$p0" -p 40 -P -F '#{pane_id}')
    tmux send-keys -t "$p1" "btop" Enter
    local p2; p2=$(tmux split-window -v -t "$p1" -p 50 -P -F '#{pane_id}')
    tmux send-keys -t "$p2" "lazygit" Enter
    tmux select-pane -t "$p0"
}

if [[ "${MUX_WINDOW:-0}" == "1" ]]; then
    # ── Nouvelle fenêtre dans la session courante ─────────────────────────────
    p0=$(tmux new-window -P -F '#{pane_id}' -n "$NAME")
    _build_layout "$p0"
else
    # ── Nouvelle session ──────────────────────────────────────────────────────
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
