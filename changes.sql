DROP TABLE IF EXISTS gathering_log_locations;
DROP TABLE IF EXISTS gathering_log;
DROP TABLE IF EXISTS toponyms;

CREATE TABLE gathering_log(
	lid text PRIMARY KEY,
	cat2 text NOT NULL,
	cat3 text NOT NULL,
	item text NOT NULL REFERENCES items(lid),
	level int NOT NULL,
	nstars int NOT NULL DEFAULT 0,
	hidden boolean NOT NULL DEFAULT false
);
GRANT SELECT ON gathering_log TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON gathering_log TO ffxivrw;

CREATE TABLE gathering_log_locations(
	gl text REFERENCES gathering_log(lid),
	region text REFERENCES regions(name),
	zone text REFERENCES zones(name),
	place text,
	level int NOT NULL,
	limited boolean NOT NULL DEFAULT false,
	PRIMARY KEY (gl, region, zone, place, level)
);
GRANT SELECT ON gathering_log_locations TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON gathering_log_locations TO ffxivrw;

CREATE OR REPLACE FUNCTION check_req_toponym ()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _n int;
BEGIN
    SELECT count(name) INTO STRICT _n FROM toponyms WHERE name=NEW.place;
    IF _n = 0 THEN
        RAISE NO_DATA_FOUND USING MESSAGE = 'No toponym found for ' || NEW.place;
    END IF;
    RETURN NEW;
END;
$BODY$;

CREATE TRIGGER check_req_toponym
    BEFORE INSERT OR UPDATE
    ON gathering_log_locations
    FOR EACH ROW EXECUTE PROCEDURE check_req_toponym();

CREATE TABLE toponym_pins (
    name text PRIMARY KEY,
    geom geometry(Point, 4326) NOT NULL
);
CREATE INDEX toponym_pins_gix ON toponym_pins USING gist (geom);
GRANT SELECT ON toponym_pins TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON toponym_pins TO ffxivrw;

CREATE TABLE toponym_others (
    name text PRIMARY KEY,
    geom geometry(Point, 4326) NOT NULL
);
CREATE INDEX toponym_others_gix ON toponym_others USING gist (geom);
GRANT SELECT ON toponym_others TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON toponym_others TO ffxivrw;

CREATE TABLE toponym_floating (
    name text PRIMARY KEY,
    geom geometry(Polygon, 4326) NOT NULL
);
CREATE INDEX toponym_floating_gix ON toponym_floating USING gist (geom);
GRANT SELECT ON toponym_floating TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON toponym_floating TO ffxivrw;

CREATE OR REPLACE VIEW toponyms AS
SELECT name, 'Area'::text, st_centroid(geom) as geom FROM areas
UNION
SELECT name, 'Chocobo'::text, geom as geom FROM chocobos
UNION
SELECT name, 'Duty'::text, geom FROM duties
UNION
SELECT name, 'Subzone'::text, st_centroid(geom) as geom FROM invis_zones
UNION
SELECT name, 'Region'::text, st_centroid(geom) as geom FROM regions
UNION
SELECT name, 'Settlement'::text, geom FROM settlements
UNION
SELECT name, 'Zone'::text, st_centroid(geom) as geom FROM zones
UNION
SELECT name, 'Pin'::text, geom FROM toponym_pins
UNION
SELECT name, 'Other'::text, geom FROM toponym_others
UNION
SELECT name, 'Floating'::text, st_centroid(geom) FROM toponym_floating;
GRANT SELECT ON toponyms TO ffxivro;