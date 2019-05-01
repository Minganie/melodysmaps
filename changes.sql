-- pg_restore.exe -U postgres -d postgres --create C:\xampp\htdocs\melodysmaps\ffxivall.bu
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


-------------------------------------
-- create mob_spawns, take 2
ALTER DATABASE ffxiv SET search_path TO ffxiv, public;
-- update missing levels to avoid trouble waaaay down the line
UPDATE nondropping SET minlvl=54, maxlvl=54 WHERE name='Archaeosaur';
UPDATE nondropping SET minlvl=46, maxlvl=46 WHERE name='Klythios';
UPDATE nondropping SET minlvl=43, maxlvl=43 WHERE name='Drowned Steersman';
-- fix more human mistakes...
UPDATE hunting_grounds SET agressive=true WHERE name like 'Snow Wolf Pup%';
UPDATE hunting_grounds SET agressive=true WHERE name like 'Sandworm%';
UPDATE hunting_grounds SET agressive=true WHERE name like 'Antling Soldier%';
ALTER TABLE hunted_where DROP CONSTRAINT hunted_where_pkey, DROP CONSTRAINT hunted_where_hg_fkey;
DROP TABLE mobs_buffered;
DROP TABLE mobs_clustered;
DROP TABLE mob_spawns;

-- make data consistent from mobiles to markers to mob_spawns with normality and triggers and stuff

-------------------------------------
-- NORMALITY
-------------------------------------
CREATE TABLE mm_mobiles(
    name text primary key,
    agressive boolean,
    elite boolean
);
GRANT SELECT ON mm_mobiles TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON mm_mobiles TO ffxivrw;
INSERT INTO mm_mobiles (name)
SELECT DISTINCT name FROM xivdb_mobs;

CREATE TABLE mm_unique_mobiles (
    id serial primary key,
    name text not null references mm_mobiles(name),
    zone text not null references zones(name),
    level integer check(level>0),
    hp integer,
    mp integer,
    fate_id text,
    is_fate boolean,
    requires text references requirements (name) ON UPDATE CASCADE,
    UNIQUE(name,zone,level,hp,mp,fate_id,is_fate,requires)
);
GRANT SELECT ON mm_unique_mobiles TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON mm_unique_mobiles TO ffxivrw;
insert into mm_unique_mobiles (name, zone, level, hp, mp, fate_id, is_fate)
SELECT DISTINCT name, zone, level, hp, mp, fate_id, is_fate FROM xivdb_mobs;

ALTER TABLE xivdb_mobs ADD COLUMN mmumob integer references mm_unique_mobiles(id);
UPDATE xivdb_mobs as m SET mmumob=mm.id
FROM mm_unique_mobiles as mm
WHERE mm.name=m.name and mm.zone=m.zone 
    and mm.level=m.level and mm.hp=m.hp and mm.mp=m.mp
    and mm.fate_id=m.fate_id and mm.is_fate=m.is_fate;
    
ALTER TABLE xivdb_mobs DROP COLUMN name,
    DROP COLUMN zone,
    DROP COLUMN level,
    DROP COLUMN hp,
    DROP COLUMN mp,
    DROP COLUMN fate_id,
    DROP COLUMN is_fate;

    
-------------------------------------
-- GEOMETRY 
-------------------------------------
--1+2. Buffer and dissolve
DROP TABLE IF EXISTS mobs_clustered;
CREATE table mobs_clustered (
    gid serial primary key,
    mmumob integer not null references mm_unique_mobiles(id),
    geom geometry(MultiPolygon, 4326)
);
GRANT SELECT ON mobs_clustered TO ffxivro;
insert into mobs_clustered (mmumob, geom)
SELECT mmumob, st_multi(ST_UnaryUnion(grp))
FROM
(
	SELECT mmumob, unnest(ST_ClusterWithin(st_buffer(geom, 0.07), 0.5)) AS grp 
	FROM xivdb_mobs
	GROUP BY mmumob
) sq;

