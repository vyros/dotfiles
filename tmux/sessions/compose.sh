#!/usr/bin/env bash
# Layout Docker/Compose : lazydocker (gauche) | shell (droite)
#
# +----------------------+---------------------+
# |                      |                     |
# |     lazydocker       |        shell        |
# |                      |                     |
# +----------------------+---------------------+

# shellcheck disable=SC2034  # NAME consommé par _lib.sh (sourcé en fin de fichier)
NAME="compose"

_build_layout() {
    local p0="$1"
    tmux send-keys -t "$p0" "lazydocker" Enter
    local p1; p1=$(tmux split-window -h -t "$p0" -l 45% -P -F '#{pane_id}')
    tmux select-pane -t "$p1"
}

# shellcheck source=_lib.sh
source "$(dirname "$0")/_lib.sh"
