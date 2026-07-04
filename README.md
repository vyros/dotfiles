# dotfiles

![lint](https://github.com/vyros/dotfiles/actions/workflows/lint.yml/badge.svg)

Configuration personnelle pour un environnement de développement en ligne de commande.

## Composants

| Outil | Description |
|---|---|
| [Vim](vim/README.md) | Configuration IDE (LSP, fzf, bat preview, git, glow) |
| [tmux](tmux/README.md) | Multiplexeur de terminal (Gruvbox, sessions persistantes) |
| [Git](git/README.md) | Aliases et paramètres (delta pour les diffs) |
| Fish / Bash | Intégration zoxide, direnv, fzf, eza, lazygit, uv, Docker, Kubernetes |
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
| `yazi` | TUI file manager avec navigation et prévisualisation (`y` pour cd à la sortie) |
| `yq` | Processeur YAML (équivalent de jq pour YAML) |
| `xh` | Client HTTP moderne, alternative à curl/httpie |
| `dust` | Analyse d'utilisation disque visuelle (`du` moderne) |
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
    Shell (fish) [O/n]
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

> **Presse-papier :** choisir **tmux** propose aussi d'installer `wl-clipboard` (Wayland) et `xclip` (X11) via le gestionnaire de paquets (`pacman`/`apt`). Sans eux, la copie du mode copie tmux (`y`, souris) ne sort pas vers le presse-papier système. Ignoré avec `--link`.

> **Diff git :** choisir **Git** propose d'installer `git-delta` (pager de diff du gitconfig, rendu side-by-side/gruvbox). Présent sur Arch, Ubuntu 24.04+ et Debian 13+ ; absent des dépôts de Debian 12 (bookworm), où le gitconfig retombe sur `less` et delta s'obtient via l'étape « Dépendances ». Ignoré avec `--link`.

### Après installation

**Vim** — installer les plugins :
```vim
:PlugInstall
```

**tmux** — installer les plugins (dans une session tmux) :
```
C-a I
```

### Mise à jour & maintenance

```bash
cd ~/dotfiles && git pull          # récupère les nouvelles configs (symlinks déjà à jour)

bash install.sh --link             # (re)pose tous les symlinks, sans menu ni dépendances
bash vim/setup.sh --check          # liste les outils présents/manquants (doctor)
bash vim/setup.sh --update         # réinstalle les binaires GitHub même déjà présents (eza, k9s…)
```

> Modifier une config déjà liée (ex. `tmux.conf`) ne nécessite pas de relancer `install.sh` :
> le symlink reflète déjà le repo. Il suffit de recharger l'outil concerné (`C-a r` pour tmux, etc.).

### Dépendances système

Le script `vim/setup.sh` installe automatiquement les dépendances sur **Arch Linux**, **Ubuntu 24.04+** et **Debian 12+** (**x86_64 uniquement** — il s'arrête avec un message sur ARM/autre archi) :

- Outils : `ripgrep`, `glow`, `fzf`, `fd`, `bat`, `delta`, `zoxide`, `lazygit`, `lazydocker`, `yazi`, `yq`, `xh`, `dust`, `eza`, `jq`, `direnv`, `btop`
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
│   ├── mux.sh                      ← dispatcher de layouts (C-a m / C-a :)
│   ├── sessions/                   ← layouts mux (ide, clide, monitor, compose, k8s)
│   │   ├── _lib.sh                 ← boilerplate mutualisé (création session/fenêtre)
│   │   └── *.sh                    ← un fichier par layout
│   └── README.md
└── vim/
    ├── vimrc
    ├── setup.sh                    ← installation des dépendances (Arch / Ubuntu / Debian)
    └── README.md
```
