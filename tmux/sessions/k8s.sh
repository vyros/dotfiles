#!/usr/bin/env bash
# Layout Kubernetes : k9s (gauche) | shell (droite)
#
# +----------------------+---------------------+
# |                      |                     |
# |        k9s           |        shell        |
# |                      |                     |
# +----------------------+---------------------+

# shellcheck disable=SC2034  # NAME consommé par _lib.sh (sourcé en fin de fichier)
NAME="k8s"

_build_layout() {
    local p0="$1"
    tmux send-keys -t "$p0" "k9s" Enter
    tmux split-window -h -t "$p0" -p 40   # shell à droite
    tmux select-pane -t "$p0"
}

# shellcheck source=_lib.sh
source "$(dirname "$0")/_lib.sh"
