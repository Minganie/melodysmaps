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

CREATE OR REPLACE FUNCTION ffxiv.get_fish_conditions(
	fishlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
WITH conds AS (
	SELECT fishlid, start_time, end_time, snagging, folklore, fish_eyes
	FROM gt_fishing_conditions
	WHERE fishlid=$1
), prev_w AS (
	SELECT fishlid, json_agg(weather) as prev_weathers
	FROM gt_fishing_transition
	WHERE fishlid=$1
	GROUP BY fishlid
), cur_w AS (
	SELECT fishlid, json_agg(weather) as curr_weathers
	FROM gt_fishing_weathers
	WHERE fishlid=$1
	GROUP BY fishlid
), pred AS (
	SELECT fishlid, json_agg(predator) as predator
	FROM (
		SELECT goal_fish_lid as fishlid, 
			json_build_object(
				'prey', get_item(prey_fish_lid), 
				'n', prey_fish_n
			) as predator
		FROM gt_fishing_predator
		WHERE goal_fish_lid=$1
	) a
	GROUP BY fishlid
)
SELECT row_to_json(a) 
FROM 
(
	SELECT conds.fishlid, start_time, end_time, snagging, folklore, fish_eyes, prev_weathers, curr_weathers, predator
	FROM conds
		LEFT JOIN prev_w ON conds.fishlid = prev_w.fishlid
		LEFT JOIN cur_w ON conds.fishlid = cur_w.fishlid
		LEFT JOIN pred ON conds.fishlid = pred.fishlid
)a;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item_nodes(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT json_agg(node)
FROM (
    SELECT json_build_object(
        'gid', n.gid,
        'category', n.category,
        'level', n.level,
        'name', n.name,
		'zone', (select zones.name from zones where st_contains(zones.geom, n.zegeom)),
        'requirement', n.requirement,
        'geom', n.geom,
        'bounds', bounds,
        'centroid', centroid,
        'trail', trail,
        'rate', to_char(rate*100, 'FM990D00')
    ) as node
    FROM (
        SELECT n.gid,
            get_category(n.category) as category,
            n.level,
            n.name,
			n.geom as zegeom,
            get_requirement(n.requires) as requirement,
            get_vertices(n.geom) as geom,
            get_bounds(n.geom) as bounds,
            get_centroid_coords(n.geom) as centroid,
            (find_best_rate(n.gid, $1)).trail as trail,
            (find_best_rate(n.gid, $1)).rate as rate
        FROM gathered_where AS gw
            join nodes as n on gw.nodegid = n.gid
        WHERE itemlid=$1
        ORDER BY rate DESC
    ) n
) a;
$BODY$;