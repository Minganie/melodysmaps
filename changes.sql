INSERT INTO immaterials (name, icon) VALUES ('Experience', 'https://img.finalfantasyxiv.com/lds/h/8/GShCUkaKnehhJU3Ox2t4wFSFc4.png');

-- split mobiles into npcs and enemies, cause npcs have one point, enemies have potentially several spawn polygons

-- npcs
CREATE TABLE npcs AS
SELECT
	lid,
	name,
	geom
FROM mobiles;
ALTER TABLE npcs ADD CONSTRAINT npcs_pkey PRIMARY KEY (lid);
GRANT SELECT ON npcs TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON npcs TO ffxivrw;

CREATE TABLE npc_available_quests (
	npc text REFERENCES npcs(lid),
	quest text REFERENCES quests(lid),
	PRIMARY KEY (npc, quest)
);
GRANT SELECT ON npc_available_quests TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON npc_available_quests TO ffxivrw;

CREATE TABLE npc_related_quests (
	npc text REFERENCES npcs(lid),
	quest text REFERENCES quests(lid),
	PRIMARY KEY (npc, quest)
);
GRANT SELECT ON npc_related_quests TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON npc_related_quests TO ffxivrw;

-- enemies
CREATE TABLE enemies AS
SELECT
	lid,
	name
FROM mobiles;
ALTER TABLE enemies ADD CONSTRAINT enemies_pkey PRIMARY KEY (lid);
GRANT SELECT ON enemies TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON enemies TO ffxivrw;

CREATE TABLE enemy_spawns (
	enemy text REFERENCES enemies(lid),
	zone text REFERENCES zones(name),
	minlevel int NOT NULL,
	maxlevel int NOT NULL,
	conditional boolean NOT NULL,
	PRIMARY KEY(enemy, zone)
);
GRANT SELECT ON enemy_spawns TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON enemy_spawns TO ffxivrw;

CREATE TABLE enemy_drops (
	enemy text REFERENCES enemies(lid),
	item text REFERENCES items(lid),
	PRIMARY KEY (enemy, item)
);
GRANT SELECT ON enemy_drops TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON enemy_drops TO ffxivrw;

CREATE TABLE enemy_related_duties (
	enemy text REFERENCES enemies(lid),
	duty text REFERENCES duties_each(lid),
	PRIMARY KEY (enemy, duty)
);
GRANT SELECT ON enemy_related_duties TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON enemy_related_duties TO ffxivrw;

-- transfer other tables/views to use npcs and enemies instead of mobiles
ALTER TABLE duty_encounter_bosses
	DROP CONSTRAINT duty_encounter_bosses_boss_fkey,
	ADD CONSTRAINT duty_encounter_bosses_boss_fkey FOREIGN KEY (boss) REFERENCES enemies (lid);
	
ALTER TABLE merchants
	DROP CONSTRAINT merchants_mobile_fkey,
	ADD CONSTRAINT merchants_mobile_fkey FOREIGN KEY (lid) REFERENCES npcs (lid);
	
ALTER TABLE quests
	DROP CONSTRAINT quests_quest_giver_fkey,
	ADD CONSTRAINT quests_quest_giver_fkey FOREIGN KEY (quest_giver) REFERENCES npcs (lid);

CREATE OR REPLACE VIEW ffxiv.vsearchables
 AS
 SELECT 0 AS id,
    items.lid,
    'Item'::text AS category,
    'Item'::text AS category_name,
    items.name,
    items.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM items
UNION
 SELECT regions.gid AS id,
    regions.lid,
    'Region'::text AS category,
    'Region'::text AS category_name,
    regions.name,
    regions.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM regions
UNION
 SELECT zones.gid AS id,
    zones.lid,
    'Zone'::text AS category,
    'Zone'::text AS category_name,
    zones.name,
    zones.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM zones
UNION
 SELECT areas.gid AS id,
    areas.lid,
    'Area'::text AS category,
    'Area'::text AS category_name,
    areas.name,
    areas.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM areas
UNION
 SELECT nodes.gid AS id,
    nodes.gid::text AS lid,
    'Fishing'::text AS category,
    'Fishing Hole'::text AS category_name,
    replace(replace(nodes.name, '<i>'::text, ''::text), '</i>'::text, ''::text) AS name,
    nodes.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM nodes
  WHERE nodes.category = 'Fishing'::text
UNION
 SELECT nodes.gid AS id,
    nodes.gid::text AS lid,
    'Spearfishing'::text AS category,
    'Spearfishing waters'::text AS category_name,
    replace(replace(nodes.name, '<i>'::text, ''::text), '</i>'::text, ''::text) AS name,
    nodes.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM nodes
  WHERE nodes.category = 'Spearfishing'::text
