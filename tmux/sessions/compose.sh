#!/usr/bin/env bash
# Layout Docker/Compose : lazydocker (gauche) | shell (droite)
#
# +----------------------+---------------------+
# |                      |                     |
# |     lazydocker       |        shell        |
# |                      |                     |
# +----------------------+---------------------+

NAME="compose"

_build_layout() {
    local p0="$1"
    tmux send-keys -t "$p0" "lazydocker" Enter
    local p1; p1=$(tmux split-window -h -t "$p0" -p 45 -P -F '#{pane_id}')
    tmux select-pane -t "$p1"
}

source "$(dirname "$0")/_lib.sh"