--3. Convex Hull
DROP TABLE IF EXISTS mob_spawns;
CREATE TABLE mob_spawns (
    gid serial primary key,
    mmumob integer not null references mm_unique_mobiles(id),
    geom geometry(Polygon, 4326)
);
grant select on mob_spawns to ffxivro;
insert into mob_spawns (mmumob, geom)
SELECT mmumob, ST_convexhull(geom) as geom
FROM mobs_clustered;


-- WHEN ADDING TO MARKERS, CASCADE THROUGH buffered, clustered, and mob_spawns
-- CREATE AS POSTGRES since ffxivrw doesn't have update rights on geometry tables
CREATE OR REPLACE FUNCTION adjust_to_new_marker()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
    DECLARE
        new_cluster geometry(MultiPolygon, 4326);
        old_cluster_id integer;
        new_hull geometry(Polygon, 4326);
        old_hull_id integer;
    BEGIN
        -- BUFFER+CLUSTER
        BEGIN
            -- new cluster
            SELECT st_multi(ST_UnaryUnion(grp)) INTO STRICT new_cluster
            FROM
            (
                SELECT unnest(ST_ClusterWithin(st_buffer(geom, 0.07), 0.5)) AS grp 
                FROM xivdb_mobs
                WHERE mmumob=NEW.mmumob
                GROUP BY mmumob
            ) sq;
            
            -- old cluster
            SELECT gid INTO STRICT old_cluster_id
            FROM mobs_clustered
            WHERE mmumob=NEW.mmumob AND st_intersects(geom, new_cluster);
            -- if you get here, there's already a cluster, update geom
            UPDATE mobs_clustered SET geom=new_cluster WHERE gid=old_cluster_id;
            
            -- if you get thrown here, it's a new cluster
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO mobs_clustered (mmumob, geom) 
                VALUES (NEW.mmumob, new_cluster);
            WHEN OTHERS THEN
                RAISE EXCEPTION '% %', SQLERRM, SQLSTATE;
        END;
        
        -- CONVEX HULL
        BEGIN
            -- New convex hull
            SELECT st_convexhull(new_cluster) INTO STRICT new_hull;
            
            -- Old convex hull
            SELECT gid INTO STRICT old_hull_id
            FROM mob_spawns AS ms 
            WHERE ms.mmumob=NEW.mmumob AND st_intersects(ms.geom, new_cluster);
            -- if you get here, there's already a convex hull, update geom
            UPDATE mob_spawns SET geom=new_hull
            WHERE gid=old_hull_id;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO mob_spawns (mmumob, geom) VALUES (NEW.mmumob, new_hull);
            WHEN OTHERS THEN
                RAISE EXCEPTION '% %', SQLERRM, SQLSTATE;
        END;
        RETURN NEW;
    END;
$BODY$;

CREATE TRIGGER adjust_to_new_marker
    AFTER INSERT OR UPDATE ON xivdb_mobs
    FOR EACH ROW EXECUTE PROCEDURE adjust_to_new_marker();

-- WHEN REMOVING MARKERS, cascade too
CREATE OR REPLACE FUNCTION adjust_geom_to_less_marker()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
    DECLARE
        old_hull_id integer;
        old_cluster_id integer;
        n_markers integer;
        n_mmumob_markers integer;
        n_mm_mmumobs integer;
        new_cluster geometry(MultiPolygon, 4326);
        new_hull geometry(Polygon, 4326);
    BEGIN
        select gid INTO STRICT old_hull_id
        from mob_spawns as ms 
        WHERE st_contains(geom, OLD.geom) AND ms.mmumob=OLD.mmumob;
        SELECT gid INTO STRICT old_cluster_id
        FROM mobs_clustered as mc
        WHERE st_contains(geom, OLD.geom) AND mc.mmumob=OLD.mmumob;
        select count(gid) into strict n_markers
        from xivdb_mobs as m
        where m.mmumob=OLD.mmumob AND m.gid<>OLD.gid AND st_contains((select ms.geom from mob_spawns as ms where gid=old_hull_id), m.geom);
        -- was it the only marker for this mmumob AT THIS LOCATION? if so, delete from mc and ms
        IF n_markers < 1 THEN
            DELETE FROM mobs_clustered WHERE mmumob=OLD.mmumob;
            DELETE FROM mob_spawns WHERE mmumob=OLD.mmumob;
        ELSE
        -- adjust mc and ms
            SELECT st_multi(ST_UnaryUnion(grp)) INTO STRICT new_cluster
            FROM
            (
                SELECT unnest(ST_ClusterWithin(st_buffer(geom, 0.07), 0.5)) AS grp 
                FROM xivdb_mobs
                WHERE mmumob=OLD.mmumob AND gid <> OLD.gid
                GROUP BY mmumob
            ) sq;
            UPDATE mobs_clustered SET geom=new_cluster WHERE gid=old_cluster_id;
            
            SELECT st_convexhull(geom) INTO STRICT new_hull
            FROM mobs_clustered
            WHERE mmumob=OLD.mmumob AND gid=old_cluster_id;
            UPDATE mob_spawns SET geom=new_hull WHERE gid=old_hull_id;
        END IF;
        RETURN OLD;
    END;
