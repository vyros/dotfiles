#!/usr/bin/env bash
# Layout IDE : btop (haut gauche) | lazygit (bas gauche) | vim (droite)
#
# +------------------+---------------------------+
# |      btop        |                           |
# +------------------+           vim             |
# |    lazygit       |                           |
# +------------------+---------------------------+

# shellcheck disable=SC2034  # NAME consommé par _lib.sh (sourcé en fin de fichier)
NAME="ide"

_build_layout() {
    local p0="$1"
    tmux send-keys -t "$p0" "btop" Enter
    local p1; p1=$(tmux split-window -h -t "$p0" -p 60 -P -F '#{pane_id}')
    tmux send-keys -t "$p1" "vim" Enter
    local p2; p2=$(tmux split-window -v -t "$p0" -p 50 -P -F '#{pane_id}')
    tmux send-keys -t "$p2" "lazygit" Enter
    tmux select-pane -t "$p1"
}

# shellcheck source=_lib.sh
source "$(dirname "$0")/_lib.sh"
