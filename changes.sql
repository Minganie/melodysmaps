-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

-- make hunting logs consistent with the rest
CREATE OR REPLACE FUNCTION get_hunting_logs()
	RETURNS json
	LANGUAGE SQL
	STABLE
AS $BODY$
select json_object_agg(name, ranks) 
from (
	select name, json_object_agg(rank, kills) as ranks 
	from (
		select name, rank, json_agg(mob) as kills
		from (
			SELECT 
				name, 
				rank, 
				json_build_object(
					'name', mob,
					'geom', get_vertices(geom),
					'bounds', get_bounds(geom),
					'centroid', get_centroid_coords(geom)
				) as mob
			FROM (
				select hl.name, hl.rank, hl.level, hl.mob, a.geom
				from vhunting_logs as hl
				join (
					select mmumob.name, st_union(geom) as geom
					from mob_spawns as ms
					join mm_unique_mobiles as mmumob ON ms.mmumob=mmumob.id
					group by mmumob.name
				)a on a.name=hl.mob
				order by hl.name, hl.level
			) As lg
			order by name, rank
		)r
		group by name, rank
		order by name, rank
	)s
	group by name
	order by name
)u;
$BODY$;

-- change searchables to put gid as lid instead of name
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
    nodes.name,
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
    nodes.name,
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
     JOIN mobiles mm ON m.lid = mm.lid
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
GRANT SELECT ON TABLE ffxiv.vsearchables TO ffxivro;

-- CBH node tables
ALTER TABLE cbh_node_tables
	ADD COLUMN nodegid bigint REFERENCES nodes(gid);
UPDATE cbh_node_tables AS cnt
	SET nodegid = n.gid
FROM nodes as n
	WHERE cnt.node = n.name;
ALTER TABLE cbh_node_tables
	DROP CONSTRAINT cbh_node_tables_pkey,
	ADD CONSTRAINT cbh_node_tables_pkey PRIMARY KEY (nodegid, baitlid, fishlid),
	DROP COLUMN node;
-- CBH node tables related functions
CREATE OR REPLACE FUNCTION ffxiv.find_best_rate(
	nodegid bigint,
	fishlids text)
    RETURNS bait_trail
    LANGUAGE 'plpgsql'
    STABLE 
AS $BODY$
DECLARE
    rate real := 0;
    hq_rate real := 0.1;
    baits RECORD;
    tmp real;
    trails jsonb := '[]';
BEGIN
    IF is_simple_catch($1, $2) THEN
        rate := (find_simple_catch_rate($1, $2)).rate;
        trails := trails || (find_simple_catch_rate($1, $2)).trail::jsonb;
    END IF;
    FOR baits IN with 
			bait_table as (
				select cnt.nodegid, baitlid, fishlid, catches
				from cbh_node_tables as cnt
				where cnt.nodegid=$1
            ), totals as (
                select baitlid, sum(catches) as total
                from bait_table
                group by baitlid
            )
            select bt.baitlid, fishlid, catches::numeric/total as rate
            from bait_table as bt
                join totals as t on bt.baitlid = t.baitlid
            WHERE fishlid = $2 AND fishlid <> bt.baitlid AND catches <> 0
	LOOP
        IF is_simple_catch($1, baits.baitlid) THEN
            tmp := (find_simple_catch_rate($1, baits.baitlid)).rate*hq_rate*baits.rate;
            IF tmp > rate THEN
                rate := tmp;
                trails := get_item(baits.baitlid)::jsonb || (find_simple_catch_rate($1, baits.baitlid)).trail::jsonb;
            END IF;
        ELSE 
            tmp := (find_best_rate($1, baits.baitlid)).rate*hq_rate*baits.rate;
            IF tmp > rate THEN
                rate := tmp;
                trails := get_item(baits.baitlid)::jsonb || (find_best_rate($1, baits.baitlid)).trail::jsonb;
            END IF;
        END IF;
    END LOOP;
    RETURN (trails::json, rate);
END;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.find_simple_catch_rate(
	nodegid bigint,
	fishlids text)
    RETURNS bait_trail
    LANGUAGE 'plpgsql'
    STABLE 