$BODY$;
COMMENT ON FUNCTION adjust_geom_to_less_marker IS 'Adjust clustered and hull geometries when deleting a marker; shrink if one marker will be left after delete; delete if no marker will be left. Must be followed by foreign key cleanup, see adjust_ref_to_less_marker';

CREATE TRIGGER adjust_geom_to_less_marker
    BEFORE DELETE ON xivdb_mobs
    FOR EACH ROW EXECUTE PROCEDURE adjust_geom_to_less_marker();

CREATE OR REPLACE FUNCTION adjust_ref_to_less_marker()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
    DECLARE
        n_mmumob_markers integer;
        n_mm_mmumobs integer;
        old_name text;
    BEGIN
        SELECT name INTO old_name
        FROM mm_unique_mobiles AS m
        WHERE id=OLD.mmumob;
        -- was it the last marker for this mmumob? if so, delete from mm_unique_mobiles
        SELECT count(gid) INTO STRICT n_mmumob_markers
        FROM xivdb_mobs AS m 
        WHERE m.mmumob=OLD.mmumob AND m.gid<>OLD.gid;
        
        IF n_mmumob_markers < 1 THEN
            DELETE FROM mm_unique_mobiles WHERE id=OLD.mmumob;
        END IF;
        
        -- and the last marker for this mob name? (i.e. no other mmumob for this mmob)
        SELECT count(id) INTO n_mm_mmumobs
        FROM mm_unique_mobiles AS m
        WHERE m.name=old_name;
        IF (n_mm_mmumobs IS NULL OR n_mm_mmumobs < 1) AND old_name IS NOT NULL THEN
            DELETE FROM mm_mobiles WHERE name=old_name;
        END IF;
        RETURN OLD;
    END;
$BODY$;
COMMENT ON FUNCTION adjust_ref_to_less_marker IS 'Foreign key reference cleanup; must be done after delete to avoid key violation. Preceded by adjust_geom_to_less_marker. If no marker is left for a mob+level+requires, delete from mm_unique_mobiles. In addition, if no marker is left for a mob name, delete from mm_mobiles.';
    
CREATE TRIGGER adjust_ref_to_less_marker
    AFTER DELETE ON xivdb_mobs
    FOR EACH ROW EXECUTE PROCEDURE adjust_ref_to_less_marker();

-- Now smoosh nondropping and hunting_grounds to mm_mobiles and mm_unique_mobiles and mob_spawns...

-- nondropping and hg DO NOT intersect, good!
-- Nondropping: most of them are either eqv in mob_spawns, or invalid, or hunts I have to document properly.
--For clarity, remove invalids...
-- done on server

-- Ignored nondropping can be seen with
select nd.agressive, nd.elite, nd.requires, nd.name as ndname, m.name as mname
from nondropping as nd
	left join mm_mobiles as m on lower(nd.name)=lower(m.name)
where m.name is null and requires is null
order by nd.name;

