#!/bin/bash

# Vérifie si l'utilisateur est root (administrateur)
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant qu'administrateur (utilisez sudo)."
  exit 1
fi

# Vérifie si MariaDB est installé
if ! command -v mysql &> /dev/null; then
  echo "MariaDB n'est pas installé sur votre système. Installation en cours..."
  sudo apt-get update
  sudo apt-get install -y mariadb-server
fi

# Demande le nom du projet 
if [ -z "$1" ]; then
  read -p "Veuillez entrer le nom du projet : " project_name
else
  project_name="$1"
fi

# Génère un mot de passe aléatoire de 16 caractères
password=$(date +%s | sha256sum | base64 | head -c 16)

# Crée la base de données
mysql -e "CREATE DATABASE $project_name;"

# Crée un utilisateur avec le même nom que le projet
mysql -e "CREATE USER '$project_name'@'localhost' IDENTIFIED BY '$password';"

# Accorder tous les droits sur la base de données à l'utilisateur
mysql -e "GRANT ALL PRIVILEGES ON $project_name.* TO '$project_name'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Afficher les informations récapitulatives
echo "La base de données '$project_name' a été créée avec succès."
echo "Nom d'utilisateur : $project_name"
echo "Mot de passe : $password"

# Assurer la sécurité en enlevant les droits d'accès à ce script
chmod 700 $0

exit 0