AS $BODY$
DECLARE
    best_rate real;
    trail json;
BEGIN
    if not is_simple_catch($1, $2) then
        raise exception 'Fish with lid ''%'' is not a primary catch.', $2;
    end if;
    with bait_table as (
        select cnt.nodegid, baitlid, fishlid, catches
        from cbh_node_tables as cnt
        where cnt.nodegid=$1 and is_simple_catch($1, fishlid)
    ), totals as (
        select baitlid, sum(catches) as total
        from bait_table
        group by baitlid
        having sum(catches) > 0
    ), rates as (
        select bt.baitlid, fishlid, catches::numeric/total as rate
        from bait_table as bt
            join totals as t on bt.baitlid = t.baitlid
    ), maxes as (
        select fishlid, max(rate) as rate
        from rates
        group by fishlid
    )
    select rate 
        into best_rate
    from maxes 
    where fishlid=$2;
    
    with bait_table as (
        select cnt.nodegid, baitlid, fishlid, catches
        from cbh_node_tables as cnt
        where cnt.nodegid=$1 and is_simple_catch($1, fishlid)
    ), totals as (
        select baitlid, sum(catches) as total
        from bait_table
        group by baitlid
        having sum(catches) > 0
    ), rates as (
        select bt.baitlid, fishlid, catches::numeric/total as rate
        from bait_table as bt
            join totals as t on bt.baitlid = t.baitlid
    ), maxes as (
        select fishlid, max(rate) as rate
        from rates
        group by fishlid
    )
    select get_item(baitlid)
        into trail
    from rates as r
        join maxes as m on r.rate=m.rate
    where r.fishlid=$2
    limit 1;
    RETURN (json_build_array(trail), best_rate);
END;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_baits(
	nodegid bigint)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
  select json_agg(get_item(baitlid))
  from 
(
   select distinct baitlid
   from cbh_node_tables
   where nodegid=$1
   order by baitlid) baitlids;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_best_baits(
	nodegid bigint)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
select json_object_agg(fishlid, bait)
from
	(
		SELECT fishlid, json_build_object(
			'trail', (find_best_rate($1, fishlid)).trail,
			'rate', to_char((find_best_rate($1, fishlid)).rate*100, 'FM990D00')
		) as bait
		FROM (
			select distinct fishlid
			from cbh_node_tables as cnt
			where nodegid=$1
		)a
	)c;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_fishes(
	nodegid bigint)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
select json_agg(get_item(fishlid))
from
(
	select distinct fishlid
	from cbh_node_tables
	where nodegid=$1
	order by fishlid
) fishlids;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_fishing_table(
	nodegid bigint)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$ 
with crossprod as ( 	
	select baitlid, fishlid
 	from 		
	( 			
		(select distinct baitlid from cbh_node_tables where nodegid=$1) a 			cross join 			
		(select distinct fishlid from cbh_node_tables where nodegid=$1) b 		
	) t 	
	order by baitlid, fishlid 
), bait_table as (
	select nodegid, baitlid, fishlid, catches
	from cbh_node_tables
	where nodegid=$1 
), totals as (
    select baitlid, sum(catches) as total
    from bait_table
    group by baitlid
), node as (
    select bt.baitlid, fishlid, catches::numeric/total as rate
    from bait_table as bt
	join totals as t on bt.baitlid = t.baitlid
), twodee as (
 	select nodegid, c.baitlid, c.fishlid, to_char(rate*100, 'FM990D00') as rate
 	from node as bhw
	right join crossprod as c on bhw.baitlid = c.baitlid and bhw.fishlid = c.fishlid
 	order by c.baitlid, c.fishlid
), onedee as (
 	select baitlid, json_agg(rate) as rates
 	from twodee
  	group by baitlid
 	order by baitlid 
) 
select json_agg(rates) as fishing_table from onedee; 
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.is_simple_catch(
	nodegid bigint,
	fishlids text)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    STABLE 
AS $BODY$
DECLARE
    is_mooch boolean;