-- HOWEVER, add all FATE mobs that are verified...
-- Add their name to mm_mobiles
with to_be_added as
(select nd.name, nd.maxlvl, nd.geom, nd.agressive, nd.elite, nd.requires
from nondropping as nd
	left join mm_mobiles as m on lower(nd.name)=lower(m.name)
where m.name is null and requires is not null
order by nd.name)
INSERT INTO mm_mobiles (name, agressive, elite) 
SELECT name, agressive, elite from to_be_added;

-- Add their lvl + requires to mm_unique_mobiles
with tba as (select mm.name, mm.agressive, mm.elite 
from mm_mobiles as mm
	left join mm_unique_mobiles as mmumob ON mm.name=mmumob.name
where mmumob.name is null),
rt as (
select tba.name, tba.agressive, tba.elite, nd.maxlvl, nd.requires, geom
from tba
	join nondropping as nd on lower(tba.name)=lower(nd.name))
INSERT INTO mm_unique_mobiles (name, zone, level, requires)
SELECT rt.name, (SELECT z.name FROM zones as z WHERE st_contains(z.geom, rt.geom)), rt.maxlvl, rt.requires 
FROM rt;

-- Finally, add their markers to xivdb_mobs
WITH tba as
(SELECT mmumob.id, mmumob.name, mmumob.zone, mmumob.level, mmumob.requires
FROM mm_unique_mobiles as mmumob
    LEFT JOIN xivdb_mobs as m ON mmumob.id=m.mmumob
where m.gid is null),
rt as
(select tba.id, nd.geom
from tba
	join nondropping as nd ON lower(tba.name)=lower(nd.name)
)
INSERT INTO xivdb_mobs (mmumob, geom)
SELECT id, st_centroid(geom)
FROM rt;

-- PLUS one manual additions...
--Archaeosaur
INSERT INTO mm_mobiles (name, agressive, elite) 
SELECT name, agressive, elite 
from nondropping as nd
WHERE nd.name='Archaeosaur';

INSERT INTO mm_unique_mobiles (name, zone, level, requires)
SELECT nd.name, (SELECT z.name FROM zones as z WHERE st_contains(z.geom, nd.geom)), nd.maxlvl, nd.requires 
FROM nondropping as nd
WHERE nd.name='Archaeosaur';

INSERT INTO xivdb_mobs (mmumob, geom)
SELECT (SELECT id FROM mm_unique_mobiles WHERE name='Archaeosaur'), st_centroid(geom)
FROM nondropping as nd
WHERE nd.name='Archaeosaur';

-- NOW copy info from nondropping to mm, mmumob and xivdb_mobs
-- agressive/elite
UPDATE mm_mobiles SET agressive=nd.agressive, elite=nd.agressive
FROM nondropping AS nd
WHERE lower(mm_mobiles.name)=lower(nd.name);

-- requires
DELETE FROM xivdb_mobs WHERE mmumob=2071 OR mmumob=1931; -- No lvl 34 thrustaevis i can find
-- check problems with 
with joined as (select *
FROM (select *
	from nondropping as nd
	WHERE requires is not null
 ) nd
	join mm_unique_mobiles as m ON lower(nd.name)=lower(m.name)
		AND m.zone=(select name from zones as z where st_contains(z.geom, nd.geom))
		AND nd.minlvl=nd.maxlvl AND nd.minlvl=m.level
		AND fate_id!='0'
), problematic as 
(select gid, count(id)
from joined
group by gid
having count(id)<>1)
select *
from problematic as p
	join nondropping as nd ON p.gid=nd.gid;
-- if there's duplicates of spitfire, well, I didn't do it.
UPDATE mm_unique_mobiles AS m SET requires=nd.requires
FROM nondropping AS nd
WHERE nd.requires IS NOT NULL
    AND lower(nd.name)=lower(m.name)
    AND m.zone=(select name from zones as z where st_contains(z.geom, nd.geom))
    AND nd.minlvl=nd.maxlvl AND nd.minlvl=m.level
    AND fate_id <> '0';


