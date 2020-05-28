CREATE TABLE xpac (
    name text primary key,
    abbrev text unique
);
GRANT SELECT on xpac TO ffxivro;
GRANT INSERT, UPDATE, DELETE on xpac TO ffxivrw;
INSERT INTO xpac (name, abbrev) VALUES 
('A Realm Reborn', 'ARR'), 
('Heavensward', 'HW'), 
('Stormblood', 'SB'), 
('Shadowbringers', 'ShB');

-- add index to ss
ALTER TABLE sightseeing 
    ADD COLUMN xpac text REFERENCES xpac(abbrev),
    ADD COLUMN idx int,
    ADD CONSTRAINT sightseeing_ukey UNIQUE (segment, idx);
UPDATE sightseeing as ss
SET idx=gid, xpac=x.abbrev
FROM xpac as x where ss.segment like x.abbrev || '%';
ALTER TABLE sightseeing
    ALTER COLUMN idx SET NOT NULL,
    ALTER COLUMN segment DROP DEFAULT;
    
-- transfer ssw to use new ukey
ALTER TABLE sightseeing_weather 
    ADD COLUMN segment text, 
    ADD COLUMN idx int;
UPDATE sightseeing_weather as ssw
    SET segment=ss.segment, idx=ss.idx
    FROM sightseeing as ss 
    WHERE ssw.sightseeing=ss.gid;
ALTER TABLE sightseeing_weather
    -- new fkey
    ADD CONSTRAINT ss_fkey FOREIGN KEY (segment, idx) REFERENCES sightseeing(segment, idx),
    DROP CONSTRAINT sightseeing_weather_sightseeing_fkey,
    -- replace pkey
    DROP CONSTRAINT sightseeing_weather_pkey,
    ADD CONSTRAINT sightseeing_weather_pkey PRIMARY KEY (segment, idx, weather);

CREATE OR REPLACE FUNCTION ffxiv.get_vistas(
	)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
