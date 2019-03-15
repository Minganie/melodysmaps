-- new duty mode after normal, hard, extreme and savage
insert into modes (name, sort_order) values ('Ultimate', 3);

-- now duties have a banner image from Lodestone
alter table duties_each add column banner_url text;

-- lid is the real unique id of these things, make it mandatory
alter table duties_each alter column lid set not null;
-- Oh, and fix your bugs, too.
DROP TRIGGER add_duty_lid ON ffxiv.duties_each;
CREATE TRIGGER add_duty_lid
    AFTER INSERT
    ON ffxiv.duties_each
    FOR EACH ROW
    EXECUTE PROCEDURE ffxiv.add_lid();

DROP TRIGGER replace_duty_lid ON ffxiv.duties_each;
CREATE TRIGGER replace_duty_lid
    AFTER UPDATE 
    ON ffxiv.duties_each
    FOR EACH ROW
    EXECUTE PROCEDURE ffxiv.replace_lid();
	
alter table hests rename to guildhests;
DROP TRIGGER add_hest_lid ON ffxiv.guildhests;
CREATE TRIGGER add_hest_lid
    AFTER INSERT
    ON ffxiv.guildhests
    FOR EACH ROW
    EXECUTE PROCEDURE ffxiv.add_lid();

DROP TRIGGER replace_hest_lid ON ffxiv.guildhests;
CREATE TRIGGER replace_hest_lid
    AFTER UPDATE 
    ON ffxiv.guildhests
    FOR EACH ROW
    EXECUTE PROCEDURE ffxiv.replace_lid();
	
DROP TRIGGER add_pvp_lid ON ffxiv.pvps;
CREATE TRIGGER add_pvp_lid
    AFTER INSERT
    ON ffxiv.pvps
    FOR EACH ROW
    EXECUTE PROCEDURE ffxiv.add_lid();
	
DROP TRIGGER replace_pvp_lid ON ffxiv.pvps;
CREATE TRIGGER replace_pvp_lid
    AFTER UPDATE 
    ON ffxiv.pvps
    FOR EACH ROW
    EXECUTE PROCEDURE ffxiv.replace_lid();
		
-- adjust dependent table to make use of lid rather than (name, mode)
-- chests
alter table duty_chests add column duty_ref text references duties_each (lid);
update duty_chests as dc set duty_ref=de.lid
from duties_each as de
where dc.duty = de.name and dc.mode = de.mode;
alter table duty_chests alter column duty_ref set not null;
alter table duty_chests drop constraint duty_chests_duty_fkey;
alter table duty_chests drop column duty;
alter table duty_chests drop column mode;
alter table duty_chests rename column duty_ref to duty;
alter table duty_chests add constraint duty_chests_ukey unique (duty, x, y);
-- boss encounters
alter table duty_bosses add column duty_ref text references duties_each (lid);
update duty_bosses as db set duty_ref=de.lid
from duties_each as de
where db.duty = de.name and db.mode = de.mode;
alter table duty_bosses alter column duty_ref set not null;
-- make boss loot and boss tokens ref the gid of the encounter instead of duty name+mode+boss, otherwise can't drop constraint
-- loot
alter table duty_boss_loot add column boss_ref int references duty_bosses (gid);
update duty_boss_loot as dbl set boss_ref = db.gid
  from duty_bosses as db
  where dbl.duty = db.duty and dbl.mode = db.mode and dbl.boss = db.name;
alter table duty_boss_loot alter column boss_ref set not null;
alter table duty_boss_loot add constraint duty_boss_loot_ukey unique(boss_ref, itemlid);
alter table duty_boss_loot drop constraint duty_boss_loot_duty_fkey;
alter table duty_boss_loot drop column duty, drop column mode, drop column boss;
alter table duty_boss_loot rename column boss_ref to boss;
-- tokens
alter table duty_boss_tokens add column boss_ref int references duty_bosses (gid);
update duty_boss_tokens as dbt set boss_ref = db.gid
  from duty_bosses as db
  where dbt.duty = db.duty and dbt.mode = db.mode and dbt.boss = db.name;