-- Hunting grounds
-- After fixing my human mistakes, all hg's are in mob_spawns
-- EXCEPT those FATE-dependent mobs that we will add now...
-- +names into mm_mobiles
with hgg as
(select gid, level, name, 
	case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, 
	requires, geom, nkilled, elite, agressive,
    (select z.name from zones as z where st_contains(z.geom, hunting_grounds.geom)) as zone
from hunting_grounds
), newmobs as
(select distinct namepart 
from hgg
where lower(namepart) not in (select lower(name) from mm_mobiles)
)
INSERT INTO mm_mobiles (name, agressive, elite)
select hgg.namepart, hgg.agressive, hgg.elite
from newmobs
	join hgg on lower(hgg.namepart) = lower(newmobs.namepart);

-- +requires
with missing as (select *
from mm_mobiles
	where name not in (select distinct name from mm_unique_mobiles)
), hgg as
(select gid, level, name, 
	case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, 
	requires, geom, nkilled, elite, agressive,
    (select z.name from zones as z where st_contains(z.geom, hunting_grounds.geom)) as zone
from hunting_grounds
)
INSERT INTO mm_unique_mobiles (name, zone, level, requires)
select m.name, (select z.name from zones as z where st_contains(z.geom, hgg.geom)), hgg.level, hgg.requires
from missing as m
	join hgg on m.name=hgg.namepart;

-- +markers
with hgg as
(select gid, level, name, 
	case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, 
	requires, geom, nkilled, elite, agressive,
    (select z.name from zones as z where st_contains(z.geom, hunting_grounds.geom)) as zone
from hunting_grounds
)
INSERT INTO xivdb_mobs (mmumob, geom)
select mm.id, st_centroid(hgg.geom)
from mm_unique_mobiles as mm
	join hgg ON mm.name=hgg.namepart
where id not in (select mmumob from xivdb_mobs);

-- NOW copy info from hg to mob_spawns
-- But first, fix permissions
ALTER TABLE mob_spawns ADD COLUMN nkilled integer CHECK(nkilled>=0) NOT NULL DEFAULT 0;
REVOKE INSERT, UPDATE, DELETE ON mob_spawns FROM ffxivrw;
GRANT UPDATE (nkilled) ON mob_spawns TO ffxivrw;

-- Fix annoying duplicates
DELETE FROM xivdb_mobs WHERE mmumob=1744;
DELETE FROM mm_unique_mobiles WHERE id=1744;
DELETE FROM xivdb_mobs WHERE mmumob=1425;
DELETE FROM mm_unique_mobiles WHERE id=1425;
-- Myotragus billy 18 ended up split, so remove its data from hg...
DELETE FROM hunted_where WHERE node='Myotragus Billy (lvl 18)';
DELETE FROM hunting_grounds WHERE gid=583;
-- HEEEEEEEEEEERRRRRRRRRRRRRRREEEEEEEE check cohesion
with hgg as
(select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
from hunting_grounds
), ms as
(select ms.gid, ms.geom, ms.nkilled, mu.id, mu.name, mu.level, mu.requires, mu.fate_id
from mob_spawns as ms
	join mm_unique_mobiles as mu ON ms.mmumob=mu.id
), wrong as
(select hgg.gid, count(ms.gid)
from hgg
	left join ms ON lower(hgg.namepart)=lower(ms.name) 
		AND hgg.level=ms.level 
        and ((hgg.requires IS NOT NULL AND ms.fate_id <> '0') OR (hgg.requires IS NOT NULL AND ms.requires IS NOT NULL) OR (hgg.requires IS NULL AND ms.fate_id = '0'))
        and st_intersects(hgg.geom, ms.geom)
group by hgg.gid
having count(ms.gid)<>1)
select * from wrong;

