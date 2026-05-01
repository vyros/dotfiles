# dotfiles

Configuration personnelle pour un environnement de développement en ligne de commande.

## Composants

| Outil | Description |
|---|---|
| [Vim](vim/README.md) | Configuration IDE (LSP, fzf, git, glow) |
| [tmux](tmux/README.md) | Multiplexeur de terminal (Gruvbox, sessions persistantes) |
| [Git](git/README.md) | Aliases et paramètres |

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
    Dépendances (LSP, plugins vim/tmux) [o/N]
```

Les symlinks suivants sont créés :

| Symlink | Source |
|---|---|
| `~/.vimrc` | `dotfiles/vim/vimrc` |
| `~/.vim/setup.sh` | `dotfiles/vim/setup.sh` |
| `~/.tmux.conf` | `dotfiles/tmux/tmux.conf` |
| `~/.gitconfig` | inclut `dotfiles/git/gitconfig` via `[include]` |

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

- `ripgrep`, `glow`, `nodejs`, `npm`, `pipx`
- `clangd`, `rust-analyzer`
- Serveurs LSP : `pylsp`, `pyright`, `dockerfile-language-server`, `docker-compose-langserver`

## Structure

```
dotfiles/
├── install.sh          ← point d'entrée
├── git/
│   ├── gitconfig       ← aliases et paramètres git
│   └── README.md
├── tmux/
│   ├── tmux.conf
│   └── README.md
└── vim/
    ├── vimrc
    ├── setup.sh        ← installation des dépendances (Arch / Debian)
    └── README.md
```
