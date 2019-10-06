-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

DROP VIEW IF EXISTS vhunting_logs;
DROP TABLE IF EXISTS hunting_log_kills;
DROP TABLE IF EXISTS hunting_log_levels;
DROP TABLE IF EXISTS hunting_log_ranks;
DROP TABLE IF EXISTS hunting_logs;
CREATE TABLE hunting_logs(
	id serial PRIMARY KEY,
	name text NOT NULL UNIQUE,
	nranks int not null
);
GRANT SELECT ON hunting_logs TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON hunting_logs TO ffxivrw;
GRANT USAGE ON hunting_logs_id_seq TO ffxivro;

CREATE OR REPLACE FUNCTION hunting_logs_fkey()
 RETURNS trigger
 LANGUAGE 'plpgsql'
 AS $BODY$
 DECLARE
	n_disc int = 0;
	n_gc int = 0;
 BEGIN
	SELECT count(dowm.name) INTO n_disc FROM dowm WHERE dowm.name=NEW.name;
	SELECT count(gc.name) INTO n_gc FROM grand_companies AS gc WHERE gc.name=NEW.name;
	IF n_disc+n_gc <> 1 THEN
		RAISE EXCEPTION 'Found % disciplines or grand companies for %', (n_disc+n_gc), NEW.name;
	END IF;
	RETURN NEW;
 END;
 $BODY$;

CREATE TRIGGER hunting_logs_fkey
BEFORE INSERT OR UPDATE ON hunting_logs
FOR EACH ROW
EXECUTE FUNCTION hunting_logs_fkey();

CREATE TABLE hunting_log_ranks(
	id SERIAL PRIMARY KEY,
	hunting_log int NOT NULL REFERENCES hunting_logs(id),
	rank int NOT NULL,
	nlevels int,
	UNIQUE(hunting_log, rank)
);
GRANT SELECT ON hunting_log_ranks TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON hunting_log_ranks TO ffxivrw;
GRANT USAGE ON hunting_log_ranks_id_seq TO ffxivro;

CREATE OR REPLACE FUNCTION hunting_log_ranks_fkey()
	RETURNS trigger
 LANGUAGE 'plpgsql'
 AS $BODY$
 DECLARE
	_n int;
	_name text;
 BEGIN
	SELECT nranks INTO STRICT _n FROM hunting_logs WHERE id=NEW.hunting_log;
	SELECT name INTO STRICT _name FROM hunting_logs WHERE id=NEW.hunting_log;
	IF NOT (NEW.rank>0 AND NEW.rank <=_n) THEN
		RAISE EXCEPTION 'Rank % not allowed (% ranks for %)', NEW.rank, _n, _name;
	END IF;
	RETURN NEW;
 END;
 $BODY$;

CREATE TRIGGER hunting_log_ranks_fkey
BEFORE INSERT OR UPDATE ON hunting_log_ranks
FOR EACH ROW
EXECUTE FUNCTION hunting_log_ranks_fkey();

CREATE TABLE hunting_log_levels(
	id SERIAL PRIMARY KEY,
	hunting_log_rank int NOT NULL REFERENCES hunting_log_ranks(id),
	level int NOT NULL,
	xp int,
	UNIQUE (hunting_log_rank, level)
);
GRANT SELECT ON hunting_log_levels TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON hunting_log_levels TO ffxivrw;
GRANT USAGE ON hunting_log_levels_id_seq TO ffxivro;

DROP VIEW IF EXISTS zones_and_dungeons;
CREATE VIEW zones_and_dungeons AS
SELECT name
FROM zones
UNION
SELECT name
FROM duties
WHERE cat='Dungeon'
ORDER BY 1;

CREATE TABLE hunting_log_kills(
	hunting_log_level int NOT NULL REFERENCES hunting_log_levels(id),
	mob text NOT NULL REFERENCES mm_mobiles(name),
	n int check(n > 0),
	zone text,
	area text, -- would be nice to have a fkey, but my toponyms are not numerous enough
	PRIMARY KEY (hunting_log_level, mob)
);
GRANT SELECT ON hunting_log_kills TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON hunting_log_kills TO ffxivrw;

CREATE OR REPLACE FUNCTION hunting_log_kills_fkey()
	RETURNS trigger
 LANGUAGE 'plpgsql'
 AS $BODY$
 DECLARE
	_name text;
 BEGIN
	SELECT name INTO STRICT _name 
	FROM zones_and_dungeons 
	WHERE name=NEW.zone;
	RETURN NEW;
 END;
 $BODY$;
 
CREATE TRIGGER hunting_log_kills_fkey
BEFORE INSERT OR UPDATE ON hunting_log_kills
FOR EACH ROW
EXECUTE FUNCTION hunting_log_kills_fkey();

DROP VIEW IF EXISTS vhunting_log;
CREATE VIEW vhunting_logs AS
SELECT hl.name, hl.nranks, hlr.rank, hlr.nlevels, hll.level, hll.xp, hlk.n, hlk.mob, hlk.zone, hlk.area 
FROM hunting_log_kills as hlk
JOIN hunting_log_levels as hll on hlk.hunting_log_level = hll.id
JOIN hunting_log_ranks as hlr on hll.hunting_log_rank = hlr.id
JOIN hunting_logs as hl on hlr.hunting_log = hl.id
ORDER BY hl.name, hlr.rank, hll.level;