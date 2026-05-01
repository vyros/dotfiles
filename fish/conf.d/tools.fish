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
    set -gx GROFF_NO_SGR 1
else if type -q batcat
    set -gx MANPAGER "sh -c 'col -bx | batcat -l man -p'"
    set -gx GROFF_NO_SGR 1
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

# ── Kubernetes ───────────────────────────────────────────────────────────────
if type -q kubectl
    kubectl completion fish | source
    abbr -a k     kubectl
    abbr -a kgp   'kubectl get pods'
    abbr -a kgpa  'kubectl get pods -A'
    abbr -a kgs   'kubectl get svc'
    abbr -a kgd   'kubectl get deploy'
    abbr -a kgn   'kubectl get nodes'
    abbr -a kl    'kubectl logs -f'
    abbr -a kex   'kubectl exec -it'
    abbr -a kaf   'kubectl apply -f'
    abbr -a kdf   'kubectl delete -f'
    abbr -a kdp   'kubectl describe pod'
end

if type -q kubectx; abbr -a kctx kubectx; end
if type -q kubens;  abbr -a kns  kubens;  end
if type -q stern;   abbr -a st   stern;   end

# ── Docker ───────────────────────────────────────────────────────────────────
if type -q docker
    abbr -a dps    'docker ps'
    abbr -a dpsa   'docker ps -a'
    abbr -a dimg   'docker images'
    abbr -a dex    'docker exec -it'
    abbr -a dlf    'docker logs -f'
    abbr -a dprune 'docker system prune -f'
    abbr -a dcu    'docker compose up -d'
    abbr -a dcd    'docker compose down'
    abbr -a dcl    'docker compose logs -f'
    abbr -a dcr    'docker compose restart'
end

if type -q lazydocker
    abbr -a lzd lazydocker
end

# ── mux (layouts tmux prédéfinis) ────────────────────────────────────────────
function mux --description "Lance un layout tmux prédéfini"
    set sessions_dir "$HOME/.config/tmux/sessions"

    # Sans argument : lister les layouts
    if test (count $argv) -eq 0
        if test -d "$sessions_dir"
            echo "Layouts disponibles :"
            for f in $sessions_dir/*.sh
                echo "  mux "(basename $f .sh)
            end
            echo
            echo "Options : -w (fenêtre) -s (session)"
        else
            echo "Aucun layout trouvé dans $sessions_dir"
        end
        return 0
    end

    # Parser les arguments
    set name ""
    set mode "auto"  # auto | window | session
    for arg in $argv
        switch $arg
            case -w --window;  set mode "window"
            case -s --session; set mode "session"
            case '*';          set name $arg
        end
    end

    if test -z "$name"
        echo "Usage : mux <layout> [-w|-s]" >&2; return 1
    end

    set script "$sessions_dir/$name.sh"
    if not test -f "$script"
        echo "Layout '$name' introuvable." >&2
        mux
        return 1
    end

    # Auto-détection : fenêtre si déjà dans tmux, session sinon
    if test "$mode" = auto
        if set -q TMUX
            set mode "window"
        else
            set mode "session"
        end
    end

    if test "$mode" = window
        MUX_WINDOW=1 bash "$script"
    else
        MUX_WINDOW=0 bash "$script"
    end
end
