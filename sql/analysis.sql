-- Remember to cast parameters where smallints are necessary.

-- The k most frequent names of a gender.
CREATE FUNCTION query_top_names(
	target_gender gender_symbol) RETURNS TABLE(
		top_names varchar(15),
		associated_gender gender_symbol,
		total_occurences bigint) AS $$
BEGIN
	RETURN QUERY (
		SELECT name, gender, sum(occurences) as total
		FROM names
		WHERE gender = target_gender
		GROUP BY name, gender
		ORDER BY total DESC
		);
	RETURN;
END;
$$ LANGUAGE plpgsql;

-- The number of names of a gender used since some year that starts with some letter.
CREATE FUNCTION special_start_count(
	target_gender gender_symbol,
	start_char char,
	start_year smallint) RETURNS integer AS $$
BEGIN
	RETURN (
		SELECT count(*) FROM names
		WHERE gender = target_gender AND name LIKE CONCAT(start_char, '%') AND year >= start_year
		);
END;
$$ LANGUAGE plpgsql;

-- The most common name of each year.
CREATE FUNCTION query_annual_leaders(
	target_gender gender_symbol) RETURNS TABLE(
		year_of_exercise smallint,
		commonest_name varchar(15),
		gender_spec gender_symbol,
		total_occurences integer) AS $$
BEGIN
	RETURN QUERY (
		WITH aux AS (
			SELECT year, max(occurences) as occurences
			FROM names WHERE gender = target_gender
			GROUP BY year
			ORDER BY year ASC
			)
		SELECT year, name, gender, occurences
		FROM names NATURAL JOIN aux
		);
	RETURN;
END;
$$ LANGUAGE plpgsql;

-- Most times the annual commonnest name.
CREATE FUNCTION prevalent_annual_leader(
	target_gender gender_symbol) RETURNS TABLE(name varchar(15), leaderships bigint) AS $$
BEGIN
	RETURN QUERY(
		SELECT commonest_name, count(*) as cts
		FROM query_annual_leaders(target_gender)
		GROUP BY commonest_name
		ORDER BY cts DESC
		);
	RETURN;
END;
$$ LANGUAGE plpgsql;

-- Names that appear every year with a minimum occurence in a period of time.
CREATE FUNCTION query_recurrent_names(
	min_occur integer,
	start_year smallint,
	end_year smallint) RETURNS TABLE(recurrent_name varchar(15)) AS $$
BEGIN
	RETURN QUERY (
		WITH source AS (
				SELECT * FROM names
				WHERE (year >= start_year AND year <= end_year AND occurences >= min_occur)
			), aux AS (
				SELECT name, count(*) as count
				FROM source
				GROUP BY name
			)
		SELECT name FROM aux
		WHERE (count >= end_year - start_year + 1));
	RETURN;
END;
$$ LANGUAGE plpgsql;

-- Find major trends in a time period.
CREATE FUNCTION query_trends(
	start_year smallint,
	end_year smallint) RETURNS TABLE(trendy_name varchar(15), growth numeric) AS $$
BEGIN
	RETURN QUERY (
		WITH source AS (
			SELECT year, name, occurences
			FROM names JOIN query_recurrent_names(1, start_year::smallint, end_year::smallint) ON name = recurrent_name
			WHERE (year >= start_year AND year <= end_year)
			)
		SELECT name, trunc(regr_slope(occurences, year)::numeric, 2) as slope
		FROM source
		GROUP BY name
		ORDER BY slope DESC
		);
	RETURN;
END;
$$ LANGUAGE plpgsql;



