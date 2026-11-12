
-- TP3 UrbanHub
-- Requête 1 : concentration moyenne par ville, zone et polluant
-- Données simulées : concentrations en µg/m³

SELECT
    l.ville,
    l.zone,
    p.code_polluant,
    ROUND(AVG(f.concentration)::numeric, 2)
        AS concentration_moyenne,
    COUNT(*) AS nombre_mesures
FROM decisionnel.fact_pollution AS f
JOIN decisionnel.dim_localisation AS l
    ON f.localisation_key = l.localisation_key
JOIN decisionnel.dim_polluant AS p
    ON f.polluant_key = p.polluant_key
GROUP BY
    l.ville,
    l.zone,
    p.code_polluant
ORDER BY
    l.ville,
    l.zone,
    p.code_polluant;


-- Requête 2 : concentration moyenne par polluant
-- et par niveau de trafic

SELECT
    p.code_polluant,
    tr.niveau_trafic,
    ROUND(AVG(f.concentration)::numeric, 2)
        AS concentration_moyenne,
    COUNT(*) AS nombre_mesures
FROM decisionnel.fact_pollution AS f
JOIN decisionnel.dim_polluant AS p
    ON f.polluant_key = p.polluant_key
JOIN decisionnel.dim_trafic AS tr
    ON f.trafic_key = tr.trafic_key
GROUP BY
    p.code_polluant,
    tr.niveau_trafic
ORDER BY
    p.code_polluant,
    tr.niveau_trafic;


-- Requête 3 : moyenne pondérée de la pollution
-- selon des coefficients pédagogiques de trafic.
--
-- Faible = 1, Moyen = 2, Élevé = 3.
-- Les mesures au trafic inconnu sont exclues.
-- Ces coefficients ne sont pas des débits réels.

WITH mesures_ponderees AS (
    SELECT
        p.code_polluant,
        f.concentration,
        CASE tr.niveau_trafic
            WHEN 'Faible' THEN 1
            WHEN 'Moyen' THEN 2
            WHEN 'Élevé' THEN 3
            ELSE NULL
        END AS poids
    FROM decisionnel.fact_pollution AS f
    JOIN decisionnel.dim_polluant AS p
        ON f.polluant_key = p.polluant_key
    JOIN decisionnel.dim_trafic AS tr
        ON f.trafic_key = tr.trafic_key
)
SELECT
    code_polluant,
    ROUND(
        (
            SUM(concentration * poids)
            / NULLIF(SUM(poids), 0)
        )::numeric,
        2
    ) AS concentration_moyenne_ponderee,
    COUNT(poids) AS nombre_mesures_ponderees
FROM mesures_ponderees
WHERE poids IS NOT NULL
GROUP BY code_polluant
ORDER BY code_polluant;
