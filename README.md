## American Baby Names

### Intro

This project employs PostgreSQL to analyze a dataset about American baby names seeking the following information:

- *Names with high usage for over 100 years.*
- *Trends on different time periods.*
- *The top 10 male/female names.*
- *The most popular male/female name starting with a certain letter since some year.*
- *The most popular male/female names by year.*
- *The most popular male/female name for the largest number of years.*

The idea came from a Datacamp's [article](https://www.datacamp.com/blog/sql-projects-for-all-levels) about good projects to practice PostgreSQL.

### Dataset

The dataset was obtained from [Social Security](https://www.ssa.gov/oact/babynames/limits.html) website on March 23, 2024.

The downloaded pack consisted of one text file for every year between 1880 and 2022, presenting a CSV-like layout with 3 columns and no headers:

	> Mary,F,7065
	> Anna,F,2604
	> Emma,F,2003
	> ...

## Project

### A Python helper

We run some preparing Python procedures before getting into SQL. They are all available in the *helper.py* script.

As previously said, the dataset gives us one text file for every year in the 1822-2022 period. We put everything into a single CSV file by running the *assemble()* function.

Since we're investigating the most frequently used American names, the least used can be discarded without harming our goals. This undersampling might be obtained by two distinct functions described in *helper.py*.

Only the data used in the following tests were uploaded into the *data* folder. If you download the complete data and want to run *helper.py*, put all the content into *data/raw* before doing it.

### Creating database objects

Once the data for the study has been defined, we start the database by running *createdb*, a PostgreSQL command:

	> createdb american_names

After accessing the database from root directory, we get into the *sql* folder and run the available scripts in order to create the the database objects:

	american_names=# \cd sql
	american_names=# \i creation.sql
	CREATE TYPE
	CREATE TABLE
	COPY 104189
	american_names=# \i analysis.sql
	CREATE FUNCTION
	CREATE FUNCTION
	CREATE FUNCTION
	CREATE FUNCTION
	CREATE FUNCTION
	CREATE FUNCTION

The 104,189 copied instances are from *data/rel_common_names.csv*, generated by *helper.py*.

### Answering questions about the dataset

The functions in *sql/analysis.sql* offer answers to our previous questions about the data.

#### *Names with high usage for over 100 years*

We can see that 45 names had at least 1000 occurences in every year between 1922 and 2022:

	> american_names=# select count(*) from query_recurrent_names(1000, 1922::smallint, 2022::smallint);
	 count
	-------
	    45
	(1 row)

Five of these names are:

	> american_names=# select * from query_recurrent_names(1000, 1922::smallint, 2022::smallint) limit 5;
	 recurrent_name
	----------------
	 Andrew
	 Anna
	 Anthony
	 Benjamin
	 Calvin
	(5 rows)

#### *Trends on different time periods*

We can query the names with highest linear growth in a time period. So, how about the 21st century?

	> american_names=# select * from query_trends(2001::smallint, 2022::smallint) limit 5;
	 trendy_name | growth
	-------------+---------
	 Liam        | 1049.96
	 Oliver      |  797.49
	 Charlotte   |  711.26
	 Harper      |  665.46
	 Amelia      |  596.71
	(5 rows)

Let's see the 2011-2020 decade:

	> american_names=# select * from query_trends(2011::smallint, 2020::smallint) limit 5;
	 trendy_name | growth
	-------------+---------
	 Oliver      | 1088.75
	 Harper      |  975.11
	 Mateo       |  854.72
	 Luna        |  852.52
	 Theodore    |  832.52
	(5 rows)

This function considers only the names that appear every year in the appointed time period.

#### *The top 10 male/female names*

Top 10 male names:

	> american_names=# select top_names, total_occurences from query_top_names('M') limit 10;
	 top_names | total_occurences
	-----------+------------------
	 James     |          5214844
	 John      |          5158428
	 Robert    |          4838129
	 Michael   |          4393742
	 William   |          4167487
	 David     |          3654723
	 Joseph    |          2647283
	 Richard   |          2572740
	 Charles   |          2417569
	 Thomas    |          2338310
	(10 rows)

The female part can be found by running this same function, but passing 'F' as argument instead of 'M'.

#### *The number of male/famale names starting with some letter since any year*

The number of male names starting with "Y" in the 21st century.

	> american_names=# select * from special_start_count('M', 'Y', 2001::smallint);
	 special_start_count
	---------------------
	                  52
	(1 row)

#### *The most popular male/female names by year*

The most popular female names in the 1980's:

	> american_names=# select year_of_exercise, commonest_name, total_occurences from query_annual_leaders('F') where year_of_exercise >= 1980 limit 10;
	 year_of_exercise | commonest_name | total_occurences
	------------------+----------------+------------------
	             1980 | Jennifer       |            58381
	             1981 | Jennifer       |            57048
	             1982 | Jennifer       |            57119
	             1983 | Jennifer       |            54350
	             1984 | Jennifer       |            50561
	             1985 | Jessica        |            48346
	             1986 | Jessica        |            52682
	             1987 | Jessica        |            55996
	             1988 | Jessica        |            51552
	             1989 | Jessica        |            47889
	(10 rows)

Amongst the male names, Michael dominated the entire decade.

#### *The most popular male/female name for the largest number of years*

John and Michael are the male names that most oftenly appeared as annual leaders:

	> american_names=# select * from prevalent_annual_leader('M');
	  name   | leaderships
	---------+-------------
	 John    |          44
	 Michael |          44
	 Robert  |          17
	 Jacob   |          14
	 James   |          13
	 Liam    |           6
	 Noah    |           4
	 David   |           1
	(8 rows)

And Mary is by far the female champion of this metric:

	> american_names=# select * from prevalent_annual_leader('F');
	   name   | leaderships
	----------+-------------
	 Mary     |          76
	 Jennifer |          15
	 Emily    |          12
	 Jessica  |           9
	 Lisa     |           8
	 Linda    |           6
	 Emma     |           6
	 Olivia   |           4
	 Sophia   |           3
	 Ashley   |           2
	 Isabella |           2
	(11 rows)




