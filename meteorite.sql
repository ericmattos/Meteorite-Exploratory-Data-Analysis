-- First we will create the two tables where we'll load the data

DROP TABLE IF EXISTS meteorite_data;
CREATE TABLE meteorite_data (
name VARCHAR(255),
id INT PRIMARY KEY AUTO_INCREMENT,
nametype VARCHAR(255),
recclass VARCHAR(255),
mass DECIMAL(25, 15),
fall VARCHAR(255),
year integer null,
dummy varchar(1)
);

DROP TABLE IF EXISTS meteorite_location;
CREATE TABLE meteorite_location (
id INT PRIMARY KEY AUTO_INCREMENT,
reclat DECIMAL(8, 6),
reclong DECIMAL(9, 6),
geo_location VARCHAR(255),
dummy Varchar(1)
);

-- Now we load the data from the CSV files
-- The data was downloaded from https://data.nasa.gov/Space-Science/Meteorite-Landings/gh4g-9sfh, on 22/06/2022 at 15:49
-- We made two alterations on the file before loading it:
-- 1) We separated the downloaded CSV file in two files, meteorite_data and meteorite_location
--    meteorite_data contains the columns 'name', 'id', 'nametype', 'recclass', 'mass', 'fall' and 'year'
--    meteorite_location contains the columns 'id', 'reclat', 'reclong' and 'geo_location'
-- 2) We created an additional column at the end of both tables to correct errors, we eliminate these columns later

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/meteorite_data.csv' 
INTO TABLE meteorite_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(name, id, nametype, recclass, @mass, fall, @year, dummy)
SET
mass = NULLIF(@mass, ''),
year = NULLIF(@year,'');
ALTER TABLE meteorite_data DROP COLUMN dummy;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/meteorite_location.csv' 
INTO TABLE meteorite_location
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, @reclat, @reclong, geo_location, dummy)
SET
reclat = NULLIF(@reclat, ''),
reclong = NULLIF(@reclong, '');
ALTER TABLE meteorite_location DROP COLUMN dummy;

-- Suppose we want to know how many of the meteorites are missing their mass. We can find out using

SELECT COUNT(*)
FROM meteorite_data
WHERE mass IS NULL;

-- We now want to determine which of the meteorites had the highest mass and look at the columns 'name', 'id', 'mass', 'year' and 'geo_location'.
-- We will do this using a CTE (we'll see a simpler way of doing this later).

WITH cte_mass AS(
SELECT MAX(mass)
FROM meteorite_data
)
SELECT dat.name, dat.id, dat.mass, dat.year, loc.geo_location
FROM meteorite_data dat JOIN meteorite_location loc USING (id)
WHERE dat.mass = (SELECT * FROM cte_mass);

-- Consider now that we want this information for the second highest mass. We can do this using two temp tables.

DROP TABLE IF EXISTS first_mass;
CREATE TEMPORARY TABLE first_mass AS
SELECT MAX(mass)
FROM meteorite_data;
DROP TABLE IF EXISTS second_mass;
CREATE TEMPORARY TABLE second_mass AS
SELECT MAX(mass)
FROM meteorite_data
WHERE mass < (SELECT * FROM first_mass);
SELECT dat.name, dat.id, dat.mass, dat.year, loc.geo_location
FROM meteorite_data dat JOIN meteorite_location loc USING (id)
WHERE dat.mass = (SELECT * FROM second_mass);

-- Next, let us classify the meteorites based on their mass, classifying them as "heavy" if their mass is above the average and as "light" if it is below the average.
-- We will do this using the CASE command.

WITH avg_mass AS(
SELECT AVG(mass)
FROM meteorite_data
)
SELECT dat.name, dat.id, dat.mass, dat.year, loc.geo_location,
	CASE WHEN mass >= (SELECT * FROM avg_mass) THEN 'heavy' ELSE 'light' END AS 'mass_class'
FROM meteorite_data dat JOIN meteorite_location loc USING (id)
WHERE mass IS NOT NULL;

-- We can also count how many meteorites were assigned "light" and how many were assigned "heavy".

WITH avg_mass AS (
SELECT AVG(mass)
FROM meteorite_data
)
SELECT CASE WHEN mass >= (SELECT * FROM avg_mass) THEN 'heavy' ELSE 'light' END AS 'mass_class', COUNT(*)
FROM meteorite_data
WHERE mass IS NOT NULL
GROUP BY mass_class;

-- We now want to know how many meteorite are missing their year.

SELECT COUNT(*)
FROM meteorite_data
WHERE year IS NULL;

-- Consider now that we want information on the oldest meteorite in the database.
-- We can use a CTE, as we did before, but let us use a simpler method this time.

SELECT dat.name, dat.id, dat.mass, dat.year, loc.geo_location
FROM meteorite_data dat JOIN meteorite_location loc USING (id)
WHERE dat.year IS NOT NULL
ORDER BY year
LIMIT 1;

-- We can also obtain the second oldest meteorite combining this with a subquery.
-- This method can be easily generalised for the n-th oldest meteorite by replacing 2 by n.

SELECT *
FROM (
	SELECT dat.name, dat.id, dat.mass, dat.year, loc.geo_location
    FROM meteorite_data dat JOIN meteorite_location loc USING (id)
	WHERE dat.year IS NOT NULL
	ORDER BY year
	LIMIT 2
) bottom2
ORDER BY year DESC
LIMIT 1;

-- Now we will determine how many known meteorites there were per year.
-- We add the restriction "year <= 2022" because one of the meteorites was assigned the year 2101, which is obviously a mistake.

SELECT year, COUNT(*) AS 'number_of_meteorites'
FROM meteorite_data
WHERE year IS NOT NULL AND year <= 2022
GROUP BY year
ORDER BY year;

-- Finally, we will calculate, for the years between 2001 and 2010, which percentage of the meteorites of this period fell in each year.

SELECT year, 100 * COUNT(*) / SUM(COUNT(*)) OVER() AS 'meteorite_percentage'
FROM meteorite_data
WHERE year BETWEEN 2001 AND 2010
GROUP BY year
ORDER BY year;