-- add a boolean for dresser and armoire in items
ALTER TABLE items ADD COLUMN dresser_able boolean;
ALTER TABLE items ADD COLUMN armoire_able boolean;


-- Fix fishing weather condition table
DROP TABLE IF EXISTS fishing_weathers;
CREATE TABLE ffxiv.cbh_fish_weathers
(
    fishlid text REFERENCES items(lid),
    weather text REFERENCES weather(name),
    catches integer,
    PRIMARY KEY(fishlid, weather)
);
GRANT SELECT ON cbh_fish_weathers TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON cbh_fish_weathers TO ffxivrw;

-- Add cat-became-hungry ids to items and nodes for later reference
ALTER TABLE items ADD COLUMN cbhid INTEGER;
ALTER TABLE nodes ADD COLUMN cbhid INTEGER;

-- Rename fishing stuff to cbh to remember where it came from
ALTER TABLE fishing_hours RENAME TO cbh_fish_hours;
ALTER TABLE cbh_fish_hours RENAME CONSTRAINT fishing_hours_pkey TO cbh_fish_hours_pkey;
ALTER TABLE cbh_fish_hours RENAME CONSTRAINT fishing_hours_fishlid_fkey TO cbh_fish_hours_fishlid_fkey;

ALTER TABLE fishing_bait_tables RENAME TO cbh_node_tables;
ALTER TABLE cbh_node_tables RENAME CONSTRAINT fishing_bait_tables_pkey to cbh_node_tables_pkey;
ALTER TABLE cbh_node_tables RENAME CONSTRAINT fishing_bait_tables_baitlid_fkey to cbh_node_tables_baitlid_fkey;

drop view if exists cbh_best_bait;
drop table gathering; -- Cleanup, what was that anyway?

-- Replace view best_bait with functions
DROP FUNCTION IF EXISTS is_simple_catch(text, text);
CREATE OR REPLACE FUNCTION is_simple_catch(nodename text, fishlids text)
  RETURNS boolean AS
$$
DECLARE
    is_mooch boolean;
BEGIN
    -- if mooch only catch, all baits are fish at that node
    SELECT bool_and(baitlid in (select fishlid from cbh_node_tables as fbt where fbt.node=$1))
        INTO is_mooch
        from cbh_node_tables 
        where node=$1 and fishlid=$2 and catches <> 0;
    RETURN not is_mooch;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;

drop function if exists find_simple_catch_rate(text, text);
DROP FUNCTION IF EXISTS find_best_rate(text, text);
DROP TYPE IF EXISTS bait_trail;
CREATE TYPE bait_trail AS (trail json, rate real);

CREATE OR REPLACE FUNCTION find_simple_catch_rate(nodename text, fishlids text)
    RETURNS bait_trail AS
$$
DECLARE
    best_rate real;
    trail json;
