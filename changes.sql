-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

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
    replace(replace(nodes.name, '<i>', ''), '</i>', '') as name,
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
    replace(replace(nodes.name, '<i>', ''), '</i>', '') as name,
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