UNION
 SELECT nodes.gid AS id,
    nodes.gid::text AS lid,
    'Mining'::text AS category,
    'Mining Node'::text AS category_name,
    nodes.name,
    nodes.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM nodes
  WHERE nodes.category = 'Mining'::text
UNION
 SELECT nodes.gid AS id,
    nodes.gid::text AS lid,
    'Quarrying'::text AS category,
    'Quarrying Node'::text AS category_name,
    nodes.name,
    nodes.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM nodes
  WHERE nodes.category = 'Quarrying'::text
UNION
 SELECT nodes.gid AS id,
    nodes.gid::text AS lid,
    'Logging'::text AS category,
    'Logging Node'::text AS category_name,
    nodes.name,
    nodes.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM nodes
  WHERE nodes.category = 'Logging'::text
UNION
 SELECT nodes.gid AS id,
    nodes.gid::text AS lid,
    'Harvesting'::text AS category,
    'Harvesting Node'::text AS category_name,
    nodes.name,
    nodes.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM nodes
  WHERE nodes.category = 'Harvesting'::text
UNION
 SELECT 0 AS id,
    mm_mobiles.name AS lid,
    'Monster'::text AS category,
    'Monster'::text AS category_name,
    mm_mobiles.name,
    mm_mobiles.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM mm_mobiles
UNION
 SELECT 0 AS id,
    m.lid,
    'Merchant'::text AS category,
    'Merchant Stall'::text AS category_name,
    ((mm.name || ' ('::text) || (( SELECT z.name
           FROM zones z
          WHERE st_contains(z.geom, st_geometryn(mm.geom, 1))
         LIMIT 1))) || ')'::text AS name,
    mm.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM merchants m
     JOIN npcs mm ON m.lid = mm.lid
UNION
 SELECT xivdb_npcs.gid AS id,
    xivdb_npcs.gid::text AS lid,
    'npc'::text AS category,
    'NPC'::text AS category_name,
    ((xivdb_npcs.name || ' ('::text) || xivdb_npcs.zone) || ')'::text AS name,
    xivdb_npcs.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM xivdb_npcs
UNION
 SELECT vtrials.id,
    vtrials.lid,
    'Trial'::text AS category,
    'Trial'::text AS category_name,
    vtrials.name,
    vtrials.real_name,
    vtrials.mode,
    vtrials.sort_order
   FROM vtrials
UNION
 SELECT vdungeons.id,
    vdungeons.lid,
    'Dungeon'::text AS category,
    'Dungeon'::text AS category_name,
    vdungeons.name,
    vdungeons.real_name,
    vdungeons.mode,
    vdungeons.sort_order
   FROM vdungeons
UNION
 SELECT vraids.id,
    vraids.lid,
    'Raid'::text AS category,
    'Raid'::text AS category_name,
    vraids.name,
    vraids.real_name,
    vraids.mode,
    vraids.sort_order
   FROM vraids
UNION
 SELECT sightseeing.gid AS id,
    to_char(sightseeing.gid, 'FM000'::text) AS lid,
    'Sightseeing'::text AS category,
    'Sightseeing Entry'::text AS category_name,
    to_char(sightseeing.gid, 'FM000'::text) AS name,
    to_char(sightseeing.gid, 'FM000'::text) AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM sightseeing
UNION
 SELECT lm.gid AS id,
    lm.name AS lid,
    'Levemete'::text AS category,
    'Levemete'::text AS category_name,
    ((((((lm.name || ' ('::text) || (( SELECT z.name
           FROM zones z
          WHERE st_contains(z.geom, lm.geom)))) || ', '::text) || (( SELECT min(l.lvl) AS min
           FROM leves l
          WHERE l.levemete = lm.name))) || '-'::text) || (( SELECT max(l.lvl) AS max
           FROM leves l
          WHERE l.levemete = lm.name))) || ')'::text AS name,
    lm.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM levemetes lm
UNION
 SELECT l.gid AS id,
    l.name AS lid,
    'Leve'::text AS category,
    'Levequest'::text AS category_name,
    l.name,
    l.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM leves l
UNION
 SELECT 0 AS id,
    a.lid,
    'Quest'::text AS category,
    'Quest'::text AS category_name,
    a.name,
    a.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM quests a
UNION
 SELECT 0 AS id,
    r.lid,
    'Recipe'::text AS category,
    'Recipe'::text AS category_name,
    ((r.name || ' ('::text) || r.discipline) || ')'::text AS name,
    r.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM recipes r
  ORDER BY 6, 8;
GRANT SELECT ON vsearchables TO ffxivro;

