#!/usr/bin/env bash
# Layout Claude IDE : lazydocker+lazygit (gauche) | vim (centre) | claude+terminal (droite)
# Optimisé pour écran ultrawide (3 colonnes ~20% / ~45% / ~35%)
#
# +----------+---------------------------+------------------+
# |lazydocker|                           |   claude -c      |
# |          |          vim              |                  |
# +----------+                           +------------------+
# | lazygit  |                           |   terminal       |
# +----------+---------------------------+------------------+

# shellcheck disable=SC2034  # NAME consommé par _lib.sh (sourcé en fin de fichier)
NAME="clide"

_build_layout() {
    local p0="$1"
    tmux send-keys -t "$p0" "lazydocker" Enter
    local p1; p1=$(tmux split-window -h -t "$p0" -l 80% -P -F '#{pane_id}')
    local p2; p2=$(tmux split-window -h -t "$p1" -l 44% -P -F '#{pane_id}')
    tmux send-keys -t "$p1" "vim" Enter
    tmux send-keys -t "$p2" "claude -c" Enter
    local p3; p3=$(tmux split-window -v -t "$p0" -l 50% -P -F '#{pane_id}')
    tmux send-keys -t "$p3" "lazygit" Enter
    tmux split-window -v -t "$p2" -l 33%   # terminal sous claude
    tmux select-pane -t "$p1"
}

# shellcheck source=_lib.sh
source "$(dirname "$0")/_lib.sh"
