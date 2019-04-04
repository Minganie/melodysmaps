-------------------------------------
-- create mob_spawns, take 2
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
CREATE OR REPLACE FUNCTION adjust_to_less_marker()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
    DECLARE
        old_hull_id integer;
        old_cluster_id integer;
        n_markers integer;
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
        IF n_markers <= 1 THEN
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

CREATE TRIGGER adjust_to_less_marker
    BEFORE DELETE ON xivdb_mobs
    FOR EACH ROW EXECUTE PROCEDURE adjust_to_less_marker();

-- Now smoosh nondropping and hunting_grounds to mm_mobiles and mm_unique_mobiles and mob_spawns...

-- nondropping and hg DO NOT intersect, good!
-- Nondropping: most of them are either eqv in mob_spawns, or invalid, or hunts I have to document properly.
--For clarity, remove invalids...
delete from nondropping where name = any('{"\u0003","Ac","Ace","Alisae","Alphinaud","Anala De La Steppe","Anala Infernal","Anila De Sel","Angrybird","Assaillant Kojin Rouge","Avogatto","Avril","Axs","Braconnier Olkund","Batmobil","Beebo","Blazea","Bob","Bobbycorwen","Borat","Bucca-Boo","Bukan Rouge","Calimero","Captain Jacke","Cazer","Chapo","Chapuli Ailes-Hautes","Chasseuse Des M","Chevelle","Choco","Choci","Chocie","Chocobotox","Chocobro","Chocolli","Chocomian","Chocomouth","Chocoprince","Chocuru","Chokokwak","Chooky","Cid","Clemintine","Cobo","Coba","Coco","Coquorail","Cordulie","Crest","Crispy","Crossmarian","Croustillon","Crozzo","Dhole De La Steppe","Dhruva De Sel","Dindofeu","Dresseuse Vira","Edila Rampante","Edoiks","Elisa","Elgala","Eliza","Elpollo","Eruca Des Hauteurs","Fenice","Fesoj","Fezo","Fiamma","Fileuse","Flake","Flash","Fopar","Forevermore","Fourmi Royale","Foutu","Frelon Gazelle","Fritz","Furet Domien","Gaei Le Vertueux","Gagana Mineur","Gardien Bestial","Gauki La Lame Forte","Gelbervogel","Gillian","Ginko","Glitch","Gold","Goldchocobo","Greyfeather","Grizzli De Montagne","Guetteur Namazu","Gusty","Gyorai Le Vif","Halonefury","Hannibal","Happy","Herbie","Heolis","Hestia","Hisashi","Holly","Honkan Rouge","Horus","Hyoe Rouge", "Ichigo","Igneel","Igor","Ikaru","Ikumi","Iltschi","Indian","Inkwehsition","Jajanzo","Jamesbond","Jeune Mammouth","Jimble","Jiromaru","Jorah","Kain","Kairos","Kamoulox","Kanaria","Kanfohyaller","Katsperch", "Kaze","Kazumi","Keira","Kemobo","Ki","Kiinazuma","Kiki","Kikolo","Kikuhope","Kincho","Kinder","Kittahsmash","Kiwii","Knuschlersmom","Krax","Krillin","Krokmou","Kurczak","Kurisu","Kweh","Kwehfka","Kwehninya", "Kwehsleysnipes","Kwey","Kyubi","Langhals","Lara","Lauburu","Laz","Lefquene The Mystic","Lemy","Leon","Ligart","Lightning","Lillith","Loot","Lucie","Luna","Lyse","M Tribe Ranger","Maaloxan","Maat","Mac", "Magatsu","Magni","Mammouth","Manji","Marie","Maro Roggo","Marshmallow","Mauci Of The Seven And Seven Swords","Maximus","Mcnugget","Mead-Porting Midlander","Melchiorre","Melody","Memeroon","Mervin","Meteorite", "Mewtwo","Mianne Thousandmalm","Mielke","Mikuzume","Minotaure D''abalathia","Misaki","Misty","Mockingbird Totem","Modish Moogle","Mogpo The Magnificent","Mojojojo","Mol Shepherd","Morgen","Mortified Moogle", "Mossy Peak","Moudsoud","Moussemousse","Musa","Myrskytuuli","Na''toth","Nanka Des Lacs","Nat''leii Zundu","Needle","Neela","Neri","Nimo","Nirvash","Nogri","Norman","Nova","Nuddles","Nyx","O''adebh Whitemane", "O''sanuwa Vundu","Oarf","Off-Duty Porter","Oisillon","Olkund Dzotamer","Olyxen","Onyxthefortuitous","Orphaned Sylph","Osskur","Otacon","Outlawstar","Oyster Hunter","Oz","Pack Chocobo","Pain''o''choco","Panko", "Payetabiere","Peanutallergy","Penpen","Perimu Haurimu Underfoot","Pewpew","Phinri","Phoenix''shadow","Pikachu","Pikorin","Pipi","Poisson-Bombo","Pollaster","Pooc","Porter","Poussin","Pow","Pretorius", "Proceratosaurus","Promachos","Pruina","Pugil De La Velodyna","Punky","Pupsi","Pure Black Crystal","Pusheen","Qiqirn Croque-Viande","Qiqirn Tranche-Viande","Quicky","Ranger Of The Drake","Raphi","Rascal", "Rasputin","Rasty","Red Rooster Tiller","Redemption","Regulus","Reispufferchen","Repede","Requin Volant","Rex","Reykios","Rgrenbow","Rhea","Rhoe","Riam","Richard","Ricky","Riesenflausch","Rin","Roadrunner", "Robert","Rose","Rose Knight","Rosseforp","Roudsoud","Rugged Researcher","Ruin","Rukia","Rumo","Rumor","Rururaji","Rygar","Saillot","Sangsue Des Lacs","Sarcosuchus De La Velodyna","Satan","Schattenfell", "Scourge","Seasoned Adventurer","Seishiro","Senshi","Serein","Seyoung","Shadow","Shenron","Shiba","Shifty-Eyed Prospector","Shipment Of Brass Cogs","Shirogane","Shokobon","Sid","Sinon","Sitta","Skenderbeu", "Skep","Skliropouli","Slaine","Sleepless Citizen","Sleipnir","Slicktrix The Gobnanimous","Sliph","Smoke","Sokhatai","Soldat Des Immortels","Son Of Saint Coinach","Spartaco","Spazz","Spector","Speedie","Speedy", "Speedygonzales","Spyro","Star","Stardust","Starfighter","Striking Dummy","Sunzie","Supply Troop","Surveillance Module","Tailfeather Hunter","Tardis","Taro","Tequila","Terabyte","Thechariotofthegods","Thundaga", "Tila","Tina","Toffy","Tokepi","Tolkien","Tomikayuma","Tomoe","Tomoya","Tonio","Triceratops","Troubles","Tsurara","Twitter","U''kahmuli","U''konelua","U''lolamo","U''ralka","Urolithe De Marbre","Ursa", "V''kebbe The Stray","Valentines''arrow","Valkyrie","Valor","Vanna","Verification Node","Vikturi","Vira Beadmaid","Vira Bowmaid","Void","Vombrellule","Vrai Griffon","Wary Merchant","Whitelighting","Whizzer", "Widget","Wiggles","Wipkipje","Woho","Wood Wailer Lance","Wood Wailer Sentry","Worried Worker","Wounded Confederate","Xela","Xlll","Yamini La Nocturne","Yato","Yojimbo","Yokou","Yoshi","Yourdaughter''sname", "Z''hotchoco","Zeuglodon","Zeus","Zezeroon Stickyfingers"}');

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
-- FIX COHESION HERE
with nd as (select *
from nondropping as nd
	join mm_unique_mobiles as mm ON lower(nd.name)=lower(mm.name)
where nd.requires is not null AND not (nd.minlvl=mm.level OR nd.maxlvl=mm.level)
)
select * from nd
order by gid;

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
ALTER TABLE mob_spawns ADD COLUMN nkilled integer CHECK(nkilled>=0) NOT NULL DEFAULT 0;
REVOKE INSERT, UPDATE, DELETE ON mob_spawns FROM ffxivrw;
GRANT UPDATE (nkilled) ON mob_spawns TO ffxivrw;

