-- pg_restore.exe -U postgres -d postgres --create D:\Programmes\xampp\htdocs\melodysmaps\ffxivall20190521.backup
-- pg_restore.exe -U postgres -d postgres --create C:\xampp\htdocs\melodysmaps\ffxivall20190524.backup
ALTER DATABASE ffxiv SET search_path TO ffxiv, public;

-- yeah, let's not break the whole website because we removed other parts, okies?
DROP VIEW IF EXISTS vzones;
CREATE VIEW vzones AS
SELECT gid, name, code, geom, a, b, e, f,
  st_xmin(geom) as c, st_xmax(geom) as d,
  st_ymin(geom) as h, st_ymax(geom) as g,
  (st_xmax(geom) - st_xmin(geom))/(b - a) AS mxge,
  (st_xmin(geom) - (st_xmax(geom) - st_xmin(geom))/(b - a)*a) AS nxge,
  (b - a)/(st_xmax(geom) - st_xmin(geom)) AS mxeg,
  (a - (b - a)/(st_xmax(geom) - st_xmin(geom))*st_xmin(geom)) AS nxeg,
  (st_ymin(geom) - st_ymax(geom))/(f - e) AS myge,
  (st_ymax(geom) - (st_ymin(geom) - st_ymax(geom))/(f - e)*e) AS nyge,
  (e - f)/(st_ymax(geom) - st_ymin(geom)) AS myeg,
  (f - (e - f)/(st_ymax(geom) - st_ymin(geom))*st_ymin(geom)) AS nyeg
FROM zones;
GRANT SELECT ON vzones TO ffxivro;

CREATE OR REPLACE FUNCTION ffxiv.get_zone(
	zonelid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
select json_build_object(
	'gid', gid,
	'id', gid,
	'name', name,
    'label', name,
	'lid', name,
	'geom', get_vertices(geom),
	'bounds', get_bounds(geom),
	'centroid', get_centroid_coords(geom),
    'region', get_region((select lid from regions as r where st_contains(r.geom, z.geom))),
	'a', a,
	'b', b,
	'c', c,
	'd', d,
    'e', e,
    'f', f,
    'g', g,
    'h', h,
    'mxge', mxge,
    'nxge', nxge,
    'myge', myge,
    'nyge', nyge,
    'mxeg', mxeg,
    'nxeg', nxeg,
    'myeg', myeg,
    'nyeg', nyeg
)
from vzones as z
where name=$1;
$BODY$;

-- forgot to drop a few columns there Mel
ALTER TABLE zones DROP COLUMN myge, 
    DROP COLUMN nyge, 
    DROP COLUMN myeg, 
    DROP COLUMN nyeg;
-- while we're in zones, zones shouldn't intersect because it screws up selects with st_contains(zone.geom, other.geom)
-- move Waking Sands to invis_zones
INSERT INTO invis_zones(name, geom, code, a, b, e, f) 
SELECT name, geom, code, a, b, e, f
FROM zones
WHERE name='The Waking Sands';
UPDATE quests SET zone='Western Thanalan' WHERE zone='The Waking Sands';
DELETE FROM zones WHERE name='The Waking Sands';

CREATE OR REPLACE FUNCTION ffxiv.get_mobile(
	lid text)
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
    'x', n.x,
    'y', n.y,
    'geom', get_vertices(n.geom),
    'bounds', get_bounds(n.geom),
    'centroid', get_centroid_coords(n.geom)
)
FROM mobiles as n
WHERE lid = $1;
$BODY$;

CREATE OR REPLACE FUNCTION get_quest(questlid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$

with quest as (
	select * from quests where lid=$1
), rewards as (
select questlid, 
    json_agg(rewards) as rewards 
from (select questlid, 
        (select row_to_json(_) from (select get_item(itemlid) as item, n, classjob, gender, optional) as _) as rewards
    from quest_rewards 
    where questlid=$1)a
group by questlid
), other as (
select questlid, 
    json_agg(reward) as other
from (select questlid, (select row_to_json(_) from (select other, icon) as _) as reward
    from quest_rewards_others
    where questlid=$1)a
group by questlid
), qreq as (
select questlid, dutylid
from quest_requirements 
where questlid=$1
), req as (
select questlid, json_agg(requirements) as requirements 
from 
    (
	select qreq.questlid, (select row_to_json(_) from (select lid, name, mode, level) as _) as requirements
	from duties_each as de, qreq
	where de.lid=qreq.dutylid
    )a
group by questlid
)
select (select row_to_json(_) from (select q.lid, q.name, q.category, q.banner, q.area, q.zone, q.quest_type, 
    get_mobile(q.quest_giver) as quest_giver, q.level, q.level_requirement, q.class_requirement, q.gc, q.gc_rank, q.xp, 
    q.gil, q.bt, q.bt_currency_n, q.bt_currency, q.bt_reputation, q.gc_seals, q.starting_class, 
    q.tomestones, q.tomestones_n, q.ventures, q.seasonal, r.rewards, o.other, req.requirements) as _)
from quest as q
	left join rewards as r on q.lid=r.questlid
	left join other as o on q.lid=o.questlid
	left join req on q.lid=req.questlid
$BODY$;

INSERT INTO categories (name, pretty_name, red_icon, gold_icon, tooltip, map_icon, lid) VALUES ('Quest', 'Quest', '', '', 'A quest you may understake', '', 'Quest');