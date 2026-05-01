# Chargé depuis ~/.bashrc — configuration des outils CLI
# Compatible bash 4+

# ── zoxide (cd intelligent) ───────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# ── fzf (fuzzy finder — raccourcis shell) ────────────────────────────────────
# Ctrl+R : historique   Ctrl+T : fichiers   Alt+C : répertoires
if command -v fzf &>/dev/null; then
    if fzf --bash &>/dev/null 2>&1; then
        eval "$(fzf --bash)"
    elif [[ -f /usr/share/fzf/key-bindings.bash ]]; then
        source /usr/share/fzf/key-bindings.bash
    fi
fi

# ── bat (pager pour man) ──────────────────────────────────────────────────────
# Debian installe 'batcat', les autres distros 'bat'
if command -v bat &>/dev/null; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFF_OPT="-c"
elif command -v batcat &>/dev/null; then
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
    export MANROFF_OPT="-c"
fi

# ── eza (ls amélioré) ─────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
    alias ll='eza -l --icons --git'
    alias la='eza -la --icons --git'
    alias lt='eza --tree --icons -L 2'
    alias lta='eza --tree --icons -L 3'
fi

# ── lazygit ───────────────────────────────────────────────────────────────────
if command -v lazygit &>/dev/null; then
    alias lzg='lazygit'
fi

# ── uv (Python) ───────────────────────────────────────────────────────────────
if command -v uv &>/dev/null; then
    alias venv='uv venv'
    alias pipi='uv pip install'
fi
