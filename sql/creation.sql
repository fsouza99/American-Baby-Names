CREATE TYPE gender_symbol AS ENUM ('M', 'F');

CREATE TABLE names (
	name varchar(15),
	gender gender_symbol,
	occurences integer NOT NULL,
	year smallint,

	CONSTRAINT names_pk PRIMARY KEY (name, gender, year)
);

\COPY names FROM '../data/rel_common_names.csv' DELIMITER ',' HEADER;