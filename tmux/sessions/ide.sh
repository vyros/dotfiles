#!/usr/bin/env bash
# Layout IDE : vim (gauche) | btop (haut droite) | lazygit (bas droite)
#
# +---------------------------+------------------+
# |                           |      btop        |
# |           vim             +------------------+
# |                           |    lazygit       |
# +---------------------------+------------------+

SESSION="ide"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    [[ -z "$TMUX" ]] && tmux attach-session -t "$SESSION" \
                     || tmux switch-client  -t "$SESSION"
    exit 0
fi

tmux new-session -d -s "$SESSION"

# Pane 0 — vim à gauche
tmux send-keys -t "$SESSION:0.0" "vim" Enter

# Pane 1 — btop en haut à droite (40% de largeur)
tmux split-window -h -t "$SESSION:0.0" -p 40
tmux send-keys -t "$SESSION:0.1" "btop" Enter

# Pane 2 — lazygit en bas à droite (50% de hauteur)
tmux split-window -v -t "$SESSION:0.1" -p 50
tmux send-keys -t "$SESSION:0.2" "lazygit" Enter

# Focus sur vim
tmux select-pane -t "$SESSION:0.0"

[[ -z "$TMUX" ]] && tmux attach-session -t "$SESSION" \
                 || tmux switch-client  -t "$SESSION"