-- HEEEEEEEEEEERRRRRRRRRRRRRRREEEEEEEE check cohesion
with hgg as
(select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
from hunting_grounds
), ms as
(select ms.gid, ms.geom, ms.nkilled, mu.id, mu.name, mu.level, mu.requires
from mob_spawns as ms
	join mm_unique_mobiles as mu ON ms.mmumob=mu.id
), wrong as
(select hgg.gid, count(ms.gid)
from hgg
	left join ms ON lower(hgg.namepart)=lower(ms.name) 
		AND hgg.level=ms.level and st_intersects(hgg.geom, ms.geom)
group by hgg.gid
having count(ms.gid)<>1
order by hgg.gid)
select *
from hgg
	join wrong on hgg.gid=wrong.gid;
-- Move Daddy Longlegs
DELETE FROM xivdb_mobs WHERE gid=23351;
DELETE FROM xivdb_mobs WHERE gid=23949;
DELETE FROM xivdb_mobs WHERE gid=24546;
DELETE FROM xivdb_mobs WHERE gid=24384;
DELETE FROM mm_unique_mobiles WHERE id=1744;
DELETE FROM xivdb_mobs WHERE mmumob=1425;
DELETE FROM mm_unique_mobiles WHERE id=1425;

-- with hgg as
-- (select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
-- from hunting_grounds)
-- UPDATE mob_spawns AS ms SET agressive=hgg.agressive, elite=hgg.agressive, requires=hgg.requires, nkilled=hgg.nkilled
-- FROM hgg
-- WHERE hgg.gid is not null and ms.gid is not null and
        -- lower(ms.name)=lower(hgg.namepart) 
        -- and ms.level=hgg.level
        -- and ((hgg.requires is not null and is_fate)
            -- or (hgg.requires is null and not is_fate))
        -- and st_intersects(ms.geom, hgg.geom);

