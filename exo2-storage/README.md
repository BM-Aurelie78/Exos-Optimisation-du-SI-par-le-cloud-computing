# Exercice 2 — Sécuriser et optimiser le stockage des données IoT

## Architecture retenue

L'exercice a été réalisé en Mode A sur VPS avec MinIO afin de simuler
un stockage objet compatible S3.

- Bucket principal : `iot-data`
- 120 fichiers CSV simulant des données de capteurs IoT
- Stockage d'archive séparé
- Politique de cycle de vie
- Chiffrement côté serveur
- Tests de compression et optimisation des coûts

## Cycle de vie

Politique appliquée :

- données actives dans `iot-data`
- transition vers le tier `ARCHIVE` après 30 jours
- expiration après 365 jours

Cette stratégie permet de réduire le coût du stockage des données
qui ne nécessitent plus un accès fréquent.

## Chiffrement

Le stockage a été configuré avec un chiffrement côté serveur
SSE-KMS.

Une clé de test a été utilisée dans le cadre du TP.

Aucune clé ni aucun mot de passe n'est stocké dans ce dépôt Git.

## Optimisation coût / performance

Trois stratégies ont été comparées :

- CSV non compressés : 13 576 octets
- compression GZIP fichier par fichier : 16 924 octets
- archive TAR.GZ globale : 2 235 octets

La compression individuelle est inefficace sur de très petits
fichiers IoT en raison de l'overhead GZIP.

La stratégie retenue consiste donc à regrouper les petits fichiers
avant compression.

Réduction obtenue avec l'archive globale : environ 83,5 %.

## Contenu du dépôt

- `csv-data/` : données IoT CSV de test
- `csv-gzip/` : essais de compression individuelle
- `iot-data-batch.tar.gz` : compression groupée optimisée
- `capteur-chiffre.csv` : fichier utilisé pour le test de chiffrement
- `test-chiffrement.txt` : donnée de validation du chiffrement

Les données internes MinIO (`minio-data`, `.minio.sys`, credentials,
clés KMS, etc.) sont volontairement exclues du dépôt.
