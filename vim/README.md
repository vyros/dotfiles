# Vim IDE Config

Configuration IDE pour Vim 9.2+, basée sur `vim-plug`.

## Installation

### Nouvelle machine

Copier `~/.vimrc` et `~/.vim/setup.sh`, puis lancer :

```bash
mkdir -p ~/.vim
bash ~/.vim/setup.sh
```

Le script installe automatiquement les dépendances système, les serveurs LSP et les plugins Vim. Fonctionne sur **Arch Linux** et **Debian 12+**.

### Plugins uniquement

```vim
:PlugInstall
```

---

## Plugins

| Plugin | Rôle |
|---|---|
| [gruvbox](https://github.com/morhetz/gruvbox) | Colorschème sombre |
| [fzf](https://github.com/junegunn/fzf) + [fzf.vim](https://github.com/junegunn/fzf.vim) | Recherche floue fichiers / buffers / grep |
| [yegappan/lsp](https://github.com/yegappan/lsp) | Client LSP natif Vim9Script |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Intégration git |
| [vim-gitgutter](https://github.com/airblade/vim-gitgutter) | Marqueurs diff git dans la gouttière |
| [vim-commentary](https://github.com/tpope/vim-commentary) | Commenter/décommenter |
| [auto-pairs](https://github.com/jiangmiao/auto-pairs) | Fermeture auto des brackets et quotes |
| [vim-surround](https://github.com/tpope/vim-surround) | Modifier les délimiteurs autour d'un texte |
| [vim-vinegar](https://github.com/tpope/vim-vinegar) | Explorateur de fichiers (netrw amélioré) |

---

## Raccourcis

> **Leader** = `<Space>`

### Navigation entre splits

| Raccourci | Action |
|---|---|
| `<C-h/j/k/l>` | Se déplacer entre les splits |
| `<C-Left/Right>` | Redimensionner horizontalement |
| `<C-Up/Down>` | Redimensionner verticalement |

### Buffers

| Raccourci | Action |
|---|---|
| `<leader>bn` | Buffer suivant |
| `<leader>bp` | Buffer précédent |
| `<leader>bd` | Fermer le buffer |
| `<leader>bl` | Lister les buffers |

### Recherche — fzf

| Raccourci | Action |
|---|---|
| `<leader>ff` | Chercher un fichier |
| `<leader>fg` | Grep live (ripgrep) |
| `<leader>fb` | Chercher dans les buffers ouverts |
| `<leader>fh` | Historique des fichiers récents |
| `<leader>ft` | Tags du buffer courant |
| `<leader>fl` | Lignes du buffer courant |

### LSP

| Raccourci | Action |
|---|---|
| `gd` | Aller à la définition |
| `gD` | Aller à la déclaration |
| `gi` | Aller à l'implémentation |
| `gy` | Aller à la définition du type |
| `gr` | Afficher les références |
| `K` | Documentation hover |
| `<leader>rn` | Renommer le symbole |
| `<leader>ca` | Actions de code |
| `<leader>lf` | Formater le fichier (ou la sélection) |
| `<leader>ld` | Afficher les diagnostics |
| `<leader>lq` | Diagnostic sur la ligne courante |
| `[d` | Diagnostic précédent |
| `]d` | Diagnostic suivant |
| `<leader>ls` | Rechercher un symbole dans le fichier |
| `<leader>lS` | Rechercher un symbole dans le workspace |
| `<leader>lc` | Hiérarchie d'appels |

### Serveurs LSP configurés

Les serveurs présents sur le système sont détectés et chargés automatiquement.

| Serveur | Langages | Statut | Installation |
|---|---|---|---|
| `clangd` | C, C++, ObjC | ✓ installé | `pacman -S clang` |
| `rust-analyzer` | Rust | ✓ installé | `rustup component add rust-analyzer` |
| `docker-langserver` | Dockerfile | ✓ installé | `npm i -g dockerfile-language-server-nodejs` |
| `docker-compose-langserver` | Docker Compose | ✓ installé | `npm i -g @microsoft/compose-language-service` |
| `pylsp` | Python | ✓ installé | `pipx install python-lsp-server` |
| `pyright` | Python | ✓ installé | `pipx install pyright` |
| `typescript-language-server` | JS, TS | — | `npm i -g typescript-language-server` |
| `gopls` | Go | — | `go install golang.org/x/tools/gopls@latest` |
| `lua-language-server` | Lua | — | `pacman -S lua-language-server` |

### Git — fugitive

| Raccourci | Action |
|---|---|
| `<leader>gs` | Statut git (`:Git`) |
| `<leader>gb` | Blame |
| `<leader>gd` | Diff split |
| `<leader>gl` | Log du fichier courant |
| `<leader>gp` | Push |
| `<leader>gP` | Pull |

### Git — gitgutter (hunks)

| Raccourci | Action |
|---|---|
| `[h` | Hunk précédent |
| `]h` | Hunk suivant |
| `<leader>hs` | Stager le hunk |
| `<leader>hu` | Annuler le hunk |
| `<leader>hp` | Prévisualiser le hunk |

### Commentaires — vim-commentary

| Raccourci | Action |
|---|---|
| `gcc` | Commenter/décommenter la ligne |
| `gc<motion>` | Commenter/décommenter un mouvement |
| `gc` (visuel) | Commenter/décommenter la sélection |

### Surround — vim-surround

| Raccourci | Exemple | Résultat |
|---|---|---|
| `cs"'` | `"hello"` → | `'hello'` |
| `ds"` | `"hello"` → | `hello` |
| `ysiw)` | `hello` → | `(hello)` |
| `yss)` | ligne entière → | `(ligne)` |

### Terminal

| Raccourci | Action |
|---|---|
| `<leader>tt` | Ouvrir un terminal horizontal |
| `<leader>tv` | Ouvrir un terminal vertical |
| `<Esc>` | Quitter le mode terminal |

### Explorateur de fichiers — vim-vinegar

| Raccourci | Action |
|---|---|
| `-` | Ouvrir netrw dans le répertoire du fichier courant |
| `-` (dans netrw) | Remonter d'un niveau |

### Markdown — glow

| Raccourci | Action |
|---|---|
| `<leader>mg` | Ouvrir un aperçu rendu dans un split vertical |

> Le split se rafraîchit automatiquement à chaque sauvegarde si glow est déjà ouvert.

### Divers

| Raccourci | Action |
|---|---|
| `<leader>/` | Effacer la surbrillance de recherche |
| `jk` | Quitter le mode insertion |
| `<A-j/k>` | Déplacer la ligne / sélection vers le bas/haut |
| `<` / `>` (visuel) | Indenter en conservant la sélection |