-- clean up Lodestone vs xivdb vs mm
DROP TABLE IF EXISTS mobiles;
DROP FUNCTION IF EXISTS get_mobile;
DROP FUNCTION IF EXISTS get_mobile_zone_names;
DROP FUNCTION IF EXISTS get_mobile_zones;
DROP FUNCTION IF EXISTS get_npc;
DROP FUNCTION IF EXISTS get_npc_from_id;
CREATE OR REPLACE FUNCTION ffxiv.get_xivdb_npc(
	npc text)
    RETURNS json
    LANGUAGE 'plpgsql'
    STABLE 
AS $BODY$
DECLARE
    rep json;
    n int;
BEGIN
    SELECT count(*) FROM xivdb_npcs WHERE lower(name) like lower('%' || $1 || '%') INTO n;
    IF n=0 THEN 
        RAISE EXCEPTION 'ffxiv.get_npc=> Can''t find NPC with search term %', '%'||$1||'%';
    ELSEIF n>1 THEN 
        RAISE EXCEPTION 'ffxiv.get_npc=> More than two NPCs with search term %', '%'||$1||'%';
    ELSE
        SELECT json_build_object(
            'id', n.name,
            'lid', n.name,
            'name', n.name,
            'label', n.name,
            'category', get_category('npc'),
            'zone', get_zone((select lid from zones as z where st_contains(z.geom, n.geom))),
            'geom', get_vertices(n.geom),
            'bounds', get_bounds(n.geom),
            'centroid', get_centroid_coords(n.geom)
        )
        FROM xivdb_npcs as n
        WHERE lower(name) like lower('%' || $1 || '%') INTO rep;
    END IF;
    RETURN rep;