alter table duty_boss_tokens alter column boss_ref set not null;
alter table duty_boss_tokens add primary key (boss_ref, token);
alter table duty_boss_tokens drop constraint duty_boss_tokens_duty_fkey;
alter table duty_boss_tokens drop column duty, drop column mode, drop column boss;
alter table duty_boss_tokens rename column boss_ref to encounter;
-- drop derelict constraints on duty_bosses
alter table duty_bosses drop constraint duty_bosses_duty_mode_name_key;
alter table duty_bosses drop column duty;
alter table duty_bosses drop column mode;
alter table duty_bosses rename column duty_ref to duty;
alter table duty_bosses drop column lid;
-- duty maps
alter table duty_maps add column duty_ref text references duties_each (lid);
update duty_maps as dm set duty_ref = de.lid
  from duties_each as de
  where dm.duty = de.name and dm.mode = de.mode;
alter table duty_maps alter column duty_ref set not null;
alter table duty_maps drop constraint duty_maps_duty_mode_name_key;
alter table duty_maps drop constraint duty_maps_duty_fkey;
-- geez, seriously. unify duty_map names
UPDATE duty_maps SET name='The Second Coil of Bahamut - Turn 1 (Savage)' WHERE name='The Second Coil of Bahamut - Turn 1' AND mode='Savage';
UPDATE duty_maps SET name='The Second Coil of Bahamut - Turn 2 (Savage)' WHERE name='The Second Coil of Bahamut - Turn 2' AND mode='Savage';
UPDATE duty_maps SET name='The Second Coil of Bahamut - Turn 3 (Savage)' WHERE name='The Second Coil of Bahamut - Turn 3' AND mode='Savage';
UPDATE duty_maps SET name='The Second Coil of Bahamut - Turn 3 Lower Decks (Savage)' WHERE name='The Second Coil of Bahamut - Turn 3 Lower Decks' AND mode='Savage';
UPDATE duty_maps SET name='The Second Coil of Bahamut - Turn 3 Main Decks (Savage)' WHERE name='The Second Coil of Bahamut - Turn 3 Main Decks' AND mode='Savage';
UPDATE duty_maps SET name='The Second Coil of Bahamut - Turn 3 Upper Decks (Savage)' WHERE name='The Second Coil of Bahamut - Turn 3 Upper Decks' AND mode='Savage';
UPDATE duty_maps SET name='The Second Coil of Bahamut - Turn 4 (Savage)' WHERE name='The Second Coil of Bahamut - Turn 4' AND mode='Savage';
alter table duty_maps add constraint duty_maps_ukey unique (name);

alter table duty_maps drop column duty, drop column mode;
alter table duty_maps rename column duty_ref to duty;
-- duty trash
alter table duty_trash_drops add column duty_ref text references duties_each (lid);
update duty_trash_drops as dtd set duty_ref = de.lid
  from duties_each as de
  where dtd.duty = de.name and dtd.mode = de.mode;
alter table duty_trash_drops alter column duty_ref set not null;
alter table duty_trash_drops add constraint duty_trash_drops_ukey unique(duty_ref, itemlid);
alter table duty_trash_drops drop constraint duty_trash_drops_pkey;
alter table duty_trash_drops drop constraint duty_trash_drops_duty_fkey;
alter table duty_trash_drops drop column duty, drop column mode;
alter table duty_trash_drops rename column duty_ref to duty;
	

-- boss -> encounter
create table mobile_types (
	name text primary key
);
grant select on mobile_types to ffxivro;
grant insert, update, delete on mobile_types to ffxivrw;
insert into mobile_types values ('Enemy');
create table mobiles (
	lid text primary key,
	name text not null,
	category text not null references mobile_types(name),
	geom geometry(Point, 4326) not null
);
grant select on mobiles to ffxivro;
grant insert, update, delete on mobiles to ffxivrw;
comment on table mobiles IS 'Counterpart to Lodestone''s NPC: enemies and npc (i.e. quest giver, etc)';

