DROP VIEW ffxiv.vsearchables;
CREATE OR REPLACE VIEW ffxiv.vsearchables AS
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
 SELECT xivdb_npcs.gid as id,
  xivdb_npcs.gid::text as lid,
  'npc'::text AS category,
  'NPC'::text as category_name,
  xivdb_npcs.name || ' (' || xivdb_npcs.zone || ')' as name,
  xivdb_npcs.name as real_name,
  NULL::text as mode,
  NULL::integer as sort_order
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
  ORDER BY 6, 8;
GRANT SELECT ON vsearchables TO ffxivro;

CREATE OR REPLACE FUNCTION ffxiv.get_npc_from_id(
	npcgid integer)
    RETURNS json
    LANGUAGE 'sql'
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


-- pg_restore.exe -U postgres -d postgres --create C:\xampp\htdocs\melodysmaps\ffxivall.bu
ALTER DATABASE ffxiv SET search_path TO ffxiv, public;
-- QUESTS
-- Fix function get_xiv_zone_geom for those weird zones like 'Seat of the First Bow'
CREATE OR REPLACE FUNCTION ffxiv.get_xiv_zone_geom(
	x real,
	y real,
	zonename text)
    RETURNS geometry
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
 mxge numeric;
 nxge numeric;
 myge numeric;
 nyge numeric;
 coords geometry(Point, 4326);
