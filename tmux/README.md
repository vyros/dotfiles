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
| `C-a &` | Fermer la fenêtre courante (confirmation demandée) |
| `C-a x` | Fermer le panneau courant (confirmation demandée) |

### Sessions

| Raccourci | Action |
|---|---|
| `C-a $` | Renommer la session |
| `C-a s` | Lister et switcher de session (navigation `hjkl`, `x` pour tuer) |
| `C-a d` | Se détacher de la session (reste active en arrière-plan) |
| `C-a C-s` | Sauvegarder la session (tmux-resurrect) |
| `C-a C-r` | Restaurer la session (tmux-resurrect) |

Depuis le shell (hors tmux) :

```bash
tmux ls                   # lister les sessions actives
tmux a                    # se rattacher à la dernière session détachée
tmux a -t <nom>           # se rattacher à une session spécifique
```

Fermer une session :

```
# Depuis C-a s : naviguer jusqu'à la session, appuyer sur x (confirmation demandée)

# Depuis le prompt tmux (C-a :) :
kill-session              # ferme la session courante
kill-session -t <nom>     # ferme une session spécifique
```

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

## Layouts prédéfinis — `mux`

```bash
mux              # lister les layouts disponibles
mux ide          # auto : fenêtre si dans tmux, session sinon
mux monitor      # idem pour le layout monitor
```

Ou depuis le prompt tmux (`C-a :`) :

```
mux ide          # ouvre le layout ide dans une nouvelle fenêtre
mux monitor      # ouvre le layout monitor dans une nouvelle fenêtre
mux              # affiche les layouts disponibles
```

**Auto-détection** : `mux` détecte si tmux est actif.
- Appelé **depuis tmux** → ouvre un nouveau **window** dans la session courante
- Appelé **hors tmux** → crée une nouvelle **session**

Si une session du même nom existe déjà, `mux` s'y reconnecte.

### Ajouter un layout

Il suffit de créer un fichier dans `tmux/sessions/` — aucune modification de `tmux.conf` n'est nécessaire.

### Créer le script

Créer un fichier `tmux/sessions/<nom>.sh` dans le repo dotfiles :

```bash
#!/usr/bin/env bash
SESSION="mon-layout"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    [[ -z "$TMUX" ]] && tmux attach-session -t "$SESSION" \
                     || tmux switch-client  -t "$SESSION"
    exit 0
fi

tmux new-session -d -s "$SESSION"

# Pane 0 — commande principale
tmux send-keys -t "$SESSION:0.0" "ma-commande" Enter

# Pane 1 — split vertical droite (40%)
tmux split-window -h -t "$SESSION:0.0" -p 40
tmux send-keys -t "$SESSION:0.1" "autre-commande" Enter

tmux select-pane -t "$SESSION:0.0"
[[ -z "$TMUX" ]] && tmux attach-session -t "$SESSION" \
                 || tmux switch-client  -t "$SESSION"
```

### Layouts inclus

| Layout | Contenu |
|---|---|
| `ide` | vim (droite) · btop (haut gauche) · lazygit (bas gauche) |
| `monitor` | btop (gauche) · journalctl -f (haut droite) · dmesg (bas droite) |
| `compose` | lazydocker (gauche) · shell (droite) |
| `k8s` | k9s (gauche) · shell (droite) |

---

## Plugins

| Plugin | Rôle |
|---|---|
| [tpm](https://github.com/tmux-plugins/tpm) | Gestionnaire de plugins |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Paramètres par défaut sains |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Sauvegarde/restauration manuelle des sessions |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Sauvegarde automatique toutes les 15 min |