alter table duty_bosses rename to duty_encounters;
-- make duty encounters recognizable from Lodestone to Mel's Maps db
alter table duty_encounters add column boss_names_ctrl text;
alter table duty_encounters add column encounter_index integer check (encounter_index >= 0);
alter table duty_encounters add constraint duty_encounters_ukey unique (duty, encounter_index);
create table duty_encounter_bosses (
	encounter int references duty_encounters (gid),
	boss text references mobiles(lid),
	primary key (encounter, boss)
);
grant select on duty_encounter_bosses to ffxivro;
grant insert, update, delete on duty_encounter_bosses to ffxivrw;

alter table duty_boss_loot rename to duty_encounter_loot;
alter table duty_boss_tokens rename to duty_encounter_tokens;
alter table duty_encounter_loot rename column boss to encounter;

-- Duty maps... now sucking less!
CREATE TABLE duty_map_rasters(
	rid serial primary key,
	rast raster,
	filename text unique not null,
	dutylid text not null
);
GRANT SELECT ON duty_map_rasters TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON duty_map_rasters TO ffxivrw;

-- Find duty lid from file name, something like 'Amdapor Keep Third Floor (Hard)_georeferenced.png'
CREATE OR REPLACE FUNCTION find_which_duty()
	RETURNS trigger
	LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE difficulty text;
	BEGIN
		SELECT regexp_replace(NEW.filename, '_georeferenced.png', '') INTO STRICT NEW.filename;
		CASE
			WHEN position('Hard' in NEW.filename) IS NOT NULL AND position('Hard' in NEW.filename) <> 0 THEN difficulty = 'Hard';
			WHEN position('Extreme' in NEW.filename) IS NOT NULL AND position('Extreme' in NEW.filename) <> 0 THEN difficulty = 'Extreme';
			WHEN position('Savage' in NEW.filename) IS NOT NULL AND position('Savage' in NEW.filename) <> 0 THEN difficulty = 'Savage';
			WHEN position('Ultimate' in NEW.filename) IS NOT NULL AND position('Ultimate' in NEW.filename) <> 0 THEN difficulty = 'Ultimate';
			ELSE difficulty = 'Regular';
		END CASE;
		SELECT lid INTO STRICT NEW.dutylid FROM duties_each WHERE mode=difficulty AND NEW.filename LIKE name || '%';
	RETURN NEW;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE EXCEPTION 'Can''t find "%" (%)', NEW.filename, difficulty;
		WHEN TOO_MANY_ROWS THEN
			RAISE EXCEPTION 'More than one duty for "%" (%)', NEW.filename, difficulty;
	END;
$BODY$;
CREATE TRIGGER set_duty_lid
	BEFORE INSERT
	ON duty_map_rasters
	FOR EACH ROW
	EXECUTE PROCEDURE find_which_duty();
    
-- TEMP TRIGGER : update geom when inputing rasters
CREATE OR REPLACE FUNCTION fix_duty_map_geom()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
    BEGIN
        UPDATE duty_maps SET geom=st_transform(st_envelope(NEW.rast), 4326) WHERE name=NEW.filename;
        RETURN NEW;
    END;
$BODY$;
CREATE TRIGGER update_duty_map_geom
    AFTER INSERT ON duty_map_rasters
    FOR EACH ROW
    EXECUTE PROCEDURE fix_duty_map_geom();
