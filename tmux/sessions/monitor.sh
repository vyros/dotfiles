#!/usr/bin/env bash
# Layout Monitor : btop (gauche) | journalctl (haut droite) | noyau (bas droite)
#
# +---------------------------+------------------+
# |                           |   journalctl     |
# |          btop             +------------------+
# |                           | journalctl -k    |
# +---------------------------+------------------+

# shellcheck disable=SC2034  # NAME consommé par _lib.sh (sourcé en fin de fichier)
NAME="monitor"

_build_layout() {
    local p0="$1"
    tmux send-keys -t "$p0" "btop" Enter
    local p1; p1=$(tmux split-window -h -t "$p0" -l 40% -P -F '#{pane_id}')
    tmux send-keys -t "$p1" "journalctl -f" Enter
    local p2; p2=$(tmux split-window -v -t "$p1" -l 50% -P -F '#{pane_id}')
    # journalctl -k plutôt que dmesg : kernel.dmesg_restrict=1 par défaut sur
    # Arch comme Ubuntu → dmesg est réservé à root
    tmux send-keys -t "$p2" "journalctl -kf" Enter
    tmux select-pane -t "$p0"
}

# shellcheck source=_lib.sh
source "$(dirname "$0")/_lib.sh"