BEGIN
 IF zonename = 'Seat of the First Bow'
    THEN coords = get_xiv_zone_geom(20, 10, 'New Gridania');
 ELSE
     select zones.mxge into STRICT mxge from zones where lower(name)=lower(zonename);
     select zones.nxge into STRICT nxge from zones where lower(name)=lower(zonename);
     select zones.myge into STRICT myge from zones where lower(name)=lower(zonename);
     select zones.nyge into STRICT nyge from zones where lower(name)=lower(zonename);
     coords = ST_GeomFromText('POINT(' || (mxge*x + nxge) || ' ' || (myge*y + nyge) ||')', 4326);
 END IF;
 RETURN coords;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'Zone % not found', zonename;
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'Zone % not unique', zonename;
END;
$BODY$;
-- tables required for future fkeys
-- GC and their ranks
CREATE TABLE grand_companies(
    name text primary key,
    particle text not null
);
GRANT SELECT ON grand_companies TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON grand_companies TO ffxivrw;
INSERT INTO grand_companies VALUES('Maelstrom', 'Storm');
INSERT INTO grand_companies VALUES('Order of the Twin Adder', 'Serpent');
INSERT INTO grand_companies VALUES('Immortal Flames', 'Flame');
CREATE TABLE grand_company_ranks(
    rank int not null,
    name text primary key,
    before_particle text,
    after_particle text
);
GRANT SELECT ON grand_company_ranks TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON grand_company_ranks TO ffxivrw;
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (1, 'Private Third Class', '', ' Private Third Class');
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (2, 'Private Second Class', '', ' Private Second Class');
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (3, 'Private First Class', '', ' Private First Class');
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (4, 'Corporal', '', ' Corporal');
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (5, 'Sergeant Third Class', '', ' Sergeant Third Class');
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (6, 'Sergeant Second Class', '', ' Sergeant Second Class');
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (7, 'Sergeant First Class', '', ' Sergeant First Class');
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (8, 'Chief Sergeant', 'Chief ', ' Sergeant');
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (9, 'Second Lieutenant', 'Second ', ' Lieutenant');
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (10, 'First Lieutenant', 'First ', ' Lieutenant');
INSERT INTO grand_company_ranks (rank, name, before_particle, after_particle) VALUES (11, 'Captain', '', ' Captain');
-- beast tribes
CREATE TABLE beast_tribes(
    name text primary key,
    currency text unique
);
GRANT SELECT ON beast_tribes TO ffxivro;
GRANT UPDATE, INSERT, DELETE ON beast_tribes TO ffxivrw;
INSERT INTO beast_tribes (name, currency) VALUES ('Ixali', 'Ixali Oaknot');
INSERT INTO beast_tribes (name, currency) VALUES ('Sahagin', 'Rainbowtide Psashp');
INSERT INTO beast_tribes (name, currency) VALUES ('Amalj''aa', 'Steel Amalj''ok');
INSERT INTO beast_tribes (name, currency) VALUES ('Sylphs', 'Sylphic Goldleaf');
INSERT INTO beast_tribes (name, currency) VALUES ('Kobolds', 'Titan Cobaltpiece');
INSERT INTO beast_tribes (name, currency) VALUES ('Vanu Vanu', 'Vanu Whitebone');
INSERT INTO beast_tribes (name, currency) VALUES ('Vath', 'Black Copper Gil');
INSERT INTO beast_tribes (name, currency) VALUES ('Moogles', 'Carved Kupo Nut');
INSERT INTO beast_tribes (name, currency) VALUES ('Ananta', 'Ananta Dreamstaff');
INSERT INTO beast_tribes (name, currency) VALUES ('Kojin', 'Kojin Sango');
INSERT INTO beast_tribes (name, currency) VALUES ('Namazu', 'Namazu Koban');
-- disciplines
-- Fix what already exists: 3 tables for discs; trigger that
-- Are tables 'cause items and others couldn't fkey on a view
-- Add to doth, dotl, dotwm when adding to disciplines
ALTER TABLE disciplines ALTER COLUMN cat SET NOT NULL,
ALTER COLUMN abbrev SET NOT NULL, ALTER COLUMN lid SET NOT NULL;
ALTER TABLE disciplines ADD COLUMN ltd boolean;
UPDATE disciplines SET ltd=false WHERE cat='War' or cat='Magic';
UPDATE disciplines SET ltd=true WHERE abbrev='BLU';
UPDATE disciplines SET name='Fisher' WHERE name='Fishing';
UPDATE disciplines SET name='Miner' WHERE name='Mining';
REVOKE UPDATE, INSERT, DELETE ON doth FROM ffxivrw;
REVOKE UPDATE, INSERT, DELETE ON dotl FROM ffxivrw;
REVOKE UPDATE, INSERT, DELETE ON dowm FROM ffxivrw;
ALTER TABLE doth DROP COLUMN icon;
ALTER TABLE doth DROP COLUMN abbrev;
ALTER TABLE dotl DROP COLUMN abbrev;
ALTER TABLE dowm DROP COLUMN abbrev;
-- old DOTL had Mining+Quarrying, move that to new table;
-- make nodes ref new table
ALTER TABLE nodes DROP CONSTRAINT fk_cat;
UPDATE nodes SET category='Mining' WHERE category='Miner';
UPDATE dotl SET name='Miner' WHERE name='Mining';
UPDATE dotl SET name='Fisher' WHERE name='Fishing';
UPDATE dotl SET name='Botanist' WHERE name='Logging';
DELETE FROM dotl WHERE name='Quarrying' OR name='Harvesting' OR name='Spearfishing';
CREATE TYPE hand AS ENUM ('Main hand', 'Off-hand');
CREATE TABLE dotl_sub (
    dotl text REFERENCES dotl(name),
    hand hand not null,
    sub_disc text not null UNIQUE,
    PRIMARY KEY (dotl, hand)
);
GRANT SELECT ON dotl_sub TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON dotl_sub TO ffxivrw;
INSERT INTO dotl_sub VALUES ('Miner', 'Main hand', 'Mining');
INSERT INTO dotl_sub VALUES ('Miner', 'Off-hand', 'Quarrying');
INSERT INTO dotl_sub VALUES ('Fisher', 'Main hand', 'Fishing');
INSERT INTO dotl_sub VALUES ('Fisher', 'Off-hand', 'Spearfishing');
INSERT INTO dotl_sub VALUES ('Botanist', 'Main hand', 'Logging');
INSERT INTO dotl_sub VALUES ('Botanist', 'Off-hand', 'Harvesting');
ALTER TABLE nodes ADD CONSTRAINT fk_cat FOREIGN KEY (category) REFERENCES dotl_sub(sub_disc) ON UPDATE CASCADE;
-- fix fkeys on new tables
ALTER TABLE doth ADD CONSTRAINT doth_fkey FOREIGN KEY (name) REFERENCES disciplines(name);
ALTER TABLE dotl ADD CONSTRAINT doth_fkey FOREIGN KEY (name) REFERENCES disciplines(name);
ALTER TABLE dowm ADD CONSTRAINT doth_fkey FOREIGN KEY (name) REFERENCES disciplines(name);
-- Might need just dow or just dom too
CREATE TABLE dow (
    name text REFERENCES disciplines(name) PRIMARY KEY
);
GRANT SELECT ON dow TO ffxivro;
INSERT INTO dow SELECT name FROM disciplines WHERE cat='War';
CREATE TABLE dom (
    name text REFERENCES disciplines(name) PRIMARY KEY
);
GRANT SELECT ON dom TO ffxivro;
INSERT INTO dom SELECT name FROM disciplines WHERE cat='Magic';

CREATE FUNCTION add_disc_to_child_table()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
    BEGIN
        CASE NEW.cat
            WHEN 'Hand' THEN
                INSERT INTO doth VALUES (NEW.name);
            WHEN 'Land' THEN
                INSERT INTO dotl VALUES (NEW.name);
            WHEN 'War' THEN
                INSERT INTO dow VALUES (NEW.name);
                INSERT INTO dowm VALUES (NEW.name);
            WHEN 'Magic' THEN
                INSERT INTO dom VALUES (NEW.name);
                INSERT INTO dowm VALUES (NEW.name);
        END case;
        RETURN NEW;
    END;
