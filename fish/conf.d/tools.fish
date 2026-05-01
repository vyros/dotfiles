# ── zoxide (cd intelligent) ───────────────────────────────────────────────────
if type -q zoxide
    zoxide init fish | source
end

# ── fzf (fuzzy finder — raccourcis shell) ────────────────────────────────────
# Ctrl+R : historique   Ctrl+T : fichiers   Alt+C : répertoires
if type -q fzf
    # --fish disponible depuis fzf 0.48 ; fallback pour Debian (0.38)
    if fzf --fish &>/dev/null 2>&1
        fzf --fish | source
    else if test -f /usr/share/fzf/key-bindings.fish
        source /usr/share/fzf/key-bindings.fish
    end
end

# ── bat (pager pour man) ──────────────────────────────────────────────────────
# Debian installe 'batcat', les autres distros 'bat'
if type -q bat
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -gx MANROFF_OPT "-c"
else if type -q batcat
    set -gx MANPAGER "sh -c 'col -bx | batcat -l man -p'"
    set -gx MANROFF_OPT "-c"
end

# ── eza (ls amélioré) ─────────────────────────────────────────────────────────
if type -q eza
    abbr -a ll  'eza -l --icons --git'
    abbr -a la  'eza -la --icons --git'
    abbr -a lt  'eza --tree --icons -L 2'
    abbr -a lta 'eza --tree --icons -L 3'
end

# ── lazygit ───────────────────────────────────────────────────────────────────
if type -q lazygit
    abbr -a lzg lazygit
end

# ── uv (Python) ───────────────────────────────────────────────────────────────
if type -q uv
    abbr -a venv 'uv venv'
    abbr -a pipi 'uv pip install'
end
