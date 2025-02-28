/*

Exploring labour market data in SQL queries

/*

-- Job vacancies in tourism industry groups (NAICS) / Postes vacants dans les secteurs associés au tourisme (SCIAN)
-- (Canada, Québec, Ontario, & Colombie-Britannique)

SELECT
	date,
    nom_region AS 'Région',
    nom_secteur AS 'Secteur',
    postes_vacants AS 'Postes vacants'
    
FROM pv_secteurs pvs

JOIN regions r
ON pvs.id_region = r.id_region

JOIN secteurs s
ON pvs.id_secteur = s.id_secteur

WHERE code_scian IN (71, 711, 712, 713, 72, 721, 722) AND
pvs.id_region IN (1, 2, 3, 4) AND
date BETWEEN '2018-01-01' AND '2024-12-31';

-- Average hourly wages by tourism-related occupations (NOC) / Moyenne du salaire horaire par professions afférentes au tourisme (CNP) 
-- (Canada, Québec, Ontario, & Colombie-Britannique)

SELECT
	date,
    nom_region AS 'Région',
    nom_profession AS 'Profession',
    salaire_horaire AS 'Moyenne du salaire horaire'
    
FROM salaire_professions sp

JOIN regions r
ON sp.id_region = r.id_region

JOIN professions p
ON sp.id_profession = p.id_profession

WHERE sp.id_profession != 1 AND
sp.id_region IN (1, 2, 3, 4) AND
date BETWEEN '2018-01-01' AND '2024-12-31';