$BODY$;
CREATE TRIGGER add_disc_to_child_table
    AFTER INSERT ON disciplines
    FOR EACH ROW EXECUTE PROCEDURE add_disc_to_child_table();

CREATE TABLE discipline_groups(
    name text primary key
);
GRANT SELECT ON discipline_groups TO ffxivro;
GRANT UPDATE, INSERT, DELETE ON discipline_groups TO ffxivrw;
CREATE TABLE discipline_group_lists(
    disc_group text REFERENCES discipline_groups(name),
    disc text REFERENCES disciplines(name),
    PRIMARY KEY (disc_group, disc)
);
GRANT SELECT ON discipline_group_lists TO ffxivro;
GRANT UPDATE, INSERT, DELETE ON discipline_group_lists TO ffxivrw;
-- For validation:
CREATE VIEW bad_disc_groups AS
SELECT *
FROM discipline_groups as dg
    LEFT JOIN discipline_group_lists AS dgl ON dg.name=dgl.disc_group
WHERE dgl.name IS NULL;

-- CREATE TABLE all_disc_groups();
-- GRANT SELECT ON discipline_group_lists TO ffxivro;
-- GRANT UPDATE, INSERT, DELETE ON discipline_group_lists TO ffxivrw;

-- add geom to npcs
INSERT INTO mobile_types VALUES ('NPC');
ALTER TABLE mobiles ADD COLUMN x real;
ALTER TABLE mobiles ADD COLUMN y real;
ALTER TABLE mobiles ADD COLUMN map text REFERENCES zones(name);
ALTER TABLE mobiles ADD COLUMN geom geometry(Point, 4326);

-- add bunch of columns to quests
ALTER TABLE quests ADD COLUMN category text;
ALTER TABLE quests ADD COLUMN banner text;
ALTER TABLE quests ADD COLUMN area text;
ALTER TABLE quests ADD COLUMN zone text references zones (name);
ALTER TABLE quests ADD COLUMN quest_giver text references mobiles(lid);
ALTER TABLE quests ADD COLUMN level int;

ALTER TABLE quests ADD COLUMN level_requirement int;
------
--ALTER TABLE quests DROP CONSTRAINT quests_class_requirement_fkey, ADD CONSTRAINT quests_class_requirement_fkey FOREIGN KEY (class_requirement) REFERENCES discipline_groups(name);
------
ALTER TABLE quests ADD COLUMN class_requirement text REFERENCES discipline_groups (name);
ALTER TABLE quests ADD COLUMN gc text references grand_companies(name);
ALTER TABLE quests ADD COLUMN gc_rank text references grand_company_ranks(name);

ALTER TABLE quests ADD COLUMN xp int;
ALTER TABLE quests ADD COLUMN gil int;
ALTER TABLE quests ADD COLUMN bt text REFERENCES beast_tribes(name);
ALTER TABLE quests ADD COLUMN bt_currency_n int;
ALTER TABLE quests ADD COLUMN bt_currency text REFERENCES beast_tribes(currency);
ALTER TABLE quests ADD COLUMN bt_reputation int;
ALTER TABLE quests ADD COLUMN gc_seals int;
ALTER TABLE quests ADD COLUMN starting_class text REFERENCES disciplines(name);
ALTER TABLE quests ADD COLUMN tomestones text REFERENCES currency (name);
ALTER TABLE quests ADD COLUMN tomestones_n int;
ALTER TABLE quests ADD COLUMN ventures int;
ALTER TABLE quests ADD COLUMN seasonal boolean;

-- 1xn rel tables
CREATE TYPE gender AS ENUM ('Male', 'Female');
CREATE TABLE quest_rewards(
    questlid text REFERENCES quests(lid),
    itemlid  text REFERENCES items(lid),
    n        int NOT NULL DEFAULT 1,
    classjob text REFERENCES disciplines (abbrev),
    gender   gender,
    optional boolean,
    PRIMARY KEY (questlid, itemlid)
);
GRANT SELECT ON quest_rewards TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON quest_rewards TO ffxivrw;
CREATE TABLE quest_rewards_others(
    questlid text references quests(lid),
    other    text,
    PRIMARY KEY (questlid, other)
);
GRANT SELECT ON quest_rewards_others TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON quest_rewards_others TO ffxivrw;
CREATE TABLE quest_requirements(
    questlid text REFERENCES quests(lid),
    dutylid  text REFERENCES duties_each(lid),
    PRIMARY KEY (questlid, dutylid)
);
GRANT SELECT ON quest_requirements TO ffxivro;
GRANT UPDATE, INSERT, DELETE ON quest_requirements TO ffxivrw;


