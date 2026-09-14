#!/usr/bin/env bash
set -e

echo "========== 1. TERRAFORM =========="
terraform init -input=false
terraform apply -auto-approve

echo
echo "========== 2. ATTENTE DE SSH =========="

for i in {1..20}; do
    if ansible smartcity -i inventory.ini -m ping >/dev/null 2>&1; then
        echo "Hote Ansible accessible."
        break
    fi

    if [ "$i" -eq 20 ]; then
        echo "ERREUR : l'hote Ansible ne repond pas."
        exit 1
    fi

    echo "Attente de l'hote... tentative $i/20"
    sleep 2
done

echo
echo "========== 3. CONFIGURATION ANSIBLE =========="
ansible-playbook -i inventory.ini playbook.yml

echo
echo "========== 4. VERIFICATION HTTP =========="
curl --fail --silent --show-error http://127.0.0.1:18081

echo
echo
echo "========== DEPLOIEMENT TERMINE =========="