-- COPY
-- nkilled
with hgg as
(select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
from hunting_grounds
), ms as
(select ms.gid, ms.geom, ms.nkilled, mu.id, mu.name, mu.level, mu.requires, mu.fate_id
from mob_spawns as ms
	join mm_unique_mobiles as mu ON ms.mmumob=mu.id
), dat as (
select ms.gid, hgg.nkilled
from hgg
	left join ms ON lower(hgg.namepart)=lower(ms.name) 
		AND hgg.level=ms.level 
        and ((hgg.requires IS NOT NULL AND ms.fate_id <> '0') OR (hgg.requires IS NOT NULL AND ms.requires IS NOT NULL) OR (hgg.requires IS NULL AND ms.fate_id = '0'))
        and st_intersects(hgg.geom, ms.geom)
)
UPDATE mob_spawns as m SET nkilled=dat.nkilled
FROM dat
WHERE m.gid = dat.gid;
--requires
with hgg as
(select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
from hunting_grounds
), ms as
(select ms.gid, ms.geom, ms.nkilled, mu.id, mu.name, mu.level, mu.requires, mu.fate_id
from mob_spawns as ms
	join mm_unique_mobiles as mu ON ms.mmumob=mu.id
), dat as (
select ms.gid, ms.id, hgg.nkilled, hgg.requires, hgg.elite, hgg.agressive
from hgg
	left join ms ON lower(hgg.namepart)=lower(ms.name) 
		AND hgg.level=ms.level 
        and ((hgg.requires IS NOT NULL AND ms.fate_id <> '0') OR (hgg.requires IS NOT NULL AND ms.requires IS NOT NULL) OR (hgg.requires IS NULL AND ms.fate_id = '0'))
        and st_intersects(hgg.geom, ms.geom)
WHERE hgg.requires IS NOT NULL AND ms.requires IS NULL
)
UPDATE mm_unique_mobiles as mu
SET requires=dat.requires
FROM dat 
WHERE mu.id=dat.id;
-- agressive/elite
with hgg as
(select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
from hunting_grounds
), hg as
(select distinct namepart, bool_and(elite) as elite, bool_and(agressive) as agressive
from hgg
group by namepart)
UPDATE mm_mobiles AS m
SET agressive=hg.agressive, elite=hg.elite
FROM hg
WHERE lower(hg.namepart)=lower(m.name)
AND (m.elite is null or m.agressive is null)
AND hg.elite is not null and hg.agressive is not null;

-- TRANSFER the foreign key in hunted_where from hunting_grounds to mob_spawns
ALTER TABLE hunted_where ADD COLUMN ms integer REFERENCES mob_spawns(gid);
ALTER TABLE hunted_where DROP COLUMN hg;

with hgg as
(select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
from hunting_grounds
), ms AS 
(select ms.gid, ms.geom, ms.nkilled, mu.id, mu.name, mu.level, mu.requires, mu.fate_id
from mob_spawns as ms
	join mm_unique_mobiles as mu ON ms.mmumob=mu.id
), dat as (
select ms.gid as mobspawn, ms.id as mmumob, hgg.name as node, hgg.nkilled, hgg.requires, hgg.elite, hgg.agressive
from hgg
	left join ms ON lower(hgg.namepart)=lower(ms.name) 
		AND hgg.level=ms.level 
        and ((hgg.requires IS NOT NULL AND ms.fate_id <> '0') OR (hgg.requires IS NOT NULL AND ms.requires IS NOT NULL) OR (hgg.requires IS NULL AND ms.fate_id = '0'))
        and st_intersects(hgg.geom, ms.geom)
)
UPDATE hunted_where AS hw SET ms=dat.mobspawn
FROM dat
    WHERE hw.node=dat.node;
    
alter table hunted_where drop constraint fk_hunting_nname;
alter table hunted_where drop constraint hunted_where_tmp_ukey, add constraint hunted_where_pkey primary key (ms, itemlid);
alter table hunted_where drop column node;


-------------------------------------
-- Transfer from hg+nd to mob_spawns on the front end
DROP VIEW vsearchables;
ALTER TABLE hunting_grounds RENAME TO old_hg;
DROP VIEW vmobs;
DROP VIEW vhunting_grounds;
DROP TABLE mhulls;
DROP TABLE markers;
ALTER TABLE nondropping RENAME TO old_nd;

-- I now have two concepts: Mob and Mob spawn
-- Update categories to reflect this
UPDATE categories SET name='Spawn', pretty_name='Spawn point', tooltip='A specific area where a monster may appear', lid='Spawn' WHERE name='Hunting';
UPDATE categories SET pretty_name='Monster', tooltip='Information on a specific monster' WHERE name='Monster';

