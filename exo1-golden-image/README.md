# TP Golden Image - Smart City

## 1. Objectif

L'objectif de ce TP est de construire des golden images reproductibles pour un environnement IoT / Smart City.

Le TP est réalisé en **mode VPS / Docker**.

Le VPS sert d'environnement de construction et Packer permet d'automatiser la création des images à partir d'**Ubuntu 22.04 LTS**.

> Dans ce mode, les artefacts produits sont des images Docker reproductibles et non des AMI AWS.

---

## 2. Environnement

Environnement utilisé pour réaliser le TP :

- VPS hôte : Debian 12
- Docker
- Docker Compose
- Packer
- Git
- Image de base : Ubuntu 22.04 LTS

Le VPS hôte fonctionne sous Debian 12, tandis que les golden images utilisent Ubuntu 22.04 comme système cible.

---

## 3. Dimensionnement des ressources

La golden image est destinée à un rôle applicatif IoT / Smart City avec une charge pédagogique à modérée.

Le dimensionnement cible retenu est :

| Ressource | Valeur | Justification |
|---|---:|---|
| CPU | 2 vCPU | Suffisant pour les traitements Python, les communications réseau et le traitement de messages IoT. |
| RAM | 4 Go | Permet d'exécuter Ubuntu et les traitements applicatifs avec une marge pour les pics de consommation. |
| Disque | 20 Go | Permet de stocker l'OS, les dépendances, les logs et les fichiers temporaires avec une marge d'évolution. |

Ce dimensionnement concerne un rôle applicatif basé sur la golden image et non l'ensemble de la plateforme Smart City.

Les composants ayant des besoins spécifiques, notamment les bases de données et le broker de messages, doivent être dimensionnés séparément.

---

## 4. Golden image de base

La golden image de base contient :

- Ubuntu 22.04 LTS
- Python 3
- pip
- Git
- curl
- certificats CA

Artefact généré :

`smart-city-golden:1.0`

Cette image constitue le socle commun à partir duquel des rôles applicatifs spécialisés peuvent être construits.

---

## 5. Golden images par rôle métier

Afin de respecter le principe **« une image = un rôle métier unique »**, plusieurs images ont été construites avec Packer.

| Image | Rôle | Principaux composants |
|---|---|---|
| `smart-city-golden:1.0` | Socle | Ubuntu 22.04, Python 3, pip, Git, curl |
| `smart-city-api:1.0` | API applicative | Ubuntu 22.04, Python 3, FastAPI, Uvicorn |
| `smart-city-worker:1.0` | Traitement des messages RabbitMQ | Ubuntu 22.04, Python 3, Pika |
| `smart-city-analysis:1.0` | Analyse des données | Ubuntu 22.04, Python 3, Pika, FastAPI |

### Image API

L'image `smart-city-api:1.0` est destinée aux services exposant une API HTTP.

Test :

```bash
docker run --rm smart-city-api:1.0 python3 -c "import fastapi; print('API OK - FastAPI', fastapi.__version__)"
```

Résultat obtenu :

```text
API OK - FastAPI 0.141.1
```

### Image Worker

L'image `smart-city-worker:1.0` est destinée aux traitements utilisant RabbitMQ.

La bibliothèque Python **Pika** permet la communication avec RabbitMQ via AMQP.

Test :

```bash
docker run --rm smart-city-worker:1.0 python3 -c "import pika; print('WORKER OK - Pika', pika.__version__)"
```

Résultat obtenu :

```text
WORKER OK - Pika 1.4.4
```

### Image Analysis

L'image `smart-city-analysis:1.0` fournit un environnement destiné aux traitements d'analyse.

Test :

```bash
docker run --rm smart-city-analysis:1.0 python3 -c "import pika, fastapi; print('ANALYSIS OK')"
```

Résultat obtenu :

```text
ANALYSIS OK
```

---

## 6. Configuration Packer

Les configurations Packer sont séparées par rôle :

```text
packer-base.pkr.hcl
packer-api.pkr.hcl
packer-worker.pkr.hcl
packer-analysis.pkr.hcl
```

Packer utilise ici le **builder Docker** avec l'image de base :

```text
ubuntu:22.04
```

---

## 7. Validation des configurations

Chaque configuration peut être validée indépendamment.

```bash
packer validate packer-base.pkr.hcl
packer validate packer-api.pkr.hcl
packer validate packer-worker.pkr.hcl
packer validate packer-analysis.pkr.hcl
```

Résultat obtenu pour chaque fichier :

```text
The configuration is valid.
```

---

## 8. Construction des images

Exemple de construction de l'image Worker :

```bash
packer build packer-worker.pkr.hcl
```

La construction est automatisée par Packer :

1. utilisation d'Ubuntu 22.04 comme base ;
2. installation des dépendances ;
3. vérification des composants ;
4. création de l'artefact ;
5. attribution du nom et du tag.

Les autres images peuvent être construites avec :

```bash
packer build packer-base.pkr.hcl
packer build packer-api.pkr.hcl
packer build packer-analysis.pkr.hcl
```

---

## 9. Vérification des images

Les images construites sont vérifiées avec :

```bash
docker images
```

Les principaux artefacts obtenus sont :

```text
smart-city-golden:1.0
smart-city-api:1.0
smart-city-worker:1.0
smart-city-analysis:1.0
ubuntu:22.04
```

Le tag `1.0` permet de versionner explicitement les golden images.

---

## 10. Choix techniques

Ubuntu 22.04 LTS a été choisi comme système cible car il s'agit d'une version LTS adaptée à un environnement serveur.

Packer permet d'automatiser la construction des images et d'obtenir un processus reproductible.

La séparation des images par rôle permet :

- de reproduire facilement les environnements ;
- de versionner les images ;
- de limiter les différences de configuration ;
- de tester les dépendances avant déploiement ;
- de reconstruire rapidement une image ;
- de séparer les responsabilités des différents services.

Les composants tels que RabbitMQ, PostgreSQL, Redis et Grafana ne sont pas intégrés dans la golden image de base. Ils peuvent être déployés séparément selon l'architecture de la plateforme.

---

## 11. Docker et AMI AWS

Le TP a été réalisé en **mode VPS / Docker**.

Packer utilise donc le builder Docker et produit des images Docker reproductibles.

Ces artefacts permettent de démontrer le principe de golden image :

- automatisation ;
- reproductibilité ;
- versionnement ;
- spécialisation par rôle métier.

Une image Docker n'est cependant pas une **AMI AWS**.

Dans un environnement AWS réel, le même principe pourrait être appliqué avec un builder Packer `amazon-ebs` afin de produire une AMI permettant de lancer plusieurs instances EC2 identiques.

---

## 12. Reproduction

### Prérequis

La machine de construction doit disposer de :

- Docker
- Packer
- Git

Vérification :

```bash
docker --version
packer version
git --version
```

### Initialisation

Exemple avec l'image Worker :

```bash
packer init packer-worker.pkr.hcl
```

### Validation

```bash
packer validate packer-worker.pkr.hcl
```

### Construction

```bash
packer build packer-worker.pkr.hcl
```

### Vérification

```bash
docker images
```

### Test

```bash
docker run --rm smart-city-worker:1.0 python3 -c "import pika; print('GOLDEN IMAGE WORKER OK - Pika', pika.__version__)"
```

---

## 13. Résultat

Le TP permet d'obtenir plusieurs golden images reproductibles et versionnées pour les différents rôles de la plateforme Smart City.

La création des images n'est plus réalisée manuellement : elle est décrite sous forme de code avec Packer, ce qui facilite leur reconstruction, leur validation et leur réutilisation.
