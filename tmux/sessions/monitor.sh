#!/usr/bin/env bash
# Layout Monitor : btop (gauche) | journalctl (haut droite) | dmesg (bas droite)
#
# +---------------------------+------------------+
# |                           |   journalctl     |
# |          btop             +------------------+
# |                           |     dmesg        |
# +---------------------------+------------------+

SESSION="monitor"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    [[ -z "$TMUX" ]] && tmux attach-session -t "$SESSION" \
                     || tmux switch-client  -t "$SESSION"
    exit 0
fi

tmux new-session -d -s "$SESSION"

# Pane 0 — btop à gauche
tmux send-keys -t "$SESSION:0.0" "btop" Enter

# Pane 1 — journalctl en haut à droite (40% de largeur)
tmux split-window -h -t "$SESSION:0.0" -p 40
tmux send-keys -t "$SESSION:0.1" "journalctl -f" Enter

# Pane 2 — dmesg en bas à droite (50% de hauteur)
tmux split-window -v -t "$SESSION:0.1" -p 50
tmux send-keys -t "$SESSION:0.2" "watch -n2 'dmesg | tail -20'" Enter

# Focus sur btop
tmux select-pane -t "$SESSION:0.0"

[[ -z "$TMUX" ]] && tmux attach-session -t "$SESSION" \
                 || tmux switch-client  -t "$SESSION"
