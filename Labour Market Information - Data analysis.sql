/*

Exploring and analyzing labour market data in SQL queries

/*

-- Variation in employment compared with 2018 / Variation de l'emploi par rapport à 2018

WITH reference_2018 AS (
    SELECT 
        id_secteur,
        AVG(emploi) AS emploi_2018_avg
    FROM 
        epa_total
    WHERE 
        YEAR(date) = 2018 AND id_region = 6 -- Québec
    GROUP BY 
        id_secteur
)
SELECT 
    YEAR(et.date) AS year,
    s.nom_secteur,
    ROUND(AVG(et.emploi) - r.emploi_2018_avg) / r.emploi_2018_avg AS variation_since_2018_percent
FROM 
    epa_total et
JOIN 
    secteurs s ON et.id_secteur = s.id_secteur
JOIN 
    reference_2018 r ON et.id_secteur = r.id_secteur
WHERE 
    id_region = 6 -- Québec
GROUP BY 
    year, s.nom_secteur, r.emploi_2018_avg
ORDER BY 
    year DESC;


-- Employment seasonality analysis / Analyse de saisonnalité de l'emploi

WITH summer_avg AS (
    SELECT 
        YEAR(et.date) AS year,
        s.nom_secteur,
        AVG(et.emploi) AS avg_summer_emploi
    FROM 
        epa_total et
    JOIN 
        secteurs s ON et.id_secteur = s.id_secteur
    WHERE 
        MONTH(et.date) IN (5, 6, 7, 8) -- Summer months
        AND et.id_region = 6 -- Québec
    GROUP BY 
        year, s.nom_secteur
),
non_summer_data AS (
    SELECT 
        YEAR(et.date) AS year,
        MONTH(et.date) AS month,
        s.nom_secteur,
        AVG(et.emploi) AS avg_non_summer_emploi
    FROM 
        epa_total et
    JOIN 
        secteurs s ON et.id_secteur = s.id_secteur
    WHERE 
        MONTH(et.date) NOT IN (5, 6, 7, 8) -- Non-summer months
        AND et.id_region = 6 -- Québec
    GROUP BY 
        year, month, s.nom_secteur
)
SELECT 
    ns.year AS année,
    ns.month AS mois,
    ns.nom_secteur AS secteur,
    sa.avg_summer_emploi AS pic_saisonnier_été,
    ns.avg_non_summer_emploi AS saison_hors_été,
    ROUND(((ns.avg_non_summer_emploi - sa.avg_summer_emploi) / sa.avg_summer_emploi), 2) AS variation_vs_summer_percent
FROM 
    non_summer_data ns
JOIN 
    summer_avg sa ON ns.year = sa.year AND ns.nom_secteur = sa.nom_secteur
ORDER BY 
    ns.year, ns.nom_secteur, ns.month;

-- YoY comparison of tourism employment by industry group / Variation annuelle de l'emploi en tourisme par sous-secteur

SELECT 
    YEAR(date) AS year,
    s.nom_secteur,
    AVG(emploi) AS total_emploi,
    LAG(AVG(emploi)) OVER (PARTITION BY s.nom_secteur ORDER BY YEAR(date)) AS prev_year_emploi,
    ROUND(AVG(emploi) - LAG(AVG(emploi)) OVER (PARTITION BY s.nom_secteur ORDER BY YEAR(date))) / LAG(AVG(emploi)) OVER (PARTITION BY s.nom_secteur ORDER BY YEAR(date)) AS yoy_variation
FROM 
    epa_total et
JOIN 
    secteurs s ON et.id_secteur = s.id_secteur
WHERE 
    id_region = 6 -- Quebec
GROUP BY 
    year, s.nom_secteur
ORDER BY 
    year DESC;

-- Tourism GDP compared to other industries / Comparaison du PIB touristique par rapport à d'autres industries

SELECT 
    p.date, 
    SUM(CASE WHEN p.id_secteur IN (35, 63) THEN p.pib ELSE 0 END) AS pib_tourisme, 
    SUM(CASE WHEN p.id_secteur = 1 THEN p.pib ELSE 0 END) AS pib_économie, 
    SUM(CASE WHEN p.id_secteur = 90 THEN p.pib ELSE 0 END) AS pib_services,
    (SUM(CASE WHEN p.id_secteur IN (35, 63) THEN p.pib ELSE 0 END) / 
     SUM(CASE WHEN p.id_secteur = 1 THEN p.pib ELSE 0 END)) AS tourisme_vs_économie,
    (SUM(CASE WHEN p.id_secteur IN (35, 63) THEN p.pib ELSE 0 END) / 
     SUM(CASE WHEN p.id_secteur = 90 THEN p.pib ELSE 0 END)) AS tourisme_vs_services
FROM pib p
GROUP BY p.date
ORDER BY p.date;
