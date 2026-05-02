#!/usr/bin/env bash
# Layout Kubernetes : k9s (gauche) | shell (droite)
#
# +----------------------+---------------------+
# |                      |                     |
# |        k9s           |        shell        |
# |                      |                     |
# +----------------------+---------------------+

NAME="k8s"

_build_layout() {
    local p0="$1"
    tmux send-keys -t "$p0" "k9s" Enter
    local p1; p1=$(tmux split-window -h -t "$p0" -p 40 -P -F '#{pane_id}')
    tmux select-pane -t "$p0"
}

source "$(dirname "$0")/_lib.sh"
