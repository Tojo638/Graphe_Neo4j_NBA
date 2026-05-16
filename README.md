# Graphe_Neo4j_NBA

Ce dépôt contient le script Cypher nécessaire pour modéliser, contraindre et charger des données massives de la NBA (Joueurs, Équipes, Matchs) dans une base de données orientée graphe **Neo4j**.

Le script est optimisé pour traiter des volumes importants de données à l'aide de paramètres (`$nodeRecords`, `$relRecords`), ce qui le rend idéal pour une intégration via des scripts d'automatisation (Python, drivers officiels) ou directement dans Neo4j Desktop.

---

## 📊 Modèle de Graphe (Schéma)

Le modèle repose sur trois types de nœuds principaux et trois types de relations :

### Nœuds
* **`PLAYER`** : Représente un joueur de la NBA.
    * *Propriétés* : `id` (Clé unique), `name` (Nom du joueur).
* **`TEAM`** : Représente une franchise NBA.
    * *Propriétés* : `id` (Clé unique), `name` (Nom de la ville de la franchise).
* **`Game`** : Représente un match joué.
    * *Propriétés* : `id` (Clé unique), `date` (Datetime), `status`, `point_home`, `point_away`, `home_win` (1 si victoire à domicile, 0 sinon).

### Relations
* `(:PLAYER)-[:PLAYS_FOR]->(:TEAM)` : Associe un joueur à son équipe.
* `(:Game)-[:team_home]->(:TEAM)` : Relie un match à l'équipe qui évolue à domicile.
* `(:Game)-[:team_away]->(:TEAM)` : Relie un match à l'équipe visiteuse.

---

## 🛠️ Structure du Script (`creation_graphe_nba.cypher`)

Le fichier est divisé en 3 étapes clés pour garantir l'intégrité et la performance de l'importation :

### Étape 1 : Configuration des Contraintes
Mise en place de contraintes de type `NODE KEY` sur les identifiants uniques (`id`) des nœuds `PLAYER`, `TEAM` et `Game`. Cela assure l'unicité des données et accélère considérablement les phases de recherche et de fusion (`MERGE`).

### Étape 2 : Chargement des Nœuds
Utilisation de la clause `UNWIND` pour itérer sur la liste de dictionnaires `$nodeRecords`. Le script nettoie les données à la volée :
* Conversion des types (chaînes de caractères vers entiers ou objets `datetime`).
* Filtrage des valeurs nulles.
* Exclusion des identifiants présents dans la liste d'exclusion `$idsToSkip`.

### Étape 3 : Chargement des Relations
Création des connexions structurelles à partir du paramètre `$relRecords`. Les correspondances (`MATCH`) s'appuient efficacement sur les clés uniques configurées à l'étape 1 pour l'établissement des relations `PLAYS_FOR`, `team_home` et `team_away`.

---

## 🚀 Utilisation et Paramètres

### Prérequis
* Une instance **Neo4j** (Neo4j Desktop, Community Server ou AuraDB).