-- When searching, return Mob = group of mob spawns
-- When in item, return mob spawns

-- Searchable: now only mob name (omg so much js rewriting to do)
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
 SELECT 0 as id,
    mm_mobiles.name as lid,
    'Monster' AS category,
    'Monster' AS category_name,
    mm_mobiles.name,
    mm_mobiles.name as real_name,
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
GRANT SELECT ON TABLE ffxiv.vsearchables TO ffxivro;


DROP FUNCTION get_hunting_drops(text);
CREATE OR REPLACE FUNCTION get_hunting_drops(msgid integer)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$
SELECT json_agg(json_build_object(
    'nq', nq, 
    'hq', hq, 
    'item', get_item(itemlid)
))
FROM hunted_where
WHERE ms=msgid
$BODY$;

DROP FUNCTION get_lootable_mob(text);

CREATE OR REPLACE FUNCTION get_zone_abbrev(thename text)
    RETURNS text
    LANGUAGE 'sql'
AS $BODY$
select string_agg(left(m, 1), '') as lab
from (select name, unnest(string_to_array(name, ' ')) as m from zones)m
where name=thename
group by name;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_mob_spawn(
	msgid integer)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
SELECT json_build_object(
	'id', ms.gid,
    'lid', ms.gid,
	'level', (select level from mm_unique_mobiles as mu where mu.id=ms.mmumob),
	'name', (select name from mm_unique_mobiles as mu where mu.id=ms.mmumob),
    'label', (select name from mm_unique_mobiles as mu where mu.id=ms.mmumob) || '(' || get_zone_abbrev((select name from zones as z where st_contains(z.geom, ms.geom))) || ' lvl ' || (select level from mm_unique_mobiles as mu where mu.id=ms.mmumob) || ')',
	'category', get_category('Hunting'),
	'requirement', get_requirement(ms.requires),
	'geom', get_vertices(ms.geom),
	'bounds', get_bounds(ms.geom),
	'centroid', get_centroid_coords(ms.geom),
	'nkilled', ms.nkilled,
	'elite', ms.elite,
	'agressive', ms.agressive,
	'drops', get_hunting_drops(ms.gid)
)
FROM mob_spawns AS ms
WHERE ms.gid=msgid
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item_hg(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$

select json_agg(json_build_object(
 'hg', get_mob_spawn(gid),
 'nq', nq,
 'hq', hq))
from(SELECT ms.gid,
 nq,
 hq,
 nkilled,
 case when nkilled>0 then nq::float/nkilled::float
   else 0
 end as nrate
FROM hunted_where AS hw
    JOIN mob_spawns as ms ON hw.hg=ms.gid
WHERE itemlid=$1
order by nrate desc)a
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_mob(
	mobname text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$
select json_build_object(
    'id', ROW_NUMBER() OVER (ORDER BY name, minlvl),
    'lid', ROW_NUMBER() OVER (ORDER BY name, minlvl),
    'name', name,
    'label', name,
    'category', get_category('Monster'),
	'geom', get_vertices(st_union(geom)),
	'bounds', get_bounds(st_union(geom)),
	'centroid', get_centroid_coords(st_union(geom)),
    'minlvl', min(level),
    'maxlvl', max(level),
    'agressive', bool_and(agressive),
    'elite', bool_and(elite)
)
select row_number() over (order by name, minlvl) as id,
    row_number() over (order by name, minlvl) as lid,
    name,
    minlvl, maxlvl, agressive, elite
from (
    SELECT 
        name, 
        st_union(geom) as geom, 
        min(level) as minlvl, 
        max(level) as maxlvl, 
        bool_and(agressive) as agressive, 
        bool_and(elite) as elite
    FROM mob_spawns as ms
    where name='Lightning Sprite' and not is_fate
    group by name)m;
$BODY$;
    
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
 SELECT 0 as id,
    mm_mobiles.name as lid,
    'Monster' AS category,
    'Monster' AS category_name,
    mm_mobiles.name,
    mm_mobiles.name as real_name,
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
GRANT SELECT ON TABLE ffxiv.vsearchables TO ffxivro;