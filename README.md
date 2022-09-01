# Meteorite Exploratory Data Analysis with SQL

This is an exploratory data analysis project using SQL on a data set of meteorite landings.  Our goal was to extract information from this data set using MySQL. We used our knowledge of SQL tables, queries, subqueries, aggregate functions, CTEs and temporary tables to determine the heaviest and second heaviest meteorites, to find the oldest and second oldest of them, to label them based on how their mass compared with the average, to calculate the number of meteorites that fell in each year and to determine the percentage of meteorites that fell in each year over the course of a ten year period.

## 1. Introduction

The data set we will be working with accounts for all known meteorite landings, including their id, name, class, mass, year and coordinates. The data was downloaded from NASA’s website at https://data.nasa.gov/Space-Science/Meteorite-Landings/gh4g-9sfh at 15:49 (BRT) on 22/06/2022.

## 2. Preprocessing

Our first step is to split the downloaded *Meteorite_Landings.csv* file into two: *meteorite_data.csv* and *meteorite_location.csv*. The first one has the columns “name”, “id”, “nametype”, “recclass”, “mass”, “fall” and “year”, while the second one has the columns “id”, “raclat”, “reclong” and “geo_location”. We also add an empty “dummy” column to the end both tables to solve the error messages that appear when we try to import the data into MySQL. The reason we keep the “id” column on both files is that we will later use this attribute to join the two tables.

Next we must create the two tables in SQL and load the data from the CSV files into them. Note that we set “mass” and “year” to be null if their fields are empty. Finally, we drop the “dummy” columns now that we are done importing the data.

## 3. Exploratory Data Analysis

We are now ready to extract insights from the data. We will begin studying the “mass” attribute. Suppose, then, that we want to know how many of the meteorites have an empty “mass” field. We can do this using a simple IS NULL command, and obtain that 131 out of 45716 meteorites are missing their mass.

Next, let us determine the name, id, mass, year and geolocation of the meteorite with the highest mass. There are different ways we could do this, the one that we choose for now employs a CTE to select the highest mass and then uses it to select the desired attributes from the entry with that mass. We obtain that the meteorite with the highest mass is called Hoba and has a mass of 60000000 g.

Suppose that we also want to do this with the second highest mass. This can be done by employing two temporary tables, one for the highest mass and one for the second highest, and then selecting the desired attributes. We obtain that the meteorite with the second highest mass is called Cape York and has a mass of 58200000 g.

Now we want to classify the meteorites based on their mass, labeling them as them as “heavy” if their mass is above average and as “light” if it is below. This can be done simply using the CASE command. We can also determine how many meteorites were assigned each label using the COUNT aggregate function together with the GROUP BY command. We obtain that there are 44382 light meteorites and 1203 heavy ones.

Next, let us study the “year” attribute. Just as we did with “mass”, we can begin by counting how many meteorites have a null year. We obtain that 291 out of 45716 meteorites are missing their year.
We can proceed with determining which is the oldest meteorite in the data base. Instead of using a CTE, as we did with the “mass” column, we will simply use the ORDER BY command to get the table in ascending order and then limit it to one entry, leaving us with the lowest value for the year. We obtain that the oldest known meteorite was the Nogata, in the year 860.

We can use a similar method to discover the second oldest meteorite, where we use ORDER BY to get the entries in ascending order within a subquery (with only two entries) and in descending order in the main query (with only one entry). We obtain that the second oldest meteorite was the Narni, in 920. This method has the advantage of being easy to generalize to the n-th oldest meteorite by replacing “LIMIT 2” by “LIMIT n”.

Next, let us find out how many meteorites fell in each year. This is a direct application of the COUNT aggregate function. Note that we have to filter for only years before 2022, since one of the meteorites was mistakenly assigned the year 2101.

Finally, we can determine, for the years between 2001 and 2010, which percentage of the meteorites in this period fell in each year. This can be done by combining the COUNT and SUM aggregate functions wit the OVER command, to sum over all the counts in the period. The result is displayed in the table below.

| Year | Percentage |
| ----- | --------- |
| 2001 | 9.7230 |
| 2002 | 12.2451 |
| 2003 | 19.5816 |
| 2004 | 11.4319 |
| 2005 | 5.1562 |
| 2006 | 14.4726 |
| 2007 | 7.0065 |
| 2008 | 5.6394 |
| 2009 | 8.8214 |
| 2010 | 5.9222 |


## 4. Conclusion

Using SQL, we were able to extract a number of insights from the data. In this project we focused only in the “name”, “id”, “mass”, “year” and “geo_location” columns, giving special attention to “mass” and “year”.

We were able to determine the heaviest and second heaviest meteorites, to find the oldest and second oldest meteorites, to classify them based on their mass in relation to the average, to determine the number of meteorites that fell per year and to calculate the percentage of meteorites that fell per year in a ten year period.
