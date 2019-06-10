-- pg_restore.exe -U postgres -d postgres --create D:\Programmes\xampp\htdocs\melodysmaps\ffxivall20190521.backup
-- pg_restore.exe -U postgres -d postgres --create C:\xampp\htdocs\melodysmaps\ffxivall20190524.backup
ALTER DATABASE ffxiv SET search_path TO ffxiv, public;

DROP TABLE IF EXISTS all_lids;

DROP VIEW vsearchables;
DROP TABLE IF EXISTS recipe_conditions;
DROP TABLE IF EXISTS recipe_materials;
DROP TABLE IF EXISTS recipes;

CREATE TABLE recipes
(
    lid text PRIMARY KEY,
    discipline text NOT NULL REFERENCES doth (name),
    name text NOT NULL,
    product text NOT NULL REFERENCES items(lid),
    level integer NOT NULL,
    category text NOT NULL,
    nb integer NOT NULL,
    durability integer NOT NULL,
    difficulty integer NOT NULL,
    quality integer NOT NULL,
    licon text NOT NULL,
    mastery text,
    n_stars integer NOT NULL,
    rec_craft integer NOT NULL,
    req_craft integer NOT NULL,
    req_contr integer NOT NULL,
    req_contr_qs integer NOT NULL,
    req_craft_qs integer NOT NULL,
    aspect text,
    specialist boolean NOT NULL,
    has_qs boolean NOT NULL,
    has_hq boolean NOT NULL,
    has_coll boolean NOT NULL,
    no_xp boolean NOT NULL,
    equipment text REFERENCES items(lid),
    facility_access text
);
GRANT SELECT on recipes TO ffxivro;
GRANT INSERT, UPDATE, DELETE on recipes TO ffxivrw;

CREATE TABLE recipe_materials
(
    recipelid text NOT NULL REFERENCES recipes (lid),
    n integer NOT NULL,
    ingredient text NOT NULL REFERENCES items (lid),
    is_crystal boolean NOT NULL,
    PRIMARY KEY (recipelid, ingredient)
);
GRANT SELECT on recipe_materials TO ffxivro;
GRANT INSERT, UPDATE, DELETE on recipe_materials TO ffxivrw;

DROP TRIGGER IF EXISTS add_recipe_lid ON recipes;
-- CREATE TRIGGER add_recipe_lid
    -- AFTER INSERT
    -- ON ffxiv.recipes
    -- FOR EACH ROW
    -- EXECUTE PROCEDURE ffxiv.add_lid();
DROP TRIGGER IF EXISTS replace_recipe_lid ON recipes;    
-- CREATE TRIGGER replace_recipe_lid
    -- AFTER UPDATE 
    -- ON ffxiv.recipes
    -- FOR EACH ROW
    -- EXECUTE PROCEDURE ffxiv.replace_lid();
    
CREATE OR REPLACE FUNCTION ffxiv.get_item_uses(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
SELECT json_agg(get_recipe(recipelid))
FROM (SELECT rm.recipelid
    FROM recipe_materials as rm
        JOIN recipes as r ON rm.recipelid = r.lid
    WHERE ingredient=$1
    ORDER BY r.level) r
$BODY$;

DROP FUNCTION IF EXISTS ffxiv.get_conditions(text);

CREATE OR REPLACE FUNCTION ffxiv.get_crystals(
	recipelid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
	SELECT json_agg(json_build_object(
		'n', n,
		'material', get_item(ingredient)
	))
	FROM recipe_materials
	WHERE is_crystal AND recipelid=$1;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_recipe(
	recipelid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
  SELECT json_build_object(
    'id', lid,
	'discipline', r.discipline, 
	'name', r.name, 
    'label', name,
	'level', r.level, 
	'cat', r.category, 
	'nb', r.nb, 
	'durability', r.durability, 
	'difficulty', r.difficulty, 
	'quality', r.quality, 
	'lid', r.lid, 
	'licon', r.licon,
	'product', get_item(product),
	'materials', get_materials(lid),
    'crystals', get_crystals(lid),
    'mastery', mastery,
    'n_stars', n_stars,
    'rec_craft', rec_craft,
    'req_craft', req_craft,
    'req_contr', req_contr,
    'req_contr_qs', req_contr_qs,
    'req_craft_qs', req_craft_qs,
    'aspect', aspect,
    'specialist', specialist,
    'has_qs', has_qs,
    'has_hq', has_hq,
    'has_coll', has_coll,
    'no_xp', no_xp,
    'equipment', equipment,
    'facility_access', facility_access
	)
  FROM recipes AS r
  WHERE lid=$1;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_materials(
	recipelid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
	SELECT json_agg(json_build_object(
		'n', n,
		'material', get_item(ingredient)
	))
	FROM recipe_materials
	WHERE NOT is_crystal AND recipelid=$1;
$BODY$;


INSERT INTO categories (name, pretty_name, red_icon, gold_icon, tooltip, lid) VALUES ('Recipe', 'Recipe', 'icons/red/recipe.png', 'icons/gold/recipe.png', 'A recipe you may craft', 'Recipe');

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
 SELECT 0 as id,
    r.lid,
    'Recipe'::text AS category,
    'Recipe'::text AS category_name,
    (r.name || ' (' || r.discipline || ')') as name,
    r.name as real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM recipes as r
  ORDER BY 6, 8;
GRANT SELECT ON TABLE ffxiv.vsearchables TO ffxivro;
