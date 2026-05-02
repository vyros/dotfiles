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
    local p0="$1"
    tmux send-keys -t "$p0" "btop" Enter
    local p1; p1=$(tmux split-window -h -t "$p0" -p 40 -P -F '#{pane_id}')
    tmux send-keys -t "$p1" "journalctl -f" Enter
    local p2; p2=$(tmux split-window -v -t "$p1" -p 50 -P -F '#{pane_id}')
    tmux send-keys -t "$p2" "watch -n2 'dmesg | tail -20'" Enter
    tmux select-pane -t "$p0"
}

source "$(dirname "$0")/_lib.sh"