-- and now fix the fact that all the geom measurements and transform coefficients are just computations...
-- MEASUREMENTS AND COEFFICIENTS CANNOT BE NULL
-- defaults for game measurements
ALTER TABLE duty_maps ALTER COLUMN a SET NOT NULL, ALTER COLUMN a SET DEFAULT 1.0;
ALTER TABLE duty_maps ALTER COLUMN b SET NOT NULL, ALTER COLUMN b SET DEFAULT 21.4;
ALTER TABLE duty_maps ALTER COLUMN e SET NOT NULL, ALTER COLUMN e SET DEFAULT 1.0;
ALTER TABLE duty_maps ALTER COLUMN f SET NOT NULL, ALTER COLUMN f SET DEFAULT 21.4;
-- geom measurements
ALTER TABLE duty_maps ALTER COLUMN c SET NOT NULL;
ALTER TABLE duty_maps ALTER COLUMN d SET NOT NULL;
ALTER TABLE duty_maps ALTER COLUMN g SET NOT NULL;
ALTER TABLE duty_maps ALTER COLUMN h SET NOT NULL;
-- coefficients
ALTER TABLE duty_maps ALTER COLUMN mxge SET NOT NULL;
ALTER TABLE duty_maps ALTER COLUMN nxge SET NOT NULL;
ALTER TABLE duty_maps ALTER COLUMN mxeg SET NOT NULL;
ALTER TABLE duty_maps ALTER COLUMN nxeg SET NOT NULL;
ALTER TABLE duty_maps ALTER COLUMN myge SET NOT NULL;
ALTER TABLE duty_maps ALTER COLUMN nyge SET NOT NULL;
ALTER TABLE duty_maps ALTER COLUMN myeg SET NOT NULL;
ALTER TABLE duty_maps ALTER COLUMN nyeg SET NOT NULL;
-- update geom measurements and coefficients automatically
CREATE OR REPLACE FUNCTION compute_coefficients()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
    BEGIN
        SELECT st_xmin(NEW.geom) INTO NEW.c;
        SELECT st_xmax(NEW.geom) INTO NEW.d;
        SELECT st_ymin(NEW.geom) INTO NEW.h;
        SELECT st_ymax(NEW.geom) INTO NEW.g;
        SELECT (NEW.d - NEW.c)/(NEW.b - NEW.a) INTO NEW.mxge;
        SELECT (NEW.c - NEW.mxge*NEW.a) INTO NEW.nxge;
        SELECT (NEW.b - NEW.a)/(NEW.d - NEW.c) INTO NEW.mxeg;
        SELECT (NEW.a - NEW.mxeg*NEW.c) INTO NEW.nxeg;
        SELECT (NEW.h - NEW.g)/(NEW.f - NEW.e) INTO NEW.myge;
        SELECT (NEW.g - NEW.myge*NEW.e) INTO NEW.nyge;
        SELECT (NEW.e - NEW.f)/(NEW.g - NEW.h) INTO NEW.myeg;
        SELECT (NEW.f - NEW.myeg*NEW.h) INTO NEW.nyeg;
        RETURN NEW;
    END;
$BODY$;
CREATE TRIGGER compute_coefficients
    BEFORE INSERT OR UPDATE
    ON duty_maps
    FOR EACH ROW
    EXECUTE PROCEDURE compute_coefficients();
	
-- Fill out guildhests
ALTER TABLE guildhests ADD COLUMN banner text;
ALTER TABLE guildhests ADD COLUMN lvl integer;
ALTER TABLE guildhests ADD COLUMN completion_xp integer;
ALTER TABLE guildhests ADD COLUMN completion_gil integer;
ALTER TABLE guildhests ADD COLUMN bonus_xp integer;
ALTER TABLE guildhests ADD COLUMN bonus_gil integer;

-- Fill out pvps
ALTER TABLE pvps ADD COLUMN banner text;
ALTER TABLE pvps ADD COLUMN lvl integer;
ALTER TABLE pvps ADD COLUMN rank_1_xp integer;
ALTER TABLE pvps ADD COLUMN rank_1_wolf integer;
ALTER TABLE pvps ADD COLUMN rank_2_xp integer;
ALTER TABLE pvps ADD COLUMN rank_2_wolf integer;
ALTER TABLE pvps ADD COLUMN rank_3_xp integer;
ALTER TABLE pvps ADD COLUMN rank_3_wolf integer;
CREATE TABLE pvp_tokens(
	duty text REFERENCES pvps (lid),
	token text REFERENCES currency(name),
	n int check(n>0),
	primary key (duty, token)
);
GRANT SELECT ON pvp_tokens TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON pvp_tokens TO ffxivrw;

