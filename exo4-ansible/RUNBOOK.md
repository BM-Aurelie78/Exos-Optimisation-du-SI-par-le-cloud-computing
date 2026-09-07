
## Prérequis d'exécution

Les commandes de ce runbook doivent être exécutées depuis le dossier de l'Exercice 4 :

```bash
cd exo4-ansible
export ANSIBLE_PASSWORD=ansible

```

# Runbook — Gestion d'un échec de patching Smart City

## Objectif

Ce runbook décrit la procédure à suivre lorsqu'un patch échoue sur le nœud Canary ou lorsqu'une validation CI GitHub Actions retourne un statut FAILURE.

## Principe général

Le déploiement suit une stratégie Canary First :

1. Détection des mises à jour disponibles.
2. Application du patch sur `smartcity-vm01`.
3. Vérifications post-patch.
4. Promotion vers `smartcity-vm02` et `smartcity-vm03` uniquement si le Canary est validé.

En cas d'échec, la promotion vers la production doit être immédiatement interrompue.

## Procédure en cas d'échec

### 1. Stopper la promotion

Ne pas exécuter :

```bash
ansible-playbook -i inventory.ini playbooks/production-patch.yml


