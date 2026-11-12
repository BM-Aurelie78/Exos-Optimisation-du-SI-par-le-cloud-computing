
-- ==================================================
-- TP3 - URBANHUB
-- Entrepôt décisionnel PostgreSQL
-- ==================================================
--
-- Grain de fact_pollution :
-- Une ligne = une observation de concentration
-- d'un polluant à un instant et dans une localisation,
-- associée à une catégorie de trafic.
--
-- Hypothèses provisoires :
-- Faible : 0 <= q < 200
-- Moyen  : 200 <= q < 500
-- Élevé  : q >= 500
--
-- Les seuils supposent que q est un débit en
-- véhicules/heure, ce qui reste à confirmer.
-- ==================================================

CREATE SCHEMA IF NOT EXISTS decisionnel;

-- ==================================================
-- DIMENSION TRAFIC
-- ==================================================

CREATE TABLE IF NOT EXISTS decisionnel.dim_trafic (
    trafic_key BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    niveau_trafic VARCHAR(20) NOT NULL UNIQUE,

    debit_min INTEGER,
    debit_max_exclu INTEGER,

    CONSTRAINT chk_debit_min
        CHECK (debit_min IS NULL OR debit_min >= 0),

    CONSTRAINT chk_intervalle_trafic
        CHECK (
            debit_max_exclu IS NULL
            OR (
                debit_min IS NOT NULL
                AND debit_min < debit_max_exclu
            )
        )
);

-- ==================================================
-- DIMENSION TEMPS
-- ==================================================

CREATE TABLE IF NOT EXISTS decisionnel.dim_temps (
    temps_key BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    date_heure TIMESTAMP NOT NULL UNIQUE,

    date_mesure DATE NOT NULL,

    heure SMALLINT NOT NULL
        CHECK (heure BETWEEN 0 AND 23),

    jour_semaine SMALLINT NOT NULL
        CHECK (jour_semaine BETWEEN 1 AND 7),

    mois SMALLINT NOT NULL
        CHECK (mois BETWEEN 1 AND 12),

    annee SMALLINT NOT NULL
);


-- ==================================================
-- DIMENSION LOCALISATION
-- Grain : une ligne par couple (ville, zone)
-- ==================================================

CREATE TABLE IF NOT EXISTS decisionnel.dim_localisation (
    localisation_key BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    ville VARCHAR(100) NOT NULL,
    zone VARCHAR(100) NOT NULL,

    CONSTRAINT uq_localisation_ville_zone
        UNIQUE (ville, zone)
);


-- ==================================================
-- DIMENSION POLLUANT
-- Grain : une ligne par polluant et unité de mesure
-- ==================================================

CREATE TABLE IF NOT EXISTS decisionnel.dim_polluant (
    polluant_key BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    code_polluant VARCHAR(50) NOT NULL,

    nom_polluant VARCHAR(100) NOT NULL,

    unite VARCHAR(50) NOT NULL,

    CONSTRAINT uq_polluant_unite
        UNIQUE (code_polluant, unite)
);


-- ==================================================
-- TABLE DE FAITS : POLLUTION
--
-- Grain :
-- Une ligne = une observation individuelle
-- d'un polluant, à un instant et dans une zone,
-- associée à une catégorie d'intensité du trafic.
-- ==================================================

CREATE TABLE IF NOT EXISTS decisionnel.fact_pollution (
    pollution_key BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    temps_key BIGINT NOT NULL,

    localisation_key BIGINT NOT NULL,

    polluant_key BIGINT NOT NULL,

    trafic_key BIGINT NOT NULL,

    concentration DOUBLE PRECISION NOT NULL,

    id_mesure_source BIGINT NOT NULL UNIQUE,

    CONSTRAINT fk_pollution_temps
        FOREIGN KEY (temps_key)
        REFERENCES decisionnel.dim_temps(temps_key),

    CONSTRAINT fk_pollution_localisation
        FOREIGN KEY (localisation_key)
        REFERENCES decisionnel.dim_localisation(localisation_key),

    CONSTRAINT fk_pollution_polluant
        FOREIGN KEY (polluant_key)
        REFERENCES decisionnel.dim_polluant(polluant_key),

    CONSTRAINT fk_pollution_trafic
        FOREIGN KEY (trafic_key)
        REFERENCES decisionnel.dim_trafic(trafic_key)
);
