--1. Buffer
create table mobs_buffered as 
SELECT gid,
    name,
    zone,
    x,
    y,
    st_buffer(geom, 0.07) as geom,
    level,
    hp,
    mp,
    fate_id,
    is_fate
FROM xivdb_mobs;
GRANT SELECT ON mobs_buffered TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON mobs_buffered to ffxivrw;

--2. Cluster
CREATE TABLE mobs_clustered AS
SELECT name, zone, level, hp, mp, fate_id, is_fate, ST_UnaryUnion(grp) as geom 
FROM
(
	SELECT name, zone, level, hp, mp, fate_id, is_fate, unnest(ST_ClusterWithin(geom, 0.5)) AS grp 
	FROM mobs_buffered
	GROUP BY name, zone, level, hp, mp, fate_id, is_fate
) sq;
grant select on mobs_clustered to ffxivro;
grant update, insert, delete on mobs_clustered to ffxivrw;

--3. Dissolve
CREATE TABLE mob_spawns AS
SELECT (row_number() over())::int as gid, name, zone, level, hp, mp, fate_id, is_fate, ST_convexhull(geom) as geom
FROM mobs_clustered;
grant select on mob_spawns to ffxivro;
grant update,insert,delete on mob_spawns to ffxivrw;

-- Fix constraints on new table
ALTER TABLE mob_spawns ADD CONSTRAINT mob_spawns_pkey PRIMARY KEY (gid);
CREATE SEQUENCE mob_spawns_gid_seq OWNED BY mob_spawns.gid;
ALTER TABLE mob_spawns ALTER COLUMN gid SET DEFAULT nextval('mob_spawns_gid_seq');
SELECT setval('mob_spawns_gid_seq', 2437);
ALTER TABLE mob_spawns ADD COLUMN agressive boolean;
ALTER TABLE mob_spawns ADD COLUMN elite boolean;
ALTER TABLE mob_spawns ADD COLUMN requires TEXT;
ALTER TABLE mob_spawns ADD CONSTRAINT mob_spawns_fkey FOREIGN KEY (requires) REFERENCES requirements(name) ON UPDATE CASCADE;

-- nondropping and hg DO NOT intersect, good!
-- Nondropping: most of them are either eqv in mob_spawns, or invalid.

-- HOWEVER, add all FATE mobs that are verified...
with joined as 
(select ms.gid as msgid, ms.name as msname, nd.name as ndname, nd.gid as ndgid
from mob_spawns as ms
    full outer join nondropping as nd on lower(ms.name)=lower(nd.name) and st_intersects(ms.geom, nd.geom)
WHERE ms.name is not null and nd.name is not null
order by ms.name, nd.name),
nd_not_joined as (
select *
from nondropping as nd
where nd.gid not in (select ndgid from joined)
order by name)
insert into mob_spawns (name, zone, is_fate, agressive, elite, requires, geom) 
select nd.name, (select z.name from zones as z where st_contains(z.geom, nd.geom)), true, nd.agressive, nd.elite, nd.requires, st_buffer(st_centroid(nd.geom), 0.07)
from nd_not_joined as nd
left join mob_spawns as ms on nd.name=ms.name
WHERE nd.requires is not null;


-- PLUS one manual additions...
--Archaeosaur
insert into mob_spawns (name, zone, is_fate, agressive, elite, requires, geom) 
select nd.name, (select z.name from zones as z where st_contains(z.geom, nd.geom)), false, nd.agressive, nd.elite, nd.requires, st_buffer(st_centroid(nd.geom), 0.07)
from nondropping as nd
WHERE nd.name='Archaeosaur';

-- NOW copy info from nondropping to mob_spawns
UPDATE mob_spawns AS ms SET agressive=nd.agressive, elite=nd.elite, requires=nd.requires
FROM nondropping AS nd
WHERE lower(ms.name)=lower(nd.name) AND st_intersects(ms.geom, nd.geom);

-- Hunting grounds
-- After fixing my human mistakes, all hg's are in mob_spawns
-- EXCEPT those FATE-dependent mobs that we will add now...
with hgg as
(select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
from hunting_grounds),
joined as 
(select ms.gid as msgid, ms.name as msname, ms.level, ms.zone, hgg.level, hgg.namepart as hgname, hgg.gid as hggid
from mob_spawns as ms
    join hgg on 
        lower(ms.name)=lower(hgg.namepart) and 
        ms.level=hgg.level and
        ms.zone=(select z.name from zones as z where st_contains(z.geom, hgg.geom)) and
        st_intersects(ms.geom, hgg.geom)
order by ms.name, hgg.namepart, ms.zone, ms.level),
hg_not_joined as (
select *
from hgg
where hgg.gid not in (select hggid from joined)
order by name)
INSERT INTO mob_spawns (name, zone, level, is_fate, agressive, elite, requires, geom)
select hg.namepart, 
    (select z.name from zones as z where st_contains(z.geom, hg.geom)), 
    hg.level, 
    true, 
    hg.agressive, 
    hg.elite, 
    hg.requires, 
    st_buffer(st_centroid(hg.geom), 0.07)
from hg_not_joined as hg;

-- NOW copy info from hg to mob_spawns
ALTER TABLE mob_spawns ADD COLUMN nkilled integer CHECK(nkilled>=0) NOT NULL DEFAULT 0;

with hgg as
(select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
from hunting_grounds)
UPDATE mob_spawns AS ms SET agressive=hgg.agressive, elite=hgg.agressive, requires=hgg.requires, nkilled=hgg.nkilled
FROM hgg
WHERE hgg.gid is not null and ms.gid is not null and
        lower(ms.name)=lower(hgg.namepart) 
        and ms.level=hgg.level
        and ((hgg.requires is not null and is_fate)
            or (hgg.requires is null and not is_fate))
        and st_intersects(ms.geom, hgg.geom);

-- TRANSFER the foreign key in hunted_where from hunting_grounds to mob_spawns
ALTER TABLE hunted_where ADD COLUMN hg integer REFERENCES mob_spawns(gid);

with hgg as
(select gid, level, name, case when substring(name from '^(.+?)\(.+') is null then name else trim(substring(name from '^(.+)\(.+')) end as namepart, requires, geom, nkilled, elite, agressive
from hunting_grounds),
ms AS (
select ms.gid, hgg.name as node
from hgg
    join mob_spawns as ms ON
        lower(ms.name)=lower(hgg.namepart) 
        and ms.level=hgg.level
        and ((hgg.requires is not null and is_fate)
            or (hgg.requires is null and not is_fate))
        and st_intersects(ms.geom, hgg.geom)
)
UPDATE hunted_where AS hw SET hg=ms.gid
FROM ms 
    WHERE hw.node=ms.node;
    
select hw.node, hw.itemlid, hw.hg, ms.name, ms.level, ms.is_fate
from hunted_where as hw
    left join mob_spawns as ms ON hw.hg=ms.gid;

alter table hunted_where drop constraint hunted_where_pkey, add constraint hunted_where_pkey PRIMARY KEY (hg, itemlid);
alter table hunted_where add constraint hunted_where_tmp_ukey UNIQUE (node, itemlid);