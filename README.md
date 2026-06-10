# WhatTodo

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![WoW Interface](https://img.shields.io/badge/WoW-12.0.5%20Midnight-orange)
![Lua](https://img.shields.io/badge/Lua-5.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> 🇫🇷 [Français](#français) · 🇬🇧 [English](#english)

---

## Français

### Présentation

WhatTodo est un addon World of Warcraft (Midnight, 12.0.5) qui affiche une **liste de tâches** se réinitialisant automatiquement selon leur fréquence. Chaque tâche et son état de complétion sont persistés **par personnage** via AceDB.

Les resets ont lieu à **5h00, heure serveur** :

| Fréquence | Reset |
|-----------|-------|
| Quotidienne | tous les jours à 5h |
| Hebdomadaire | chaque mercredi à 5h |
| Mensuelle | le 1er de chaque mois à 5h |

L'état « fait / à faire » est déduit de la dernière complétion comparée à la borne de reset courante : au passage de 5h, les tâches concernées redeviennent « à faire » toutes seules.

L'interface est en **français** sur les clients FR et en **anglais** partout ailleurs (selon la locale du jeu).

### Installation

1. Télécharger la dernière release (fichier ZIP)
2. Extraire le dossier `WhatTodo` dans :
   ```
   World of Warcraft/_retail_/Interface/AddOns/
   ```
3. Lancer le jeu et activer **WhatTodo** dans le gestionnaire d'addons

### Utilisation

#### Affichage

Une fenêtre au style parchemin liste les tâches groupées par fréquence (Quotidiennes / Hebdomadaires / Mensuelles), avec un compte à rebours jusqu'au prochain reset par section. Cocher une case marque la tâche comme faite. La fenêtre est déplaçable par glisser-déposer et sa position est mémorisée.

#### Bouton minimap

Un bouton « parchemin » apparaît autour de la minicarte :

| Action | Résultat |
|--------|----------|
| Clic gauche | Affiche / masque la liste |
| Clic droit | Ouvre le panel de gestion |

L'infobulle indique le nombre de tâches restantes par fréquence.

#### Panel de gestion

Choisir une fréquence, saisir un libellé, cliquer sur **Ajouter**. Chaque tâche existante peut être renommée, recatégorisée ou supprimée.

#### Commandes

| Commande | Effet |
|----------|-------|
| `/wt` | Affiche / masque la liste |
| `/wt config` | Ouvre le panel de gestion |

---

## English

### Overview

WhatTodo is a World of Warcraft addon (Midnight, 12.0.5) that displays a **to-do list** which resets automatically based on each task's frequency. Tasks and their completion state are stored **per character** through AceDB.

Resets happen at **5:00 AM server time**:

| Frequency | Reset |
|-----------|-------|
| Daily | every day at 5am |
| Weekly | every Wednesday at 5am |
| Monthly | on the 1st of each month at 5am |

The done/to-do state is derived from the last completion time versus the current reset boundary: when 5am passes, the relevant tasks re-arm on their own.

The interface is shown in **French** on FR clients and in **English** everywhere else (based on the game locale).

### Installation

1. Download the latest release (ZIP file)
2. Extract the `WhatTodo` folder into:
   ```
   World of Warcraft/_retail_/Interface/AddOns/
   ```
3. Launch the game and enable **WhatTodo** in the addon manager

### Usage

#### Display

A parchment-style window lists tasks grouped by frequency (Daily / Weekly / Monthly), with a countdown to the next reset per section. Ticking a checkbox marks a task as done. The window is draggable and its position is saved.

#### Minimap button

A scroll-style button appears around the minimap:

| Action | Result |
|--------|--------|
| Left-click | Toggle the list |
| Right-click | Open the management panel |

The tooltip shows the number of remaining tasks per frequency.

#### Management panel

Pick a frequency, type a label, click **Add**. Each existing task can be renamed, re-categorized or deleted.

#### Commands

| Command | Effect |
|---------|--------|
| `/wt` | Toggle the list |
| `/wt config` | Open the management panel |

---

## License

MIT — see [LICENSE](LICENSE).
