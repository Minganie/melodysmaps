CREATE TABLE gt_fishing_conditions (
	fishlid text REFERENCES items(lid) PRIMARY KEY,
	start_time int CHECK(start_time >= 0 AND start_time <= 24),
	end_time   int CHECK(start_time >= 0 AND start_time <= 24),
	snagging  boolean not null default false,
	folklore  boolean not null default false,
	fish_eyes boolean not null default false
);
GRANT SELECT ON gt_fishing_conditions TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON gt_fishing_conditions TO ffxivrw;

CREATE TABLE gt_fishing_weathers (
	fishlid text REFERENCES items(lid),
	weather text REFERENCES weather(name) ON UPDATE CASCADE,
	PRIMARY KEY (fishlid, weather)
);
GRANT SELECT ON gt_fishing_weathers TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON gt_fishing_weathers TO ffxivrw;

CREATE TABLE gt_fishing_transition(
	fishlid text REFERENCES items(lid),
	weather text REFERENCES weather(name) ON UPDATE CASCADE,
	PRIMARY KEY (fishlid, weather)
);
GRANT SELECT ON gt_fishing_transition TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON gt_fishing_transition TO ffxivrw;

CREATE TABLE gt_fishing_predator (
	goal_fish_lid text REFERENCES items(lid),
	prey_fish_lid text REFERENCES items(lid),
	prey_fish_n int check(prey_fish_n > 0),
	PRIMARY KEY (goal_fish_lid, prey_fish_lid)
);
GRANT SELECT ON gt_fishing_predator TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON gt_fishing_predator TO ffxivrw;