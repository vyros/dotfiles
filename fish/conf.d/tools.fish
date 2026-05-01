# ── zoxide (cd intelligent) ───────────────────────────────────────────────────
zoxide init fish | source

# ── fzf (fuzzy finder — raccourcis shell) ────────────────────────────────────
# Ctrl+R : historique   Ctrl+T : fichiers   Alt+C : répertoires
fzf --fish | source

# ── bat (pager pour man) ──────────────────────────────────────────────────────
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx MANROFF_OPT "-c"

# ── eza (ls amélioré) ─────────────────────────────────────────────────────────
abbr -a ll  'eza -l --icons --git'
abbr -a la  'eza -la --icons --git'
abbr -a lt  'eza --tree --icons -L 2'
abbr -a lta 'eza --tree --icons -L 3'

# ── lazygit ───────────────────────────────────────────────────────────────────
abbr -a lzg lazygit

# ── uv (Python) ───────────────────────────────────────────────────────────────
abbr -a venv 'uv venv'
abbr -a pipi 'uv pip install'
