DROP TABLE IF EXISTS gathering_log_locations;
DROP TABLE IF EXISTS gathering_log;

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
	area text REFERENCES areas(name),
	level int NOT NULL,
	limited boolean NOT NULL DEFAULT false,
	PRIMARY KEY (gl, region, zone, area, level)
);
GRANT SELECT ON gathering_log_locations TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON gathering_log_locations TO ffxivrw;