# Git Config

Aliases et paramètres git. La section `[user]` reste dans `~/.gitconfig` local (non versionné).

## Installation

`install.sh` ajoute automatiquement l'`[include]` dans `~/.gitconfig` :

```bash
bash ~/dotfiles/install.sh
```

Ou manuellement :

```bash
git config --global include.path "~/dotfiles/git/gitconfig"
```

---

## Aliases

### Status / Log

| Alias | Commande | Description |
|---|---|---|
| `git st` | `status -sb` | Statut court avec branche |
| `git lg` | log graph coloré | Log graphe du branch courant |
| `git lga` | log graph coloré | Log graphe de toutes les branches |
| `git last` | `log -1 HEAD --stat` | Dernier commit avec fichiers modifiés |
| `git contributors` | `shortlog -sn --no-merges` | Classement des contributeurs |
| `git aliases` | | Lister tous les aliases |

### Branches

| Alias | Commande | Description |
|---|---|---|
| `git br` | `branch -vv` | Branches locales avec tracking |
| `git bra` | `branch -vva` | Toutes les branches (locales + remotes) |
| `git sw <branche>` | `switch` | Changer de branche |
| `git gone` | | Supprimer les branches dont la remote a disparu |

### Staging / Diff

| Alias | Commande | Description |
|---|---|---|
| `git a <fichier>` | `add` | Ajouter au stage |
| `git ap` | `add --patch` | Staging interactif par hunks |
| `git d` | `diff` | Diff non stagé |
| `git ds` | `diff --staged` | Diff stagé |
| `git dw` | `diff --word-diff=color` | Diff mot à mot |

### Commit

| Alias | Commande | Description |
|---|---|---|
| `git ci` | `commit` | Commit |
| `git ca` | `commit --amend` | Amender le dernier commit |
| `git can` | `commit --amend --no-edit` | Amender sans changer le message |
| `git fixup` | `commit --fixup` | Commit fixup (pour rebase autosquash) |
| `git wip` | | Commit rapide "WIP" de tout |
| `git unwip` | | Annule le dernier commit s'il est "WIP" |

### Undo / Reset

| Alias | Commande | Description |
|---|---|---|
| `git undo` | `reset HEAD~1 --mixed` | Annule le dernier commit (garde les modifs) |
| `git unstage <fichier>` | `restore --staged` | Retirer du stage |
| `git discard <fichier>` | `restore` | Annuler les modifs d'un fichier |

### Rebase

| Alias | Commande | Description |
|---|---|---|
| `git rbi <base>` | `rebase -i` | Rebase interactif |
| `git rbc` | `rebase --continue` | Continuer le rebase |
| `git rba` | `rebase --abort` | Annuler le rebase |
| `git rbs` | `rebase --skip` | Passer le commit courant |

### Remote / Stash

| Alias | Commande | Description |
|---|---|---|
| `git pf` | `push --force-with-lease` | Force push sécurisé |
| `git sl` | `stash list` | Lister les stashs |
| `git sp` | `stash pop` | Appliquer et supprimer le dernier stash |
| `git ss <message>` | `stash push -m` | Sauvegarder avec un message |

---

## Paramètres notables

| Paramètre | Valeur | Effet |
|---|---|---|
| `pull.rebase` | `true` | `git pull` fait un rebase plutôt qu'un merge |
| `push.autoSetupRemote` | `true` | `git push` crée le tracking remote automatiquement |
| `rebase.autosquash` | `true` | Les commits `fixup!` sont squashés automatiquement |
| `rebase.autostash` | `true` | Stash auto avant rebase si l'arbre est sale |
| `merge.conflictstyle` | `diff3` | Affiche aussi la base commune dans les conflits |
| `diff.algorithm` | `histogram` | Diffs plus lisibles sur les fichiers refactorés |
