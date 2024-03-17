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


-- 8. Stwórz zapytanie zwracające wszystkie wartości pola 
-- „GovernmentForm” (countryinfo) bez powtórzeń
SELECT DISTINCT ci.doc -> 'government' ->> 'GovernmentForm' government_form
FROM lista4.countryinfo ci;


-- 9. Stwórz zapytanie wypisujące najczęściej występującą wartość w bazie dla pola „Continent” (countryinfo)
SELECT ci.doc -> 'geography' ->> 'Continent' continent,
    count(*) counter
FROM lista4.countryinfo ci
GROUP BY continent
ORDER BY counter DESC
LIMIT 1;


-- 10. Stwórz zapytanie wypisujące nazwy państw wraz z wartością IndepYear w kolejności malejącej
-- po polu „IndepYear” (countryinfo)
SELECT ci.doc ->>'Name' country_name,
    ((ci.doc ->> 'IndepYear')::int) indep_year
FROM lista4.countryinfo ci
WHERE (ci.doc ->> 'IndepYear')::int IS NOT NULL 
ORDER BY indep_year DESC;


-- 11. Stwórz zapytanie wypisujące języki oraz ilokrotnie są językami urzędowymi w kolejności malejącej
SELECT lan language,
	count(lan2) official_counter
FROM (
	SELECT DISTINCT cl."Language" lan
	FROM lista4.countrylanguage cl
	)
LEFT JOIN (
	SELECT cl."Language" lan2
	FROM lista4.countrylanguage cl
	WHERE cl."IsOfficial" = 'T'
	) ON lan2 = lan
GROUP BY language
ORDER BY official_counter DESC;


-- 12. Stwórz zapytanie wypisujące języki oraz ilość ludzi posługujących 
-- się nimi na całym świecie w kolejności malejącej
SELECT
    lan language,
    sum(pp_using_lan_locally) people_using_lan_globally
FROM (
     SELECT 
        code,
        lan,
        round(percentage * population) AS pp_using_lan_locally
     FROM (
         SELECT cl."CountryCode" code,
            cl."Language" lan,
            (cl."Percentage")::FLOAT / 100 AS percentage,
            (ci.doc -> 'demographics' ->> 'Population')::int population
        FROM lista4.countrylanguage cl
        INNER JOIN lista4.countryinfo ci ON cl."CountryCode" = ci.doc ->> '_id'
     )
)
GROUP BY language
ORDER BY people_using_lan_globally DESC;


-- 13. Stwórz zapytanie wypisujące kraje które znajdują się w pierwszej dwudziestce pod względem
-- długości życia oraz jednocześnie znajdują się w pierwszej dwudziestce krajów z największą
-- wartością GNP
SELECT name1 AS country_name,
    life_expectancy,
    gnp
FROM (
    SELECT ci.doc ->> 'Name' name1,
        (ci.doc -> 'demographics' ->> 'LifeExpectancy')::float life_expectancy
    FROM lista4.countryinfo ci
    WHERE ci.doc -> 'demographics' ->> 'LifeExpectancy' IS NOT NULL 
    ORDER BY life_expectancy DESC
    LIMIT 20
)
INNER JOIN (
    SELECT ci.doc ->> 'Name' name2,
        (ci.doc ->> 'GNP')::float gnp
    FROM lista4.countryinfo ci
    ORDER BY gnp DESC
    LIMIT 20
) ON name1 = name2
ORDER BY country_name;