-- RUN THE MOLESTONE HERE with chests OFF
-- RUN RASTERTOSQL FOR ARR HERE
-- RUN rastertosql.bat : will take .png's and make .sql
-- input the .sql into db with psql -U postgres -d ffxiv -f file.sql

-- or restore from ffxivbu20190308

-- Now, duty_map_rasters = duty_maps, constraint that
ALTER TABLE duty_maps ADD CONSTRAINT duty_map_raster_fkey FOREIGN KEY (name) REFERENCES duty_map_rasters (filename);
ALTER TABLE duty_chests ADD CONSTRAINT duty_chest_map_fkey FOREIGN KEY (map) REFERENCES duty_maps(name);
-- I would constraint-check the geom, but you can only constraint-check within the same table, so let's rely on these permanent triggers:
DROP TRIGGER update_duty_map_geom ON duty_map_rasters;
DROP FUNCTION fix_duty_map_geom();
    
-- make automatic insert on duty_maps
CREATE OR REPLACE FUNCTION add_duty_map()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
    BEGIN
        INSERT INTO duty_maps (name, geom, duty) VALUES (NEW.filename, st_transform(st_envelope(NEW.rast), 4326), NEW.dutylid);
        RETURN NEW;
    END;
$BODY$;
CREATE TRIGGER add_duty_map_from_raster
    AFTER INSERT ON duty_map_rasters
    FOR EACH ROW
    EXECUTE PROCEDURE add_duty_map();

-- RUN RASTERTOSQL HERE FOR HW AND SB

-- utility functions for content generation: coords -> geom
DROP FUNCTION get_xiv_geom(real, real, text);
-- for out in the world: zone,x,y -> geom 
CREATE OR REPLACE FUNCTION ffxiv.get_xiv_zone_geom(
	x real,
	y real,
	zonename text)
    RETURNS geometry
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
 mxge numeric;
 nxge numeric;
 myge numeric;
 nyge numeric;
