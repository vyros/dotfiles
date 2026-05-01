#!/usr/bin/env bash
# Layout Monitor : btop (gauche) | journalctl (haut droite) | dmesg (bas droite)
#
# +---------------------------+------------------+
# |                           |   journalctl     |
# |          btop             +------------------+
# |                           |     dmesg        |
# +---------------------------+------------------+

NAME="monitor"

_build_layout() {
    local t="$1"
    tmux send-keys      -t "${t}.0" "btop" Enter
    tmux split-window -h -t "${t}.0" -p 40
    tmux send-keys      -t "${t}.1" "journalctl -f" Enter
    tmux split-window -v -t "${t}.1" -p 50
    tmux send-keys      -t "${t}.2" "watch -n2 'dmesg | tail -20'" Enter
    tmux select-pane    -t "${t}.0"
}

if [[ "${MUX_WINDOW:-0}" == "1" ]]; then
    # ── Nouvelle fenêtre dans la session courante ─────────────────────────────
    W=$(tmux new-window -P -F '#{window_id}' -n "$NAME")
    _build_layout "$W"
else
    # ── Nouvelle session ──────────────────────────────────────────────────────
    if tmux has-session -t "$NAME" 2>/dev/null; then
        [[ -z "$TMUX" ]] && tmux attach-session -t "$NAME" \
                         || tmux switch-client  -t "$NAME"
        exit 0
    fi
    tmux new-session -d -s "$NAME"
    _build_layout "$NAME:0"
    [[ -z "$TMUX" ]] && tmux attach-session -t "$NAME" \
                     || tmux switch-client  -t "$NAME"
fi