-- TRANSFER the foreign key in hunted_where from hunting_grounds to mob_spawns
-- ALTER TABLE hunted_where ADD COLUMN hg integer REFERENCES mob_spawns(gid);

-- with hgg as
-- (select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
-- from hunting_grounds),
-- ms AS (
-- select ms.gid, hgg.name as node
-- from hgg
    -- join mob_spawns as ms ON
        -- lower(ms.name)=lower(hgg.namepart) 
        -- and ms.level=hgg.level
        -- and ((hgg.requires is not null and is_fate)
            -- or (hgg.requires is null and not is_fate))
        -- and st_intersects(ms.geom, hgg.geom)
-- )
-- UPDATE hunted_where AS hw SET hg=ms.gid
-- FROM ms 
    -- WHERE hw.node=ms.node;
    
-- select hw.node, hw.itemlid, hw.hg, ms.name, ms.level, ms.is_fate
-- from hunted_where as hw
    -- left join mob_spawns as ms ON hw.hg=ms.gid;

-- alter table hunted_where drop constraint hunted_where_pkey, add constraint hunted_where_pkey PRIMARY KEY (hg, itemlid);
-- alter table hunted_where add constraint hunted_where_tmp_ukey UNIQUE (node, itemlid);
    
    
    
-------------------------------------
-- Transfer from hg+nd to mob_spawns on the front end
alter table hunted_where drop constraint hunted_where_tmp_ukey,
    drop constraint fk_hunting_nname,
    drop column node;
    
DROP VIEW vsearchables;
ALTER TABLE hunting_grounds RENAME TO old_hg;
DROP VIEW vmobs;
DROP VIEW vhunting_grounds;
DROP TABLE mhulls;
DROP TABLE markers;
ALTER TABLE nondropping RENAME TO old_nd;

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
WHERE hg=msgid
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
	'level', ms.level,
	'name', ms.name,
    'label', ms.name || '(' || get_zone_abbrev((select name from zones as z where st_contains(z.geom, ms.geom))) || ' lvl ' || ms.level || ')',
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
 SELECT mob_spawns.gid AS id,
    mob_spawns.gid AS lid,
    'Monster'::text AS category,
    'Monster Location'::text AS category_name,
    mob_spawns.name,
    mob_spawns.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM mob_spawns
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