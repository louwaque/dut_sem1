-- requetes simples

-- 1
SELECT *
FROM tp1_bd_voyage.client

-- 2
SELECT *
FROM tp1_bd_voyage.client
WHERE categorie = 'PRIVILEGIE'

-- 3
SELECT nom, prenom
FROM tp1_bd_voyage.client
WHERE ville = 'MARSEILLE'

-- 4
SELECT nom
FROM tp1_bd_voyage.client
WHERE ville = 'MARSEILLE' AND prenom LIKE '%R%'

-- 5
SELECT R.numcl, idv
FROM tp1_bd_voyage.client C
INNER JOIN tp1_bd_voyage.reservation R ON C.numcl = R.numcl
WHERE '2003-03-01' <= dateres AND dateres <= '2004-01-01'
-- ou
SELECT R.numcl, idv
FROM tp1_bd_voyage.client C
INNER JOIN tp1_bd_voyage.reservation R ON C.numcl = R.numcl
WHERE dateres BETWEEN '2003-03-01' AND '2004-01-01'

-- 6
SELECT idv, duree
FROM tp1_bd_voyage.voyage
WHERE voyage.paysarr = 'MAROC'
INTERSECT
SELECT idv, duree
FROM tp1_bd_voyage.voyage
WHERE hotel = 'ANTIQUE'

-- 7
SELECT villedep
FROM tp1_bd_voyage.voyage
WHERE paysarr = 'MAROC'

-- 8
SELECT *
FROM tp1_bd_voyage.optionv
WHERE libelle LIKE '%VISITE%'

-- 9
SELECT datedep
FROM tp1_bd_voyage.planning
WHERE idv = 927 AND datedep BETWEEN '2004-06-01' AND '2004-07-30'
ORDER BY datedep DESC

-- 10
SELECT numcl, nom, prenom
FROM tp1_bd_voyage.client
WHERE ville != 'PARIS' AND ville != 'MARSEILLE'
ORDER BY numcl
-- ou
SELECT numcl, nom, prenom
FROM tp1_bd_voyage.client
EXCEPT
SELECT numcl, nom, prenom
FROM tp1_bd_voyage.client
WHERE ville = 'PARIS'
EXCEPT
SELECT numcl, nom, prenom
FROM tp1_bd_voyage.client
WHERE ville = 'MARSEILLE'
ORDER BY numcl
-- ou
SELECT numcl, nom, prenom
FROM tp1_bd_voyage.client
EXCEPT
SELECT numcl, nom, prenom
FROM tp1_bd_voyage.client
WHERE ville IN ('PARIS','MARSEILLE')
ORDER BY numcl
-- ou
SELECT numcl, nom, prenom
FROM tp1_bd_voyage.client
WHERE ville NOT IN ('PARIS','MARSEILLE')
ORDER BY numcl

-- 11
SELECT numcl, nom
FROM tp1_bd_voyage.client
WHERE adresse IS NULL

-- sous requetes et operateurs ensemblistes

-- 1
SELECT V.idv, villearr
FROM tp1_bd_voyage.voyage V
INNER JOIN tp1_bd_voyage.planning P ON V.idv = P.idv
WHERE tarif = (
  SELECT MIN(tarif)
  FROM tp1_bd_voyage.planning
)
-- ou

-- 2
SELECT villearr, tarif
FROM tp1_bd_voyage.voyage V
INNER JOIN tp1_bd_voyage.planning P ON V.idv = P.idv
GROUP BY V.idv, villearr, tarif
HAVING tarif >= ALL(
  SELECT tarif
  FROM tp1_bd_voyage.voyage V
  INNER JOIN tp1_bd_voyage.planning P ON V.idv = P.idv
)

-- 3
SELECT villedep
FROM tp1_bd_voyage.voyage
INTERSECT
SELECT ville
FROM tp1_bd_voyage.client
-- ou
SELECT DISTINCT villedep
FROM tp1_bd_voyage.voyage V
INNER JOIN tp1_bd_voyage.client C ON V.villedep = C.ville

-- 4
SELECT O.libelle
FROM tp1_bd_voyage.optionv O
INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
WHERE V.idv = 354 AND O.libelle IN (
  SELECT DISTINCT O.libelle
  FROM tp1_bd_voyage.optionv O
  INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
  INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
  WHERE V.idv = 952
)
-- ou
SELECT O.libelle
FROM tp1_bd_voyage.optionv O
INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
WHERE V.idv = 354
INTERSECT
SELECT O.libelle
FROM tp1_bd_voyage.optionv O
INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
WHERE V.idv = 952

