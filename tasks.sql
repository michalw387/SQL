-- 1. Wypełnij bazę wartościami znajdującymi się w pliku "insert_country.sql”


-- 2. Stwórz zapytanie zwracające nazwę kraju, jego stolicę, wartość „GNP” (countryinfo) dla kraju z
-- największą wartością „GNP”
SELECT country."Name" country_name,
	city."Name" capital,
	countryinfo.doc ->> 'GNP' gnp
FROM lista4.country country
INNER JOIN lista4.city city ON city."ID" = country."Capital"
INNER JOIN lista4.countryinfo countryinfo ON countryinfo.doc ->> '_id' = country."Code"
WHERE (countryinfo.doc ->> 'GNP')::FLOAT = (
		SELECT max((ci.doc ->> 'GNP')::FLOAT)
		FROM lista4.countryinfo ci
		);


-- 3. Stwórz zapytanie zwracające minimalne, maksymalne oraz średnie „GNP” dla każdego z
-- kontynentów
SELECT countryinfo.doc -> 'geography' ->> 'Continent' continent,
	max((countryinfo.doc ->> 'GNP')::FLOAT) max_gnp,
	min((countryinfo.doc ->> 'GNP')::FLOAT) min_gnp,
	avg((countryinfo.doc ->> 'GNP')::FLOAT) avg_gnp
FROM lista4.countryinfo countryinfo
GROUP BY countryinfo.doc -> 'geography' ->> 'Continent';


-- 4. Stwórz zapytanie zwracające wszystkie miasta znajdujące się w regionie: North America
-- (countryinfo)
SELECT city."Name",
	countryinfo.doc -> 'geography' ->> 'Region' region
FROM lista4.countryinfo countryinfo
INNER JOIN lista4.city city ON countryinfo.doc ->> '_id' = city."CountryCode"
WHERE countryinfo.doc -> 'geography' ->> 'Region' = 'North America';


-- 5. Stwórz zapytanie zwracające listę nazw państw dla których wartość pola „HeadOfState” zawiera
-- w sobie „Elisabeth”
SELECT countryinfo.doc ->> 'Name' country,
	countryinfo.doc -> 'government' ->> 'HeadOfState' head_of_state
FROM lista4.countryinfo countryinfo
WHERE countryinfo.doc -> 'government' ->> 'HeadOfState' LIKE '%Elisabeth%';


-- 6. Stwórz zapytanie zwracające ilość państw znajdujących się na każdym z kontynentów
SELECT countryinfo.doc -> 'geography' ->> 'Continent' continent,
	count(countryinfo.doc -> '_id') country_counter
FROM lista4.countryinfo countryinfo
GROUP BY continent;


-- 7. Stwórz zapytanie zwracające nazwy 10 państw z największą oraz 10 państw z najmniejszą
-- wartością pola LifeExpectancy (countryinfo)
(
    SELECT countryinfo.doc ->> 'Name' country_name,
    	countryinfo.doc -> 'demographics' ->> 'LifeExpectancy' life_expectancy
    FROM lista4.countryinfo countryinfo
    WHERE countryinfo.doc ->  'demographics' ->> 'LifeExpectancy' IS NOT NULL
    ORDER BY countryinfo.doc -> 'demographics' ->> 'LifeExpectancy' DESC 
    LIMIT 10
)
UNION
(
    SELECT countryinfo.doc ->> 'Name' country_name,
    	countryinfo.doc -> 'demographics' ->> 'LifeExpectancy' life_expectancy
    FROM lista4.countryinfo countryinfo
    WHERE countryinfo.doc -> 'demographics' ->> 'LifeExpectancy' IS NOT NULL
    ORDER BY countryinfo.doc -> 'demographics' ->> 'LifeExpectancy' 
    LIMIT 10
)
ORDER BY life_expectancy DESC;


