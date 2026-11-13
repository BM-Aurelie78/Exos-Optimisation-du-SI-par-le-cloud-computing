
-- TP3 UrbanHub
-- Gestion des permissions de l'entrepôt décisionnel

-- 1. Créer un rôle analyste sans connexion directe
CREATE ROLE analyste NOLOGIN;

-- 2. Autoriser l'accès à la base de données
GRANT CONNECT ON DATABASE urbanhub TO analyste;

-- 3. Autoriser l'utilisation du schéma décisionnel
GRANT USAGE ON SCHEMA decisionnel TO analyste;

-- 4. Autoriser la lecture des tables décisionnelles
GRANT SELECT ON ALL TABLES
IN SCHEMA decisionnel TO analyste;

-- 5. Autoriser la lecture des futures tables
-- créées par urbanhub_user dans ce schéma
ALTER DEFAULT PRIVILEGES FOR ROLE urbanhub_user
IN SCHEMA decisionnel
GRANT SELECT ON TABLES TO analyste;