-- 5
SELECT V.idv, V.villedep, V.paysarr
FROM tp1_bd_voyage.voyage V
EXCEPT
SELECT V.idv, V.villedep, V.paysarr
FROM tp1_bd_voyage.voyage V
INNER JOIN tp1_bd_voyage.planning P ON V.idv = P.idv
INNER JOIN tp1_bd_voyage.reservation R ON P.idv = R.idv AND P.datedep = R.datedep
ORDER BY V.idv
-- ou
SELECT V.idv, V.villedep, V.paysarr
FROM tp1_bd_voyage.voyage V
WHERE idv NOT IN (
  SELECT V.idv
  FROM tp1_bd_voyage.voyage V
  INNER JOIN tp1_bd_voyage.planning P ON V.idv = P.idv
  INNER JOIN tp1_bd_voyage.reservation R ON P.idv = R.idv AND P.datedep = R.datedep
)
ORDER BY V.idv
-- ou
SELECT V.idv, V.villedep, V.paysarr
FROM tp1_bd_voyage.voyage V
WHERE idv <> ALL (
  SELECT V.idv
  FROM tp1_bd_voyage.voyage V
  INNER JOIN tp1_bd_voyage.planning P ON V.idv = P.idv
  INNER JOIN tp1_bd_voyage.reservation R ON P.idv = R.idv AND P.datedep = R.datedep
)
ORDER BY V.idv

-- 6
SELECT O.libelle
FROM tp1_bd_voyage.optionv O
INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
WHERE V.idv = 354 AND C.prix IS NULL
UNION
SELECT O.libelle
FROM tp1_bd_voyage.optionv O
INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
WHERE V.idv = 952 AND C.prix IS NOT NULL
-- ou
SELECT O.libelle
FROM tp1_bd_voyage.optionv O
INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
WHERE (V.idv = 354 AND C.prix IS NULL) OR (V.idv = 952 AND C.prix IS NOT NULL)

-- 7
SELECT V.idv, V.villearr
FROM tp1_bd_voyage.optionv O
INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
WHERE O.libelle = 'VISITE GUIDEE'
INTERSECT
SELECT V.idv, V.villearr
FROM tp1_bd_voyage.optionv O
INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
WHERE O.libelle = 'PISCINE'
-- ou
SELECT V.idv, V.villearr
FROM tp1_bd_voyage.optionv O
INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
WHERE O.libelle = 'VISITE GUIDEE' AND V.idv IN (
  SELECT V.idv
  FROM tp1_bd_voyage.optionv O
  INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
  INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
  WHERE O.libelle = 'PISCINE'
)

-- 8
SELECT C.nom, C.prenom
FROM tp1_bd_voyage.client C
EXCEPT
SELECT C.nom, C.prenom
FROM tp1_bd_voyage.client C
INNER JOIN tp1_bd_voyage.reservation R ON C.numcl = R.numcl
-- ou
SELECT C.nom, C.prenom
FROM tp1_bd_voyage.client C
WHERE C.numcl NOT IN (
  SELECT C.numcl
  FROM tp1_bd_voyage.client C
  INNER JOIN tp1_bd_voyage.reservation R ON C.numcl = R.numcl
)
-- ou

-- 9
SELECT V.villearr, V.paysarr
FROM tp1_bd_voyage.voyage V
EXCEPT
SELECT V.villearr, V.paysarr
FROM tp1_bd_voyage.voyage V
WHERE villedep = 'MARSEILLE'

-- 10
SELECT *
FROM tp1_bd_voyage.optionv
EXCEPT
SELECT O.code, O.libelle
FROM tp1_bd_voyage.optionv O
INNER JOIN tp1_bd_voyage.carac C ON O.code = C.code
INNER JOIN tp1_bd_voyage.voyage V ON C.idv = V.idv
WHERE V.paysarr = 'CHYPRE'

-- 11
SELECT DISTINCT hotel
FROM tp1_bd_voyage.voyage
WHERE nbetoiles = (
  SELECT MAX(nbetoiles)
  FROM tp1_bd_voyage.voyage
)

-- 12
SELECT paysarr
FROM tp1_bd_voyage.voyage
EXCEPT
SELECT DISTINCT paysarr
FROM tp1_bd_voyage.voyage
WHERE hotel IN (
  SELECT DISTINCT hotel
  FROM tp1_bd_voyage.voyage
  WHERE nbetoiles = (
    SELECT MAX(nbetoiles)
    FROM tp1_bd_voyage.voyage
  )
)

-- 13
SELECT paysarr, COUNT(hotel) AS "NB hotel"
FROM tp1_bd_voyage.voyage
WHERE paysarr IN (
  SELECT DISTINCT paysarr
  FROM tp1_bd_voyage.voyage
  WHERE nbetoiles = (
    SELECT MAX(nbetoiles)
    FROM tp1_bd_voyage.voyage
  )
)
GROUP BY paysarr