END;
$BODY$;
CREATE OR REPLACE FUNCTION ffxiv.get_xivdb_npc_from_id(
	npcgid integer)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT json_build_object(
    'id', n.name,
    'lid', n.name,
    'name', n.name,
    'label', n.name,
    'category', get_category('npc'),
    'zone', get_zone((select lid from zones as z where st_contains(z.geom, n.geom))),
    'geom', get_vertices(n.geom),
    'bounds', get_bounds(n.geom),
    'centroid', get_centroid_coords(n.geom)
)
FROM xivdb_npcs as n
WHERE gid = npcgid;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_npc_zones(
	lid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
select json_agg(coords)
from (
    select get_game_coords((st_dump(geom)).geom) as coords
    from npcs as m
    where m.lid=$1
)a;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_npc_zone_names(lid text)
    RETURNS text
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
select string_agg(zo->>'zone', ', ') 
from
(
    SELECT json_array_elements(get_npc_zones($1)) as zo
)a;
$BODY$;

CREATE FUNCTION get_npc(npclid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT row_to_json(a) FROM
(
	SELECT 
		0 as id,
		npcs.lid, 
		npcs.name, 
		npcs.name as label,
		get_category('npc') as category, 
		get_npc_zones(npcs.lid) as zones,
		get_npc_zone_names(npcs.lid) as zone_names,
		get_vertices(geom) as geom,
		get_bounds(geom) as bounds,
		get_centroid_coords(geom) as centroid,
		aq.aq as available_quests, 
		rq.rq as related_quests
	FROM
		npcs
	LEFT JOIN
		(
		SELECT n.lid, json_agg(aq.quest) as aq
		FROM npcs as n
			LEFT JOIN npc_available_quests as aq ON n.lid=aq.npc
		WHERE lid=$1
		GROUP BY n.lid
		) aq ON aq.lid = npcs.lid
	LEFT JOIN
		(
		SELECT n.lid, json_agg(rq.quest) as rq
		FROM npcs as n
			LEFT JOIN npc_related_quests as rq ON n.lid=rq.npc
		WHERE lid=$1
		GROUP BY n.lid
		) rq ON rq.lid = npcs.lid
	WHERE npcs.lid=$1
)a;
$BODY$;

CREATE FUNCTION get_enemy(enemylid text)
	RETURNS json
	LANGUAGE 'sql'
	STABLE 
AS $BODY$
SELECT row_to_json(a) 
FROM
(
	SELECT e.lid, e.name, 'Enemy' as category, ed.ed as enemy_drops, es.es as enemy_spawns
	FROM enemies as e
	LEFT JOIN (
		SELECT e.lid, json_agg(ed.enemy) as ed
		FROM enemies as e
			LEFT JOIN enemy_drops as ed ON e.lid=ed.enemy
		WHERE e.lid=$1
		GROUP BY e.lid
	) ed ON e.lid=ed.lid
	LEFT JOIN (
		SELECT e.lid, json_agg(es.enemy) as es
		FROM enemies as e
			LEFT JOIN enemy_spawns as es ON e.lid=es.enemy
		WHERE e.lid=$1
		GROUP BY e.lid
	) es ON e.lid=es.lid
	WHERE e.lid=$1
)a
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_merchant(
	merchantlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
select json_build_object(
	'id', 0::int,
	'lid', m.lid,
	'name', m.name,
	'label', m.name || ' (' || get_npc_zone_names($1) || ')',
	'category', get_category('Merchant'),
	'requirement', get_requirement(requires),
	'all_tabs', get_merchant_tabs(m.lid),
	'zone_names', get_npc_zone_names($1),
	'zones', get_npc_zones($1),
	'geom', get_vertices(geom),
	'bounds', get_bounds(geom),
	'centroid', get_centroid_coords(geom)
)
from merchants as s
    join npcs as m ON s.lid=m.lid
where s.lid=$1;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_quest(
	questlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$

with quest as (
	select * from quests where lid=$1
), 
rewards as 
(
	select questlid, 
		json_agg(rewards) as rewards 
	from (
		select 
			questlid, 
			(select row_to_json(_) from (select get_item(itemlid) as item, n, classjob as class_job, gender, optional) as _) as rewards
		from quest_rewards 
		where questlid=$1
	)a
	group by questlid
), 
other as 
(
	select questlid, 
		json_agg(reward) as other
	from (
		select questlid, (select row_to_json(_) from (select other, icon) as _) as reward
		from quest_rewards_others
		where questlid=$1
	)a
	group by questlid
), 
dreq as 
(
	select questlid, json_agg(requirements) as duty_requirements 
	from 
		(
			select $1, (select row_to_json(_) from (select t::text as type, lid, name, mode, level) as _) as requirements
			from duty_requirements as de
			where de.lid in (select dutylid
			from quest_duty_requirements 
			where questlid=$1)
		)a
	group by questlid
),
areq as
(
	select questlid, json_agg(requirements) as action_requirements
	from (
		select questlid, get_requirement(action) as requirements
		from quest_action_requirements
		where questlid=$1
	)a
	group by questlid
)

select (select row_to_json(_) from 
	(
	select q.lid, 
	q.name, 
	q.category as quest_category, 
	q.banner, 
	q.area, 
	q.zone, 
	q.quest_type, 
    get_npc(q.quest_giver) as quest_giver, 
	q.level, 
	q.level_requirement, 
	q.class_requirement, 
	q.gc, 
	q.gc_rank, 
	q.xp, 
    q.gil, 
	q.bt, 
	q.bt_currency_n, 
	get_immaterial(q.bt_currency) as bt_currency, 
	q.bt_reputation, 
	q.gc_seals, 
	q.starting_class, 
    get_immaterial(q.tomestones) as tomestones, 
	q.tomestones_n, 
	q.ventures, 
	q.seasonal, 
	r.rewards, 
	o.other, 
	dreq.duty_requirements, 
	areq.action_requirements
	) as _)
from quest as q
 left join rewards as r on q.lid=r.questlid
 left join other as o on q.lid=o.questlid
 left join dreq on q.lid=dreq.questlid
 left join areq on q.lid=areq.questlid
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_leve(
	name text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$

with mobs as
(
	select l.gid, json_agg(json_build_object(
		'n', lm.n, 
		'mob', lm.mob)) as mobs
	from leves as l
		left join leve_mobs as lm on l.gid = lm.leve
	where name=$1
	group by gid
), rewards as
(
	select l.gid, json_agg(json_build_object(
		'n', lr.n, 
		'item', get_item(lr.itemlid))) as rewards
	from leves as l
		left join leve_rewards as lr on l.gid = lr.leve
	where name=$1
	group by gid
)
select json_build_object(
	'gid', l.gid,
	'id', l.gid,
    'lid', l.name,
    'lvl', lvl,
    'name', name,
    'category', get_category('Leve'),
    'patch', patch,
    'xp', xp,
	'ixp', get_immaterial('Experience'),
    'gil', gil,
	'igil', get_immaterial('Gil'),
    'seals', seals,
    'description', description,
    'levemete_name', levemete,
    'job', job,
    'type', type,
	'gc', gc,
    'model', model,
    'wanted', wanted,
    'first_item', first_item,
    'second_item', second_item,
    'third_item', third_item,
    'fourth_item', fourth_item,
    'item', item,
    'n', n,
    'max_n_nodes', max_n_nodes,
    'real_item', get_item(itemlid),
    'mob', mob,
    'item_mob', item_mob,
    'target_mob', target_mob,
    'client', CASE WHEN client is null THEN null::json ELSE get_xivdb_npc(client) END,
	'mobs', m.mobs,
	'rewards', r.rewards
	)
from leves as l
	join mobs as m on l.gid = m.gid
	join rewards as r on l.gid = r.gid
where name=$1;

$BODY$;