select json_object_agg(segment, vistas)
from
(
    select segment, json_agg(vista) as vistas
    from
    (
        select segment, get_vista(xpac || to_char(idx, 'FM000'::text)) as vista
        from sightseeing
        order by gid
    ) a
    GROUP BY segment
    order by segment
) b;
$BODY$;
CREATE OR REPLACE FUNCTION ffxiv.get_vista(
	vista text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
select json_build_object(
    'id', gid,
    'lid', gid,
    'name', xpac || to_char(ss.idx, 'FM000'::text),
    'label', xpac || to_char(ss.idx, 'FM000'::text),
    'zone', ss.zone,
    'x', x,
    'y', y,
    'debut', debut,
    'category', get_category('Sightseeing'),
    'fin', fin,
    'emote', emote,
    'impression', impression,
    'confirmed', confirmed,
    'record', ss.record,
    'hint', hint,
    'big_hint', big_hint,
    'uname', uname,
	'geom', get_vertices(geom),
	'bounds', get_bounds(geom),
	'centroid', get_centroid_coords(geom),
    'weather', get_vista_weathers(gid)
)
from sightseeing as ss
where xpac || to_char(ss.idx, 'FM000'::text)=$1;
$BODY$;

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
    xpac || to_char(sightseeing.idx, 'FM000'::text) AS lid,
    'Sightseeing'::text AS category,
    'Sightseeing Entry'::text AS category_name,
    xpac || to_char(sightseeing.idx, 'FM000'::text) AS name,
    xpac || to_char(sightseeing.idx, 'FM000'::text) AS real_name,
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
GRANT ALL ON TABLE ffxiv.vsearchables TO mluce;
GRANT SELECT ON TABLE ffxiv.vsearchables TO ffxivro;


INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 1, 'Coerthas Western Highlands', 32, 36, '/lookout', get_xiv_zone_geom(32, 36, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 2, 'Coerthas Western Highlands', 20, 23, '/lookout', get_xiv_zone_geom(20, 23, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 3, 'Coerthas Western Highlands', 10.3, 18, '/lookout', get_xiv_zone_geom(10.3, 18, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 4, 'Coerthas Western Highlands', 20, 6.6, '/lookout', get_xiv_zone_geom(20, 6.6, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 5, 'Coerthas Western Highlands', 31.6, 4.8, '/lookout', get_xiv_zone_geom(31.6, 4.8, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 6, 'Coerthas Western Highlands', 36.2, 19.2, '/lookout', get_xiv_zone_geom(36.2, 19.2, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 7, 'Coerthas Western Highlands', 20.6, 36.5, '/lookout', get_xiv_zone_geom(20.6, 36.5, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 8, 'The Dravanian Forelands', 27.4, 36.3, '/lookout', get_xiv_zone_geom(27.4, 36.3, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 9, 'The Dravanian Forelands', 12.0, 39.4, '/lookout', get_xiv_zone_geom(12.0, 39.4, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 10, 'The Dravanian Forelands', 16.6, 23.3, '/lookout', get_xiv_zone_geom(16.6, 23.3, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 11, 'The Dravanian Forelands', 29.6, 6.1, '/lookout', get_xiv_zone_geom(29.6, 6.1, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 12, 'The Dravanian Forelands', 8.2, 6.1, '/pray', get_xiv_zone_geom(8.2, 6.1, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 13, 'The Dravanian Forelands', 33.9, 23.5, '/lookout', get_xiv_zone_geom(33.9, 23.5, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 14, 'The Dravanian Forelands', 11.4, 13.4, '/lookout', get_xiv_zone_geom(11.4, 13.4, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 15, 'The Churning Mists', 29, 35, '/lookout', get_xiv_zone_geom(29, 35, 'The Churning Mists'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 16, 'The Churning Mists', 29, 13, '/lookout', get_xiv_zone_geom(29, 13, 'The Churning Mists'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 17, 'The Churning Mists', 18.6, 6.4, '/lookout', get_xiv_zone_geom(18.6, 6.4, 'The Churning Mists'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 18, 'The Churning Mists', 07.8, 27.0, '/lookout', get_xiv_zone_geom(07.8, 27.0, 'The Churning Mists'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 19, 'The Churning Mists', 17, 37, '/pray', get_xiv_zone_geom(17, 37, 'The Churning Mists'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 20, 'The Churning Mists', 35.1, 20.4, '/lookout', get_xiv_zone_geom(35.1, 20.4, 'The Churning Mists'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 21, 'The Churning Mists', 23.2, 18.6, '/lookout', get_xiv_zone_geom(23.2, 18.6, 'The Churning Mists'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 22, 'The Sea of Clouds', 15.2, 37.7, '/lookout', get_xiv_zone_geom(15.2, 37.7, 'The Sea of Clouds'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 23, 'The Sea of Clouds', 37.2, 40.1, '/doze', get_xiv_zone_geom(37.2, 40.1, 'The Sea of Clouds'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 24, 'The Sea of Clouds', 39.9, 21.9, '/lookout', get_xiv_zone_geom(39.9, 21.9, 'The Sea of Clouds'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 25, 'The Sea of Clouds', 13.0, 8.9, '/lookout', get_xiv_zone_geom(13.0, 8.9, 'The Sea of Clouds'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 26, 'The Sea of Clouds', 18.4, 27, '/lookout', get_xiv_zone_geom(18.4, 27, 'The Sea of Clouds'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 27, 'The Sea of Clouds', 25.0, 23.9, '/lookout', get_xiv_zone_geom(25.0, 23.9, 'The Sea of Clouds'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 28, 'The Sea of Clouds', 38.1, 11.7, '/lookout', get_xiv_zone_geom(38.1, 11.7, 'The Sea of Clouds'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 29, 'The Dravanian Hinterlands', 40.1, 21.8, '/lookout', get_xiv_zone_geom(40.1, 21.8, 'The Dravanian Hinterlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 30, 'The Dravanian Hinterlands', 17.9, 23.2, '/lookout', get_xiv_zone_geom(17.9, 23.2, 'The Dravanian Hinterlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 31, 'The Dravanian Hinterlands', 22, 27, '/lookout', get_xiv_zone_geom(22, 27, 'The Dravanian Hinterlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 32, 'The Dravanian Hinterlands', 10.1, 35.9, '/lookout', get_xiv_zone_geom(10.1, 35.9, 'The Dravanian Hinterlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 33, 'The Dravanian Hinterlands', 28.8, 37.8, '/lookout', get_xiv_zone_geom(28.8, 37.8, 'The Dravanian Hinterlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 34, 'The Dravanian Hinterlands', 32.7, 11.9, '/lookout', get_xiv_zone_geom(32.7, 11.9, 'The Dravanian Hinterlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 35, 'The Dravanian Hinterlands', 13.0, 21.6, '/lookout', get_xiv_zone_geom(13.0, 21.6, 'The Dravanian Hinterlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 36, 'Azys Lla', 39.2, 17.0, '/lookout', get_xiv_zone_geom(39.2, 17.0, 'Azys Lla'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 37, 'Azys Lla', 33.4, 35.6, '/lookout', get_xiv_zone_geom(33.4, 35.6, 'Azys Lla'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 38, 'Azys Lla', 06.0, 30.6, '/lookout', get_xiv_zone_geom(06.0, 30.6, 'Azys Lla'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 39, 'Azys Lla', 10.9, 35.6, '/lookout', get_xiv_zone_geom(10.9, 35.6, 'Azys Lla'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 40, 'Azys Lla', 06.1, 9.9, '/lookout', get_xiv_zone_geom(06.1, 9.9, 'Azys Lla'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 41, 'Azys Lla', 09.4, 21.5, '/lookout', get_xiv_zone_geom(09.4, 21.5, 'Azys Lla'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 42, 'Azys Lla', 30.4, 11.4, '/lookout', get_xiv_zone_geom(30.4, 11.4, 'Azys Lla'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 43, 'Coerthas Western Highlands', 32, 28, '/rally', get_xiv_zone_geom(32, 28, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 44, 'Coerthas Western Highlands', 29.9, 23.8, '/lookout', get_xiv_zone_geom(29.9, 23.8, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 45, 'Coerthas Western Highlands', 09.0, 10.4, '/sit', get_xiv_zone_geom(09.0, 10.4, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 46, 'Coerthas Western Highlands', 12.7, 8.2, '/me', get_xiv_zone_geom(12.7, 8.2, 'Coerthas Western Highlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 47, 'The Dravanian Forelands', 23.4, 39.4, '/lookout', get_xiv_zone_geom(23.4, 39.4, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 48, 'The Dravanian Forelands', 24.2, 18.8, '/lookout', get_xiv_zone_geom(24.2, 18.8, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 49, 'The Dravanian Forelands', 34.3, 15.8, '/lookout', get_xiv_zone_geom(34.3, 15.8, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 50, 'The Dravanian Forelands', 18.6, 32.6, '/lookout', get_xiv_zone_geom(18.6, 32.6, 'The Dravanian Forelands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 51, 'The Churning Mists', 33.8, 32.4, '/pray', get_xiv_zone_geom(33.8, 32.4, 'The Churning Mists'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 52, 'The Churning Mists', 37.3, 14.4, '/lookout', get_xiv_zone_geom(37.3, 14.4, 'The Churning Mists'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 53, 'The Churning Mists', 14.7, 25.0, '/lookout', get_xiv_zone_geom(14.7, 25.0, 'The Churning Mists'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 54, 'The Sea of Clouds', 06, 6, '/lookout', get_xiv_zone_geom(06, 6, 'The Sea of Clouds'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 55, 'The Sea of Clouds', 26.7, 6.9, '/lookout', get_xiv_zone_geom(26.7, 6.9, 'The Sea of Clouds'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 56, 'The Sea of Clouds', 09.9, 28.7, '/lookout', get_xiv_zone_geom(09.9, 28.7, 'The Sea of Clouds'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 57, 'The Dravanian Hinterlands', 12.2, 13.0, '/lookout', get_xiv_zone_geom(12.2, 13.0, 'The Dravanian Hinterlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 58, 'The Dravanian Hinterlands', 19.7, 38.1, '/lookout', get_xiv_zone_geom(19.7, 38.1, 'The Dravanian Hinterlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 59, 'The Dravanian Hinterlands', 30.4, 31.3, '/lookout', get_xiv_zone_geom(30.4, 31.3, 'The Dravanian Hinterlands'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 60, 'Azys Lla', 10, 14.8, '/lookout', get_xiv_zone_geom(10, 14.8, 'Azys Lla'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 61, 'Azys Lla', 35.6, 6.4, '/lookout', get_xiv_zone_geom(35.6, 6.4, 'Azys Lla'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('HW', 'HW', 62, 'Azys Lla', 25.9, 28.6, '/lookout', get_xiv_zone_geom(25.9, 28.6, 'Azys Lla'));

INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 1, 'The Fringes', 21.9, 26.9, '/lookout', get_xiv_zone_geom(21.9, 26.9, 'The Fringes'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 2, 'The Fringes', 24.2, 16.2, '/lookout', get_xiv_zone_geom(24.2, 16.2, 'The Fringes'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 3, 'The Fringes', 23.2, 7.2, '/lookout', get_xiv_zone_geom(23.2, 7.2, 'The Fringes'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 4, 'The Fringes', 9.3, 10.8, '/lookout', get_xiv_zone_geom(9.3, 10.8, 'The Fringes'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 5, 'The Fringes', 8.6, 26.4, '/lookout', get_xiv_zone_geom(8.6, 26.4, 'The Fringes'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 6, 'The Fringes', 36.5, 16.4, '/lookout', get_xiv_zone_geom(36.5, 16.4, 'The Fringes'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 7, 'The Fringes', 30.0, 25.2, '/lookout', get_xiv_zone_geom(30.0, 25.2, 'The Fringes'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 8, 'The Peaks', 33.3, 10.2, '/lookout', get_xiv_zone_geom(33.3, 10.2, 'The Peaks'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 9, 'The Peaks', 27.0, 36.8, '/lookout', get_xiv_zone_geom(27.0, 36.8, 'The Peaks'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 10, 'The Peaks', 22.0, 32.8, '/lookout', get_xiv_zone_geom(22.0, 32.8, 'The Peaks'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 11, 'The Peaks', 25.1, 5.8, '/lookout', get_xiv_zone_geom(25.1, 5.8, 'The Peaks'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 12, 'The Peaks', 19.9, 23.4, '/lookout', get_xiv_zone_geom(19.9, 23.4, 'The Peaks'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 13, 'The Peaks', 8.1, 37.5, '/lookout', get_xiv_zone_geom(8.1, 37.5, 'The Peaks'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 14, 'The Peaks', 18.3, 14.3, '/lookout', get_xiv_zone_geom(18.3, 14.3, 'The Peaks'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 15, 'The Peaks', 7.5, 7.6, '/lookout', get_xiv_zone_geom(7.5, 7.6, 'The Peaks'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 16, 'The Lochs', 23.5, 33.7, '/lookout', get_xiv_zone_geom(23.5, 33.7, 'The Lochs'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 17, 'The Lochs', 35.2, 33.2, '/lookout', get_xiv_zone_geom(35.2, 33.2, 'The Lochs'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 18, 'The Lochs', 13.8, 35.5, '/lookout', get_xiv_zone_geom(13.8, 35.5, 'The Lochs'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 19, 'The Lochs', 20.5, 16.5, '/pray', get_xiv_zone_geom(20.5, 16.5, 'The Lochs'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 20, 'The Lochs', 33.9, 30.2, '/lookout', get_xiv_zone_geom(33.9, 30.2, 'The Lochs'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 21, 'The Lochs', 5.9, 22.0, '/lookout', get_xiv_zone_geom(5.9, 22.0, 'The Lochs'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 22, 'Kugane', 14.3, 9.6, '/lookout', get_xiv_zone_geom(14.3, 9.6, 'Kugane'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 23, 'Kugane', 9.4, 7.3, '/sit', get_xiv_zone_geom(9.4, 7.3, 'Kugane'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 24, 'Kugane', 13.2, 12.7, '/lookout', get_xiv_zone_geom(13.2, 12.7, 'Kugane'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 25, 'Kugane', 11.9, 11.7, '/lookout', get_xiv_zone_geom(11.9, 11.7, 'Kugane'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 26, 'Kugane', 10.2, 10.0, '/lookout', get_xiv_zone_geom(10.2, 10.0, 'Kugane'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 27, 'The Ruby Sea', 25.9, 13.0, '/lookout', get_xiv_zone_geom(25.9, 13.0, 'The Ruby Sea'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 28, 'The Ruby Sea', 32.9, 8.7, '/lookout', get_xiv_zone_geom(32.9, 8.7, 'The Ruby Sea'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 29, 'The Ruby Sea', 24.0, 5.6, '/lookout', get_xiv_zone_geom(24.0, 5.6, 'The Ruby Sea'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 30, 'The Ruby Sea', 31.5, 37.2, '/lookout', get_xiv_zone_geom(31.5, 37.2, 'The Ruby Sea'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 31, 'The Ruby Sea', 10.1, 26.7, '/lookout', get_xiv_zone_geom(10.1, 26.7, 'The Ruby Sea'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 32, 'The Ruby Sea', 6.4, 10.8, '/lookout', get_xiv_zone_geom(6.4, 10.8, 'The Ruby Sea'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 33, 'Yanxia', 12.4, 26.7, '/lookout', get_xiv_zone_geom(12.4, 26.7, 'Yanxia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 34, 'Yanxia', 30.3, 32.9, '/lookout', get_xiv_zone_geom(30.3, 32.9, 'Yanxia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 35, 'Yanxia', 34.3, 18.3, '/lookout', get_xiv_zone_geom(34.3, 18.3, 'Yanxia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 36, 'Yanxia', 30.4, 6.2, '/lookout', get_xiv_zone_geom(30.4, 6.2, 'Yanxia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 37, 'Yanxia', 14.8, 6.3, '/lookout', get_xiv_zone_geom(14.8, 6.3, 'Yanxia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 38, 'Yanxia', 19.5, 20.5, '/lookout', get_xiv_zone_geom(19.5, 20.5, 'Yanxia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 39, 'Yanxia', 15.2, 31.6, '/lookout', get_xiv_zone_geom(15.2, 31.6, 'Yanxia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 40, 'The Azim Steppe', 14.2, 9.8, '/lookout', get_xiv_zone_geom(14.2, 9.8, 'The Azim Steppe'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 41, 'The Azim Steppe', 12.2, 32.0, '/lookout', get_xiv_zone_geom(12.2, 32.0, 'The Azim Steppe'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 42, 'The Azim Steppe', 19.8, 33.7, '/lookout', get_xiv_zone_geom(19.8, 33.7, 'The Azim Steppe'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 43, 'The Azim Steppe', 34.5, 31.9, '/lookout', get_xiv_zone_geom(34.5, 31.9, 'The Azim Steppe'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 44, 'The Azim Steppe', 20.0, 12.6, '/pray', get_xiv_zone_geom(20.0, 12.6, 'The Azim Steppe'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 45, 'The Azim Steppe', 22.6, 21.2, '/lookout', get_xiv_zone_geom(22.6, 21.2, 'The Azim Steppe'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 46, 'Rhalgr''s Reach', 11.4, 13.9, '/lookout', get_xiv_zone_geom(11.4, 13.9, 'Rhalgr''s Reach'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 47, 'Rhalgr''s Reach', 10.5, 9.7, '/lookout', get_xiv_zone_geom(10.5, 9.7, 'Rhalgr''s Reach'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 48, 'The Fringes', 27.5, 35.1, '/lookout', get_xiv_zone_geom(27.5, 35.1, 'The Fringes'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 49, 'The Peaks', 14.3, 36.6, '/lookout', get_xiv_zone_geom(14.3, 36.6, 'The Peaks'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 50, 'The Peaks', 20.4, 22.9, '/lookout', get_xiv_zone_geom(20.4, 22.9, 'The Peaks'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 51, 'The Lochs', 17.1, 19.2, '/lookout', get_xiv_zone_geom(17.1, 19.2, 'The Lochs'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 52, 'The Lochs', 36.0, 33.5, '/lookout', get_xiv_zone_geom(36.0, 33.5, 'The Lochs'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 53, 'Kugane', 11.1, 9.9, '/lookout', get_xiv_zone_geom(11.1, 9.9, 'Kugane'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 54, 'Kugane', 9.8, 8.3, '/lookout', get_xiv_zone_geom(9.8, 8.3, 'Kugane'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 55, 'Kugane', 12.5, 10.6, '/lookout', get_xiv_zone_geom(12.5, 10.6, 'Kugane'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 56, 'Kugane', 9.9, 12.3, '/lookout', get_xiv_zone_geom(9.9, 12.3, 'Kugane'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 57, 'The Ruby Sea', 5.0, 36.4, '/lookout', get_xiv_zone_geom(5.0, 36.4, 'The Ruby Sea'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 58, 'The Ruby Sea', 9.5, 19.0, '/lookout', get_xiv_zone_geom(9.5, 19.0, 'The Ruby Sea'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 59, 'The Ruby Sea', 21.5, 11.9, '/lookout', get_xiv_zone_geom(21.5, 11.9, 'The Ruby Sea'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 60, 'Yanxia', 35.6, 38.8, '/lookout', get_xiv_zone_geom(35.6, 38.8, 'Yanxia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 61, 'The Azim Steppe', 31.3, 11.5, '/lookout', get_xiv_zone_geom(31.3, 11.5, 'The Azim Steppe'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('SB', 'SB', 62, 'The Azim Steppe', 21.8, 20.3, '/lookout', get_xiv_zone_geom(21.8, 20.3, 'The Azim Steppe'));

INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 1, 'The Crystarium', 8.6, 11.2, '/lookout', get_xiv_zone_geom(8.6, 11.2, 'The Crystarium'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 2, 'The Crystarium', 10.4, 13.1, '/lookout', get_xiv_zone_geom(10.4, 13.1, 'The Crystarium'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 3, 'The Crystarium', 9.9, 5.9, '/lookout', get_xiv_zone_geom(9.9, 5.9, 'The Crystarium'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 4, 'The Crystarium', 11.0, 4.7, '/lookout', get_xiv_zone_geom(11.0, 4.7, 'The Crystarium'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 5, 'The Crystarium', 7.1, 9.6, '/lookout', get_xiv_zone_geom(7.1, 9.6, 'The Crystarium'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 6, 'Eulmore', 11.7, 8.4, '/lookout', get_xiv_zone_geom(11.7, 8.4, 'Eulmore'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 7, 'Eulmore', 12.4, 14.0, '/lookout', get_xiv_zone_geom(12.4, 14.0, 'Eulmore'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 8, 'Eulmore', 11.1, 11.4, '/lookout', get_xiv_zone_geom(11.1, 11.4, 'Eulmore'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 9, 'Eulmore', 12.3, 10.4, '/lookout', get_xiv_zone_geom(12.3, 10.4, 'Eulmore'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 10, 'Lakeland', 37.4, 20.9, '/lookout', get_xiv_zone_geom(37.4, 20.9, 'Lakeland'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 11, 'Lakeland', 18.4, 18.7, '/lookout', get_xiv_zone_geom(18.4, 18.7, 'Lakeland'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 12, 'Lakeland', 22.1, 15.1, '/lookout', get_xiv_zone_geom(22.1, 15.1, 'Lakeland'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 13, 'Lakeland', 6.3, 15.2, '/lookout', get_xiv_zone_geom(6.3, 15.2, 'Lakeland'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 14, 'Lakeland', 8.7, 22.9, '/lookout', get_xiv_zone_geom(8.7, 22.9, 'Lakeland'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 15, 'Lakeland', 21.5, 36.2, '/lookout', get_xiv_zone_geom(21.5, 36.2, 'Lakeland'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 16, 'Kholusia', 33.2, 28.9, '/lookout', get_xiv_zone_geom(33.2, 28.9, 'Kholusia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 17, 'Kholusia', 28.8, 22.1, '/lookout', get_xiv_zone_geom(28.8, 22.1, 'Kholusia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 18, 'Kholusia', 23.6, 38.1, '/lookout', get_xiv_zone_geom(23.6, 38.1, 'Kholusia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 19, 'Kholusia', 18.2, 29.3, '/lookout', get_xiv_zone_geom(18.2, 29.3, 'Kholusia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 20, 'Kholusia', 12.1, 22.1, '/lookout', get_xiv_zone_geom(12.1, 22.1, 'Kholusia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 21, 'Kholusia', 13.6, 9.8, '/lookout', get_xiv_zone_geom(13.6, 9.8, 'Kholusia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 22, 'Kholusia', 37.1, 11.5, '/lookout', get_xiv_zone_geom(37.1, 11.5, 'Kholusia'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 23, 'Amh Araeng', 33.6, 13.5, '/lookout', get_xiv_zone_geom(33.6, 13.5, 'Amh Araeng'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 24, 'Amh Araeng', 25.3, 16.6, '/lookout', get_xiv_zone_geom(25.3, 16.6, 'Amh Araeng'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 25, 'Amh Araeng', 28.5, 31.9, '/lookout', get_xiv_zone_geom(28.5, 31.9, 'Amh Araeng'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 26, 'Amh Araeng', 22.1, 9.4, '/lookout', get_xiv_zone_geom(22.1, 9.4, 'Amh Araeng'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 27, 'Amh Araeng', 11.1, 16.9, '/lookout', get_xiv_zone_geom(11.1, 16.9, 'Amh Araeng'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 28, 'Amh Araeng', 20.4, 21.3, '/lookout', get_xiv_zone_geom(20.4, 21.3, 'Amh Araeng'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 29, 'Il Mheg', 14.8, 31.9, '/lookout', get_xiv_zone_geom(14.8, 31.9, 'Il Mheg'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 30, 'Il Mheg', 8.7, 16.8, '/lookout', get_xiv_zone_geom(8.7, 16.8, 'Il Mheg'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 31, 'Il Mheg', 20.2, 4.6, '/lookout', get_xiv_zone_geom(20.2, 4.6, 'Il Mheg'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 32, 'Il Mheg', 21.4, 20.9, '/lookout', get_xiv_zone_geom(21.4, 20.9, 'Il Mheg'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 33, 'Il Mheg', 20.8, 16.3, '/lookout', get_xiv_zone_geom(20.8, 16.3, 'Il Mheg'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 34, 'Il Mheg', 35.7, 24.8, '/lookout', get_xiv_zone_geom(35.7, 24.8, 'Il Mheg'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 35, 'The Rak''tika Greatwood', 13.6, 32.5, '/lookout', get_xiv_zone_geom(13.6, 32.5, 'The Rak''tika Greatwood'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 36, 'The Rak''tika Greatwood', 8.9, 25.1, '/lookout', get_xiv_zone_geom(8.9, 25.1, 'The Rak''tika Greatwood'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 37, 'The Rak''tika Greatwood', 4.3, 27.2, '/lookout', get_xiv_zone_geom(4.3, 27.2, 'The Rak''tika Greatwood'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 38, 'The Rak''tika Greatwood', 14.1, 18.3, '/lookout', get_xiv_zone_geom(14.1, 18.3, 'The Rak''tika Greatwood'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 39, 'The Rak''tika Greatwood', 29.1, 19.0, '/lookout', get_xiv_zone_geom(29.1, 19.0, 'The Rak''tika Greatwood'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 40, 'The Rak''tika Greatwood', 26.4, 10.0, '/lookout', get_xiv_zone_geom(26.4, 10.0, 'The Rak''tika Greatwood'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 41, 'The Tempest', 33.0, 16.2, '/lookout', get_xiv_zone_geom(33.0, 16.2, 'The Tempest'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 42, 'The Tempest', 34.5, 25.4, '/lookout', get_xiv_zone_geom(34.5, 25.4, 'The Tempest'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 43, 'The Tempest', 37.1, 6.6, '/lookout', get_xiv_zone_geom(37.1, 6.6, 'The Tempest'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 44, 'The Tempest', 34.3, 30.6, '/lookout', get_xiv_zone_geom(34.3, 30.6, 'The Tempest'));
INSERT INTO sightseeing (xpac, segment, idx, zone, x, y, emote, geom) VALUES ('ShB', 'ShB', 45, 'The Tempest', 13.7, 36.8, '/lookout', get_xiv_zone_geom(13.7, 36.8, 'The Tempest'));