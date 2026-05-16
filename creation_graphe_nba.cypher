// --- ÉTAPE 1 : CONTRAINTES ---
CREATE CONSTRAINT `id_PLAYER_key` IF NOT EXISTS
FOR (n: `PLAYER`)
REQUIRE (n.`id`) IS NODE KEY;

CREATE CONSTRAINT `id_TEAM_key` IF NOT EXISTS
FOR (n: `TEAM`)
REQUIRE (n.`id`) IS NODE KEY;

CREATE CONSTRAINT `id_Game_key` IF NOT EXISTS
FOR (n: `Game`)
REQUIRE (n.`id`) IS NODE KEY;

// --- ÉTAPE 2 : CHARGEMENT DES NŒUDS ---
// Chargement des Joueurs
UNWIND $nodeRecords AS nodeRecord
WITH *
WHERE NOT nodeRecord.`PLAYER_ID` IN $idsToSkip AND NOT toInteger(trim(nodeRecord.`PLAYER_ID`)) IS NULL
MERGE (n: `PLAYER` { `id`: toInteger(trim(nodeRecord.`PLAYER_ID`)) })
SET n.`name` = nodeRecord.`PLAYER_NAME`;

// Chargement des Équipes
UNWIND $nodeRecords AS nodeRecord
WITH *
WHERE NOT nodeRecord.`TEAM_ID` IN $idsToSkip AND NOT toInteger(trim(nodeRecord.`TEAM_ID`)) IS NULL
MERGE (n: `TEAM` { `id`: toInteger(trim(nodeRecord.`TEAM_ID`)) })
SET n.`name` = nodeRecord.`CITY`;

// Chargement des Matchs (Games)
UNWIND $nodeRecords AS nodeRecord
WITH *
WHERE NOT nodeRecord.`GAME_ID` IN $idsToSkip AND NOT nodeRecord.`GAME_ID` IS NULL
MERGE (n: `Game` { `id`: nodeRecord.`GAME_ID` })
SET n.`date` = datetime(nodeRecord.`GAME_DATE_EST`)
SET n.`status` = nodeRecord.`GAME_STATUS_TEXT`
SET n.`point_home` = toInteger(trim(nodeRecord.`PTS_home`))
SET n.`point_away` = toInteger(trim(nodeRecord.`PTS_away`))
SET n.`home_win` = toInteger(trim(nodeRecord.`HOME_TEAM_WINS`));

// --- ÉTAPE 3 : CHARGEMENT DES RELATIONS ---
// Relation d'appartenance des joueurs aux équipes
UNWIND $relRecords AS relRecord
MATCH (source: `PLAYER` { `id`: toInteger(trim(relRecord.`PLAYER_ID`)) })
MATCH (target: `TEAM` { `id`: toInteger(trim(relRecord.`TEAM_ID`)) })
MERGE (source)-[r: `PLAYS_FOR`]->(target);

// Relation Match vers Équipe Invité (Away)
UNWIND $relRecords AS relRecord
MATCH (source: `Game` { `id`: relRecord.`GAME_ID` })
MATCH (target: `TEAM` { `id`: toInteger(trim(relRecord.`TEAM_ID_away`)) })
MERGE (source)-[r: `team_away`]->(target);

// Relation Match vers Équipe Locale (Home)
UNWIND $relRecords AS relRecord
MATCH (source: `Game` { `id`: relRecord.`GAME_ID` })
MATCH (target: `TEAM` { `id`: toInteger(trim(relRecord.`TEAM_ID_home`)) })
MERGE (source)-[r: `team_home`]->(target);