BEGIN
    -- if mooch only catch, all baits are fish at that node
    SELECT bool_and(baitlid in (select fishlid from cbh_node_tables as fbt where fbt.nodegid=$1))
        INTO is_mooch
        from cbh_node_tables as cnt
        where cnt.nodegid=$1 and fishlid=$2 and catches <> 0;
    RETURN not is_mooch;
END;
$BODY$;

	
-- Gathered where
ALTER TABLE gathered_where
	ADD COLUMN nodegid bigint REFERENCES nodes(gid);
UPDATE gathered_where AS gw
	SET nodegid = n.gid
FROM nodes as n
	WHERE gw.node = n.name;
ALTER TABLE gathered_where
	DROP CONSTRAINT gathered_where_pkey,
	ADD CONSTRAINT gathered_where_pkey PRIMARY KEY (nodegid, itemlid),
	DROP COLUMN node;
-- Gathered where related functions
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

CREATE OR REPLACE FUNCTION ffxiv.get_node_gathering(
	nodegid bigint)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
  SELECT json_agg(get_item(itemlid))
  FROM gathered_where
  WHERE nodegid=$1;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_node(
	nodegid bigint)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT json_build_object(
 'gid', n.gid,
 'category', get_category(n.category),
 'level', n.level,
 'name', n.name,
 'requirement', get_requirement(n.requires),
 'geom', get_vertices(n.geom),
 'bounds', get_bounds(n.geom),
 'centroid', get_centroid_coords(n.geom),
 'gathering', get_node_gathering(gid),
 'fishes', get_fishes(gid),
 'baits', get_baits(gid),
 'fishing_table', get_fishing_table(gid),
 'best_baits', get_best_baits(gid)
)
FROM nodes AS n
WHERE gid=$1
$BODY$;

-- Where treasures	
ALTER TABLE where_treasures
	ADD COLUMN nodegid bigint REFERENCES nodes(gid);
UPDATE where_treasures AS wt
	SET nodegid = n.gid
FROM nodes as n
	WHERE wt.node = n.name;
ALTER TABLE where_treasures
	DROP CONSTRAINT where_treasures_pkey,
	ADD CONSTRAINT where_treasures_pkey PRIMARY KEY (nodegid, treasure),
	DROP COLUMN node;
-- treasured_where related functions
CREATE OR REPLACE FUNCTION ffxiv.get_item_maps(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT json_agg(json_build_object(
	'map', map,
	'nodes', nodes
))
FROM (
	SELECT tw.node as map,
		json_agg(get_node(wt.nodegid)) as nodes
	FROM treasured_where AS tw
		JOIN where_treasures AS wt ON tw.node = wt.treasure
	WHERE tw.itemlid=$1
	GROUP BY tw.node
) as nodes
$BODY$;

-- finally, nodes themselves
ALTER TABLE nodes
	DROP CONSTRAINT nodes_name_key,
	ADD CONSTRAINT nodes_name_key UNIQUE (category, name);

-- and because you changed the function parameter type... gnnnrrrhhhhhnnnn
DROP FUNCTION IF EXISTS find_best_rate(int, text);
DROP FUNCTION IF EXISTS find_best_rate(text, text);
DROP FUNCTION IF EXISTS find_simple_catch_rate(int, text);
DROP FUNCTION IF EXISTS find_simple_catch_rate(text, text);
DROP FUNCTION IF EXISTS get_baits(int);
DROP FUNCTION IF EXISTS get_baits(text);
DROP FUNCTION IF EXISTS get_best_baits(text);
DROP FUNCTION IF EXISTS get_best_baits(int);
DROP FUNCTION IF EXISTS get_fishes(text);
DROP FUNCTION IF EXISTS get_fishes(int);
DROP FUNCTION IF EXISTS get_fishing_table(text);
DROP FUNCTION IF EXISTS get_fishing_table(int);
DROP FUNCTION IF EXISTS get_node(text);
DROP FUNCTION IF EXISTS get_node_gathering(text);
DROP FUNCTION IF EXISTS is_simple_catch(int, text);
DROP FUNCTION IF EXISTS is_simple_catch(text, text);