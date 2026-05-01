# dotfiles

Configuration personnelle pour un environnement de développement en ligne de commande.

## Composants

| Outil | Description |
|---|---|
| [Vim](vim/README.md) | Configuration IDE (LSP, fzf, bat preview, git, glow) |
| [tmux](tmux/README.md) | Multiplexeur de terminal (Gruvbox, sessions persistantes) |
| [Git](git/README.md) | Aliases et paramètres (delta pour les diffs) |
| Fish / Bash | Intégration zoxide, fzf, eza, lazygit, uv, Docker, Kubernetes |
| Bat | Thème Gruvbox, pager pour man |

## Outils inclus

| Outil | Rôle |
|---|---|
| `fzf` | Fuzzy finder — fichiers, historique shell, répertoires |
| `delta` | Pager git avec syntax highlighting |
| `zoxide` | `cd` intelligent par fréquence (`z projet`) |
| `uv` | Gestionnaire Python ultra-rapide (pip + venv + pyenv) |
| `ruff` | Linter/formateur Python |
| `lazygit` | TUI git interactif |
| `bat` | `cat` avec syntax highlighting et thème Gruvbox |
| `eza` | `ls` moderne avec icônes et infos git |
| `fd` | `find` rapide, utilisé par fzf et Vim |
| `jq` | Processeur JSON |
| `direnv` | Variables d'environnement par répertoire |
| `btop` | Moniteur système |
| `lazydocker` | TUI Docker interactif (containers, images, logs, stats) |
| `k9s` | TUI Kubernetes interactif (pods, services, logs, exec) |
| `kubectx` / `kubens` | Basculer entre contextes et namespaces K8s |
| `stern` | Tail de logs multi-pods en parallèle |

## Installation

### Pré-requis

- Git
- Vim 9.2+ compilé depuis les sources
- tmux 3.2+

### Nouvelle machine

```bash
git clone <url> ~/dotfiles
bash ~/dotfiles/install.sh
```

Le script propose de choisir les composants à installer :

```
── Dotfiles — sélection des composants ──

    Vim [O/n]
    tmux [O/n]
    Git [O/n]
    Fish [O/n]
    Bat [O/n]
    Dépendances (LSP, plugins vim/tmux) [o/N]
```

Les symlinks créés :

| Symlink | Source |
|---|---|
| `~/.vimrc` | `dotfiles/vim/vimrc` |
| `~/.vim/setup.sh` | `dotfiles/vim/setup.sh` |
| `~/.tmux.conf` | `dotfiles/tmux/tmux.conf` |
| `~/.gitconfig` | inclut `dotfiles/git/gitconfig` via `[include]` |
| `~/.config/fish/conf.d/tools.fish` | `dotfiles/fish/conf.d/tools.fish` (fish) |
| `~/.bashrc` | source de `dotfiles/bash/tools.sh` (bash) |
| `~/.config/bat/config` | `dotfiles/bat/config` |

> **Note :** `~/.gitconfig` n'est pas remplacé — la section `[user]` (nom, email) reste locale à chaque machine.

### Après installation

**Vim** — installer les plugins :
```vim
:PlugInstall
```

**tmux** — installer les plugins (dans une session tmux) :
```
C-a I
```

### Dépendances système

Le script `vim/setup.sh` installe automatiquement les dépendances sur **Arch Linux** et **Debian 12+** :

- Outils : `ripgrep`, `glow`, `fzf`, `fd`, `bat`, `delta`, `zoxide`, `lazygit`, `lazydocker`, `eza`, `jq`, `direnv`, `btop`
- Kubernetes : `kubectl`, `k9s`, `kubectx`, `kubens`, `stern`
- Runtime : `nodejs`, `npm`, `pipx`, `rustup`
- Compilateurs : `clangd`, `rust-analyzer`
- Serveurs LSP Python : `pylsp`, `pyright`
- Serveurs LSP Docker : `dockerfile-language-server`, `docker-compose-langserver`

## Structure

```
dotfiles/
├── install.sh                      ← point d'entrée
├── bat/
│   └── config                      ← thème Gruvbox
├── bash/
│   └── tools.sh                    ← zoxide, fzf, eza, lazygit, uv, docker (bash)
├── fish/
│   └── conf.d/
│       └── tools.fish              ← zoxide, fzf, eza, lazygit, uv, docker (fish)
├── git/
│   ├── gitconfig                   ← aliases et delta
│   └── README.md
├── tmux/
│   ├── tmux.conf
│   └── README.md
└── vim/
    ├── vimrc
    ├── setup.sh                    ← installation des dépendances (Arch / Debian)
    └── README.md
```