BEGIN
 select zones.mxge into STRICT mxge from zones where lower(name)=lower(zonename);
 select zones.nxge into STRICT nxge from zones where lower(name)=lower(zonename);
 select zones.myge into STRICT myge from zones where lower(name)=lower(zonename);
 select zones.nyge into STRICT nyge from zones where lower(name)=lower(zonename);
 RETURN ST_GeomFromText('POINT(' || (mxge*x + nxge) || ' ' || (myge*y + nyge) ||')', 4326);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'Zone % not found', zonename;
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'Zone % not unique', zonename;
END;
$BODY$;
-- find duty default map: the one with the longest name to get the sub-zone one, nothing fancy...
CREATE OR REPLACE FUNCTION ffxiv.get_default_map(
	dutylid text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
 mapname text;
BEGIN
 SELECT name INTO mapname FROM duty_maps WHERE duty=dutylid ORDER BY char_length(name) DESC LIMIT 1;
 RETURN mapname;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION '[get_default_map] Maps for duty with lid % not found', dutylid;
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION '[get_default_map] More than one map for duty with lid %', dutylid;
END;
$BODY$;
-- for duties: dutylid, x, y -> geom
CREATE OR REPLACE FUNCTION ffxiv.get_xiv_duty_geom(
	x real,
	y real,
	dutylid text)
    RETURNS geometry
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
 mxge numeric;
 nxge numeric;
 myge numeric;
 nyge numeric;
BEGIN
 select duty_maps.mxge into STRICT mxge from duty_maps where name=(get_default_map(dutylid));
 select duty_maps.nxge into STRICT nxge from duty_maps where name=(get_default_map(dutylid));
 select duty_maps.myge into STRICT myge from duty_maps where name=(get_default_map(dutylid));
 select duty_maps.nyge into STRICT nyge from duty_maps where name=(get_default_map(dutylid));
 RETURN ST_GeomFromText('POINT(' || (mxge*x + nxge) || ' ' || (myge*y + nyge) ||')', 4326);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'Maps for duty with lid % not found', dutylid;
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'More than one map for duty with lid %', dutylid;
END;
$BODY$;

ALTER TABLE guildhests ALTER COLUMN banner SET NOT NULL;
ALTER TABLE guildhests ALTER COLUMN lvl SET NOT NULL;
ALTER TABLE guildhests ALTER COLUMN completion_xp SET NOT NULL;
ALTER TABLE guildhests ALTER COLUMN completion_gil SET NOT NULL;
ALTER TABLE guildhests ALTER COLUMN bonus_xp SET NOT NULL;
ALTER TABLE guildhests ALTER COLUMN bonus_gil SET NOT NULL;

ALTER TABLE pvps ALTER COLUMN banner SET NOT NULL;
ALTER TABLE pvps ALTER COLUMN lvl SET NOT NULL;
ALTER TABLE pvps ALTER COLUMN rank_1_xp SET NOT NULL;
ALTER TABLE pvps ALTER COLUMN rank_1_wolf SET NOT NULL;
ALTER TABLE pvps ALTER COLUMN rank_2_xp SET NOT NULL;
ALTER TABLE pvps ALTER COLUMN rank_2_wolf SET NOT NULL;
ALTER TABLE pvps ALTER COLUMN rank_3_xp SET NOT NULL;
ALTER TABLE pvps ALTER COLUMN rank_3_wolf SET NOT NULL;

-- RUN THE MOLESTONE WITH CHESTS ON

-- Adjust sql functions
-- boss loot
DROP FUNCTION ffxiv.get_boss_loot(integer);
CREATE OR REPLACE FUNCTION ffxiv.get_encounter_loot(
	dutylid text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$
    WITH items_per_encounter AS
    (
        SELECT
            de.gid,
            json_agg(get_item(del.itemlid)) as items
        FROM duty_encounter_loot AS del
			JOIN duty_encounters AS de ON del.encounter = de.gid
        WHERE de.duty=dutylid
        GROUP BY de.gid
    ),
    tokens_per_encounter AS
    (
        SELECT
            de.gid,
            json_agg(json_build_object(
                'qty', det.qty, 
                'token', get_token(det.token)
                )) AS tokens
        FROM duty_encounter_tokens AS det
			JOIN duty_encounters as de ON det.encounter = de.gid
        WHERE de.duty=dutylid
        GROUP BY de.gid
    )
    
    SELECT json_agg(json_build_object(
        'encounter', de.name,
        'geom', get_vertices(de.geom),
        'bounds', get_bounds(de.geom),
        'tokens', tokens,
        'items', items
    ))
    FROM duties_each AS d
        LEFT JOIN duty_encounters AS de ON de.duty = d.lid
        LEFT JOIN tokens_per_encounter AS tpe ON tpe.gid = de.gid
        LEFT JOIN items_per_encounter AS ipe ON ipe.gid = de.gid
    WHERE d.lid = dutylid;
$BODY$;
-- chest loot
DROP FUNCTION ffxiv.get_chests(integer);
CREATE OR REPLACE FUNCTION ffxiv.get_chests(
	dutylid text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$
    SELECT json_agg(json_build_object(
        'gid', dc.gid,
        'map', dc.map,
        'x', dc.x,
        'y', dc.y,
        'geom', get_vertices(dc.geom),
        'bounds', get_bounds(dc.geom),
        'coi', is_coi(dc.gid),
        'items', get_chest_loot(dc.gid)
    ))
    FROM duties_each AS d
        LEFT JOIN duty_chests as dc ON dc.duty=d.lid
    WHERE d.lid=dutylid;
$BODY$;
-- trash drops
DROP FUNCTION ffxiv.get_trash_drops(integer);
CREATE OR REPLACE FUNCTION ffxiv.get_trash_drops(
	dutylid text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$
SELECT
    json_agg(json_build_object(
        'nq', dtd.nq, 
        'hq', dtd.hq, 
        'item', get_item(dtd.itemlid)
    ))
FROM duties_each AS de
    LEFT JOIN duty_trash_drops AS dtd ON dtd.duty = de.lid
WHERE de.lid = $1;
$BODY$;
-- duty modes per name
CREATE OR REPLACE FUNCTION ffxiv.get_modes(
	duty text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$

SELECT json_object_agg(
        de.mode, 
        json_build_object(
        'mode', de.mode,
        'level', de.level,
        'nruns', de.nruns,
        'encounters', get_encounter_loot(de.lid),
        'chests', get_chests(de.lid),
        'trash_drops', get_trash_drops(de.lid)
    ))
FROM duties AS d
    JOIN duties_each AS de ON d.name = de.name
WHERE d.name=$1
GROUP BY d.name

$BODY$;
-- get duty mode ?
DROP FUNCTION ffxiv.get_duty_mode(text, text);

-- put lids in vsearchables
drop view vsearchables;
drop view vtrials;
CREATE OR REPLACE VIEW ffxiv.vtrials AS
SELECT d.id,
	d.lid,
	d.name || (case d.mode when 'Regular' then '' when 'Hard' then ' (Hard)' when 'Extreme' then ' (Extreme)' when 'Savage' then ' (Savage)' when 'Ultimate' then ' (Ultimate)' end) as name,
	d.name as real_name,
	d.mode,
	m.sort_order
FROM duties as dn
	JOIN duties_each as d ON dn.name = d.name
	JOIN modes as M on d.mode=m.name
WHERE dn.cat='Trial'
ORDER BY d.name, m.sort_order;

DROP VIEW ffxiv.vdungeons;
CREATE OR REPLACE VIEW ffxiv.vdungeons AS
 SELECT d.id,
	d.lid,
    d.name || (case d.mode when 'Regular' then '' when 'Hard' then ' (Hard)' when 'Extreme' then ' (Extreme)' when 'Savage' then ' (Savage)' when 'Ultimate' then ' (Ultimate)' end) as name,
    d.name AS real_name,
    d.mode,
    m.sort_order
   FROM duties as dn
     JOIN duties_each as d ON d.name = dn.name
     JOIN modes m ON d.mode = m.name
  WHERE dn.cat = 'Dungeon'
  ORDER BY d.name, m.sort_order;

DROP VIEW ffxiv.vraids;
CREATE OR REPLACE VIEW ffxiv.vraids AS
 SELECT d.id,
	d.lid,
    d.name || (case d.mode when 'Regular' then '' when 'Hard' then ' (Hard)' when 'Extreme' then ' (Extreme)' when 'Savage' then ' (Savage)' when 'Ultimate' then ' (Ultimate)' end) as name,
    d.name AS real_name,
    d.mode,
    m.sort_order
   FROM duties AS dn
     JOIN duties_each as d ON d.name = dn.name
     JOIN modes m ON d.mode = m.name
  WHERE dn.cat = 'Raid'
  ORDER BY d.name, m.sort_order;
 
CREATE VIEW vsearchables AS 
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
    nodes.name AS lid,
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
    nodes.name AS lid,
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
    nodes.name AS lid,
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
    nodes.name AS lid,
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
    nodes.name AS lid,
    'Harvesting'::text AS category,
    'Harvesting Node'::text AS category_name,
    nodes.name,
    nodes.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM nodes
  WHERE nodes.category = 'Harvesting'::text
UNION
 SELECT hunting_grounds.gid AS id,
    hunting_grounds.name AS lid,
    'Hunting'::text AS category,
    'Hunting Ground'::text AS category_name,
    hunting_grounds.name,
    hunting_grounds.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM hunting_grounds
UNION
 SELECT merchants.gid AS id,
    merchants.lid,
    'Merchant'::text AS category,
    'Merchant Stall'::text AS category_name,
    ((merchants.name || ' ('::text) || zones.name) || ')'::text AS name,
    merchants.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM merchants
     LEFT JOIN zones ON st_contains(zones.geom, merchants.geom)
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
 SELECT vmobs.gid AS id,
    vmobs.name AS lid,
    'Monster'::text AS category,
    'Monster Location'::text AS category_name,
    vmobs.name,
    vmobs.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM vmobs
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
  ORDER BY 6, 8;