BEGIN
    if not is_simple_catch($1, $2) then
        raise exception 'Fish with lid ''%'' is not a primary catch.', $2;
    end if;
    with bait_table as (
        select node, baitlid, fishlid, catches
        from cbh_node_tables
        where node=$1 and is_simple_catch($1, fishlid)
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
        select node, baitlid, fishlid, catches
        from cbh_node_tables
        where node=$1 and is_simple_catch($1, fishlid)
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
$$
LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION find_best_rate(nodename text, fishlids text)
  RETURNS bait_trail AS
$$
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
    FOR baits IN with bait_table as (
            select node, baitlid, fishlid, catches
            from cbh_node_tables
            where node=$1
            ), totals as (
                select baitlid, sum(catches) as total
                from bait_table
                group by baitlid
            )
            select bt.baitlid, fishlid, catches::numeric/total as rate
            from bait_table as bt
                join totals as t on bt.baitlid = t.baitlid
            WHERE fishlid = $2 AND fishlid <> bt.baitlid AND catches <> 0 LOOP
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
$$
LANGUAGE 'plpgsql' IMMUTABLE;

-- Make gathered_where mirror changes to cbh_node_tables
INSERT INTO gathered_where (node, itemlid)
SELECT DISTINCT node, fishlid FROM cbh_node_tables WHERE catches <> 0 
ON CONFLICT ON CONSTRAINT gathered_where_pkey DO NOTHING;

CREATE OR REPLACE FUNCTION add_fish_gw()
RETURNS trigger AS
$$
BEGIN
  INSERT INTO gathered_where (node, itemlid) VALUES (NEW.node, NEW.fishlid) ON CONFLICT ON CONSTRAINT gathered_where_pkey DO NOTHING;
  RETURN NEW;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

CREATE TRIGGER add_fish_gw_trigger BEFORE INSERT
  ON cbh_node_tables
  FOR EACH ROW
  EXECUTE PROCEDURE add_fish_gw();

CREATE OR REPLACE FUNCTION rem_fish_gw()
RETURNS trigger AS
$$
BEGIN
  DELETE FROM gathered_where WHERE node = OLD.node AND itemlid = OLD.fishlid;
  RETURN OLD;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

CREATE TRIGGER rem_fish_gw_trigger BEFORE DELETE
  ON cbh_node_tables
  FOR EACH ROW
  EXECUTE PROCEDURE rem_fish_gw();

-- More cleanup
DROP VIEW best_bait;
DROP TABLE baited_how_where;

-- Adjust get_node and dependents to use new functions rather than old best_bait view
CREATE OR REPLACE FUNCTION ffxiv.get_fishes(
	node text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
  select json_agg(get_item(fishlid))
  from
    (
	  select distinct fishlid
	  from cbh_node_tables
	  where node=$1
      order by fishlid
	) fishlids;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_baits(
	node text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
  select json_agg(get_item(baitlid))
  from 
	(
	  select distinct baitlid
	  from cbh_node_tables
	  where node=$1
	  order by baitlid) baitlids;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_fishing_table(
	node text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
with crossprod as
(
	select baitlid, fishlid
	from
		(
			(select distinct baitlid from cbh_node_tables where node=$1) a
			cross join
			(select distinct fishlid from cbh_node_tables where node=$1) b
		) t
	order by baitlid, fishlid
), bait_table as (
    select node, baitlid, fishlid, catches
    from cbh_node_tables
    where node=$1
), totals as (
    select baitlid, sum(catches) as total
    from bait_table
    group by baitlid
), node as (
    select bt.baitlid, fishlid, catches::numeric/total as rate
    from bait_table as bt
        join totals as t on bt.baitlid = t.baitlid
), twodee as
(
	select node, c.baitlid, c.fishlid, to_char(rate*100, 'FM990D00') as rate
	from node as bhw
		right join crossprod as c on bhw.baitlid = c.baitlid and bhw.fishlid = c.fishlid
	order by c.baitlid, c.fishlid
)
, onedee as
(
	select baitlid, json_agg(rate) as rates
	from twodee 
	group by baitlid
	order by baitlid
)
select json_agg(rates) as fishing_table
from onedee;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_best_baits(
	node text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
select json_object_agg(fishlid, bait) from
(
SELECT fishlid, json_build_object(
    'trail', (find_best_rate($1, fishlid)).trail,
    'rate', to_char((find_best_rate($1, fishlid)).rate*100, 'FM990D00')
) as bait
FROM (select distinct fishlid
from cbh_node_tables as cnt
where node=$1)a
)c;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_node(
	node text)
    RETURNS json
    LANGUAGE 'sql'
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
	'gathering', get_node_gathering(name),
	'fishes', get_fishes(name),
	'baits', get_baits(name),
	'fishing_table', get_fishing_table(name),
    'best_baits', get_best_baits(name)
)
FROM nodes AS n
WHERE name=$1
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_fish_conditions(
	fishlid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
select json_build_object(
	'hours', (
        select json_build_array(zero,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,sixteen,seventeen,eighteen,nineteen,twenty,twentyone,twentytwo,twentythree) as hours 
        from cbh_fish_hours
        where fishlid=$1),
	'weathers', (
        select json_agg(json_build_object(
            'weather', weather,
            'catches', catches
        ))
        from cbh_fish_weathers
        where fishlid=$1
    )
);
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
  SELECT json_build_object(
 'lid', i.lid,
    'licon', i.licon,
    'name', i.name,
    'category', get_category('Item'),
    'bonuses', get_item_bonuses(lid),
    'disciplines', get_item_disciplines(lid),
    'effects', get_item_effects(lid),
    'interests', get_item_interests(lid),
    'level', i.level,
    'g_rarity', i.g_rarity,
    'lcat2', i.lcat2,
    'lcat3', i.lcat3,
    'required_level', i.required_level,
    'is_unique', i.is_unique,
    'untradable', i.untradable,
    'advanced_melding', i.advanced_melding,
    'unsellable', i.unsellable,
    'market_prohibited', i.market_prohibited,
    'sell_price', i.sell_price,
    'note', i.note,
    'recast', i.recast,
    'damage', i.damage,
    'auto_attack', i.auto_attack,
    'delay', i.delay,
    'block_strength', i.block_strength,
    'block_rate', i.block_rate,
    'defense', i.defense,
    'magic_defense', i.magic_defense,
    'materia_slots', i.materia_slots,
    'repair_class', i.repair_class,
    'repair_level', i.repair_level,
    'repair_material', i.repair_material,
    'melding_class', i.melding_class,
    'melding_level', i.melding_level,
    'convertible', i.convertible,
    'desynth_class', i.desynth_class,
    'desynthesizable', i.desynthesizable,
    'dyeable', i.dyeable,
    'projectable', i.projectable,
    'crest_worthy', i.crest_worthy,
    'meld_ilvl', i.meld_ilvl,
    'fish_conditions', get_fish_conditions(i.lid)
  )
   FROM items i
   WHERE lid = $1
$BODY$;

-- TRIM GET_NODES so it doesn't take 5 seconds to execute...
DROP FUNCTION IF EXISTS get_item_nodes(text);
DROP FUNCTION IF EXISTS get_node_source(text, text);
DROP FUNCTION IF EXISTS get_source_nodes(text);

CREATE OR REPLACE FUNCTION ffxiv.get_item_nodes(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
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
            (find_best_rate(n.name, $1)).trail as trail,
            (find_best_rate(n.name, $1)).rate as rate
        FROM gathered_where AS gw
            join nodes as n on gw.node = n.name
        WHERE itemlid=$1
        ORDER BY rate DESC
    ) n
) a;
$BODY$;


-- Run ITEM LISTER HERE for fish pages -- 304-321
-- Run Fish lister