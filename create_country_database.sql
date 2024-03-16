DROP SCHEMA IF EXISTS country_db CASCADE;
DROP TYPE IF EXISTS t_or_f CASCADE;

CREATE SCHEMA IF NOT EXISTS country_db;

CREATE TABLE country_db.country (
	"Code" CHAR(3) PRIMARY KEY NOT NULL DEFAULT 'UNK',
	"Name" VARCHAR(255) NOT NULL DEFAULT '',
	"Code2" CHAR(2) UNIQUE NOT NULL DEFAULT '',
	"Capital" INT DEFAULT NULL,
	CHECK (length("Code") >= 3)
	);

	
CREATE TABLE country_db.city (
	"ID" INT PRIMARY KEY NOT NULL,
	"Name" VARCHAR(255) NOT NULL DEFAULT '',
	"CountryCode" CHAR(3) NOT NULL DEFAULT '',
	"District" VARCHAR(255) NOT NULL DEFAULT '',
	"Info" JSON DEFAULT NULL
	);

ALTER TABLE country_db.country ADD FOREIGN KEY ("Capital") REFERENCES country_db.city("ID");
	
CREATE TYPE country_db.t_or_f AS ENUM (
	'T',
	'F'
	);

CREATE TABLE country_db.countryLanguage (
	"CountryCode" CHAR(3) NOT NULL DEFAULT '',
	"Language" CHAR(30) NOT NULL DEFAULT '',
	"IsOfficial" country_db.t_or_f NOT NULL DEFAULT 'F',
	"Percentage" FLOAT NOT NULL DEFAULT 0.0,
	FOREIGN KEY ("CountryCode") REFERENCES country_db.country("Code"),
	PRIMARY KEY (
		"CountryCode",
		"Language"
		)
	);

CREATE INDEX indexCountryCode ON country_db.countryLanguage ("CountryCode");

CREATE SEQUENCE country_db.countryInfo_id;

CREATE TABLE country_db.countryinfo (
	"doc" JSON,
	"_id" VARCHAR(32) NOT NULL PRIMARY KEY DEFAULT nextval('countryInfo_id')
	);

ALTER SEQUENCE country_db.countryInfo_id OWNED BY country_db.countryinfo."_id";

