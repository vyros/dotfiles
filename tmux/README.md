# tmux Config

Configuration tmux 3.2+, thème Gruvbox (cohérent avec la config Vim).

## Installation

```bash
bash ~/dotfiles/install.sh
```

Ou manuellement :

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
tmux source ~/.tmux.conf
# Dans tmux : C-a I  pour installer les plugins
```

---

## Raccourcis

> **Préfixe** = `C-a`

### Panneaux

| Raccourci | Action |
|---|---|
| `C-a \|` | Split vertical (conserve le répertoire courant) |
| `C-a -` | Split horizontal (conserve le répertoire courant) |
| `M-h/j/k/l` | Naviguer entre les panneaux (sans préfixe) |
| `C-a H/J/K/L` | Redimensionner le panneau |
| `C-a y` | Synchroniser tous les panneaux (toggle) |
| `C-a C-g` | Terminal flottant (popup 80x80%) |

### Fenêtres

| Raccourci | Action |
|---|---|
| `C-a c` | Nouvelle fenêtre (conserve le répertoire courant) |
| `M-n` | Fenêtre suivante (sans préfixe) |
| `M-p` | Fenêtre précédente (sans préfixe) |

### Sessions

| Raccourci | Action |
|---|---|
| `C-a $` | Renommer la session |
| `C-a s` | Lister et switcher de session |
| `C-a C-s` | Sauvegarder la session (tmux-resurrect) |
| `C-a C-r` | Restaurer la session (tmux-resurrect) |

> La session est aussi sauvegardée automatiquement toutes les **15 minutes** (tmux-continuum).

### Mode copie (vi)

| Raccourci | Action |
|---|---|
| `C-a Esc` | Entrer en mode copie |
| `v` | Début de sélection |
| `V` | Sélection ligne |
| `C-v` | Sélection rectangulaire |
| `y` | Copier dans le presse-papier système |
| `C-a P` | Coller depuis le buffer tmux |
| `C-a >` | Envoyer le buffer tmux → presse-papier système |
| `C-a <` | Importer le presse-papier système → buffer tmux |
| `C-a b` | Naviguer dans les buffers |
| `C-a +` | Supprimer le buffer courant |

### Divers

| Raccourci | Action |
|---|---|
| `C-a r` | Recharger la config |

---

## Plugins

| Plugin | Rôle |
|---|---|
| [tpm](https://github.com/tmux-plugins/tpm) | Gestionnaire de plugins |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Paramètres par défaut sains |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Sauvegarde/restauration manuelle des sessions |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Sauvegarde automatique toutes les 15 min |
