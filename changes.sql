CREATE TABLE lottery_types(
    name text PRIMARY KEY
);
GRANT SELECT ON lottery_types TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON lottery_types TO ffxivrw;
INSERT INTO lottery_types (name) VALUES 
-- mgp card packs
('Bronze Triad Card'), ('Silver Triad Card'), ('Gold Triad Card'), ('Platinum Triad Card'), ('Mythril Triad Card'), ('Imperial Triad Card'), ('Dream Triad Card'), 
-- eureka
 -- inventory items
('Anemos Lockbox'), ('Pagos Lockbox'), ('Cold-warped Lockbox'), ('Pyros Lockbox'), ('Heat-warped Lockbox'), ('Hydatos Lockbox'), ('Moisture-warped Lockbox'), 
 -- chests
('Happy Bunny Bonze Treasure Chest'), ('Happy Bunny Silver Treasure Chest'), ('Happy Bunny Gold Treasure Chest'), 
-- potd
('Bronze-trimmed Sack'), ('Iron-trimmed Sack'), ('Silver-trimmed Sack'), ('Gold-trimmed Sack'), 
-- hoh
('Silver-haloed Sack'),  ('Gold-haloed Sack'), ('Platinum-haloed Sack'),
-- kupo of fortune
('Kupo of Fortune'),
-- retainers
('Field Exploration I'), 
('Field Exploration II'), 
('Field Exploration III'), 
('Field Exploration IV'), 
('Field Exploration V'), 
('Field Exploration VI'), 
('Field Exploration VII'), 
('Field Exploration VIII'), 
('Field Exploration IX'), 
('Field Exploration X'), 
('Field Exploration XI'), 
('Field Exploration XII'), 
('Field Exploration XIII'), 
('Field Exploration XIV'), 
('Field Exploration XV'), 
('Field Exploration XVI'), 
('Field Exploration XVII'), 
('Field Exploration XVIII'), 
('Field Exploration XIX'), 
('Field Exploration XX'), 
('Field Exploration XXI'), 
('Field Exploration XXII'), 
('Field Exploration XXIII'), 
('Field Exploration XXIV'), 
('Field Exploration XXV'), 
('Highland Exploration I'), 
('Highland Exploration II'), 
('Highland Exploration III'), 
('Highland Exploration IV'), 
('Highland Exploration V'), 
('Highland Exploration VI'), 
('Highland Exploration VII'), 
('Highland Exploration VIII'), 
('Highland Exploration IX'), 
('Highland Exploration X'), 
('Highland Exploration XI'), 
('Highland Exploration XII'), 
('Highland Exploration XIII'), 
('Highland Exploration XIV'), 
('Highland Exploration XV'), 
('Highland Exploration XVI'), 
('Highland Exploration XVII'), 
('Highland Exploration XVIII'), 
('Highland Exploration XIX'), 
('Highland Exploration XX'), 
('Highland Exploration XXI'), 
('Highland Exploration XXII'), 
('Highland Exploration XXIII'), 
('Highland Exploration XXIV'), 
('Highland Exploration XXV'), 
('Woodland Exploration I'), 
('Woodland Exploration II'), 
('Woodland Exploration III'), 
('Woodland Exploration IV'), 
('Woodland Exploration V'), 
('Woodland Exploration VI'), 
('Woodland Exploration VII'), 
('Woodland Exploration VIII'), 
('Woodland Exploration IX'), 
('Woodland Exploration X'), 
('Woodland Exploration XI'), 
('Woodland Exploration XII'), 
('Woodland Exploration XIII'), 
('Woodland Exploration XIV'), 
('Woodland Exploration XV'), 
('Woodland Exploration XVI'), 
('Woodland Exploration XVII'), 
('Woodland Exploration XVIII'), 
('Woodland Exploration XIX'), 
('Woodland Exploration XX'), 
('Woodland Exploration XXI'), 
('Woodland Exploration XXII'), 
('Woodland Exploration XXIII'), 
('Woodland Exploration XXIV'), 
('Woodland Exploration XXV'), 
('Waterside Exploration I'), 
('Waterside Exploration II'), 
('Waterside Exploration III'), 
('Waterside Exploration IV'), 
('Waterside Exploration V'), 
('Waterside Exploration VI'), 
('Waterside Exploration VII'), 
('Waterside Exploration VIII'), 
('Waterside Exploration IX'), 
('Waterside Exploration X'), 
('Waterside Exploration XI'), 
('Waterside Exploration XII'), 
('Waterside Exploration XIII'), 
('Waterside Exploration XIV'), 
('Waterside Exploration XV'), 
('Waterside Exploration XVI'), 
('Waterside Exploration XVII'), 
('Waterside Exploration XVIII'), 
('Waterside Exploration XIX'), 
('Waterside Exploration XX'), 
('Waterside Exploration XXI'), 
('Waterside Exploration XXII'), 
('Waterside Exploration XXIII'), 
('Waterside Exploration XXIV'), 
('Waterside Exploration XXV'), 
('Quick Exploration'),
-- maps
('Timeworn Leather Map'), 
('Timeworn Goatskin Map'), 
('Timeworn Toadskin Map'), 
('Timeworn Boarskin Map'), 
('Timeworn Peisteskin Map'), 
('Timeworn Archaeoskin Map'), 
('Timeworn Wyvernskin Map'), 
('Timeworn Dragonskin Map'), 
('Timeworn Gaganaskin Map'), 
('Timeworn Gazelleskin Map'), 
('Timeworn Gliderskin Map'), 
('Timeworn Zonureskin Map'), 
('Timeworn Thief''s Map'),
('Unhidden Leather Map');

CREATE TABLE lottery(
    lottery text REFERENCES lottery_types(name),
    item text REFERENCES items(lid),
    drop_rate real,
    PRIMARY KEY(lottery, item)
);
GRANT SELECT ON lottery_types TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON lottery_types TO ffxivrw;

CREATE TABLE triad_categories (
    name text PRIMARY KEY
);
GRANT SELECT ON triad_categories TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON triad_categories TO ffxivrw;
INSERT INTO triad_categories (name) VALUES ('Primal'), ('Scion'), ('Beastman'), ('Garlean');

CREATE TABLE triad_rules (
    name text PRIMARY KEY
);
GRANT SELECT ON triad_rules TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON triad_rules TO ffxivrw;
INSERT INTO triad_rules (name) VALUES 
('All Open'), 
('Three Open'), 
('Random'), 
('Roulette'), 
('Sudden Death'), 
('Swap'), 
('Plus'), 
('Same'), 
('Fallen Ace'), 
('Order'), 
('Chaos'), 
('Reverse'), 
('Ascension'), 
('Descension');

CREATE TABLE triad_cards (
    name text PRIMARY KEY,
    stars int NOT NULL CHECK(stars>0 AND stars<6),
    card_type text REFERENCES triad_categories(name),
    north int NOT NULL CHECK(north>0 AND north<11),
    east  int NOT NULL CHECK(east>0 AND east<11),
    south int NOT NULL CHECK(south>0 AND south<11),
    west  int NOT NULL CHECK(west>0 AND west<11),
    icon text,
    lid text REFERENCES items(lid),
    first_deck boolean NOT NULL default FALSE,
    event text,
    tournament text
);
GRANT SELECT ON triad_cards TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON triad_cards TO ffxivrw;

CREATE TABLE triad_npcs (
    name text primary key,
    geom geometry(Point, 4326) NOT NULL,
    cost int NOT NULL CHECK(cost>=0),
    loss int NOT NULL CHECK(loss>=0),
    draw int NOT NULL CHECK(draw>=0),
    win int NOT NULL CHECK(win>=0)
);
GRANT SELECT ON triad_npcs TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON triad_npcs TO ffxivrw;
CREATE INDEX triad_npc_geom_idx
  ON triad_npcs
  USING GIST (geom);

CREATE TABLE triad_npc_decks (
    npc text REFERENCES triad_npcs(name),
    card text REFERENCES triad_cards(name),
    always boolean NOT NULL DEFAULT false,
    PRIMARY KEY (npc, card)
);
GRANT SELECT ON triad_npc_decks TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON triad_npc_decks TO ffxivrw;

CREATE TABLE triad_npc_rules (
    id SERIAL PRIMARY KEY,
    npc text REFERENCES triad_npcs(name),
    rule text REFERENCES triad_rules(name)
);
GRANT SELECT ON triad_npc_rules TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON triad_npc_rules TO ffxivrw;

CREATE TABLE triad_npc_rewards (
    npc text REFERENCES triad_npcs(name),
    card text REFERENCES triad_cards(name),
    PRIMARY KEY (npc, card)
);
GRANT SELECT ON triad_npc_rewards TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON triad_npc_rewards TO ffxivrw;

CREATE TABLE triad_npc_conditions (
    npc text REFERENCES triad_npcs(name),
    quest text REFERENCES quests(lid),
    PRIMARY KEY (npc, quest)
);
GRANT SELECT ON triad_npc_conditions TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON triad_npc_conditions TO ffxivrw;

INSERT INTO categories (name, pretty_name, red_icon, gold_icon, tooltip, map_icon, lid) VALUES ('Triad NPC', 'Triple Triad NPC', 'icons/red/triad.png', 'icons/gold/triad.png', 'An NPC that will play Triple Triad with you', 'icons/map/npc.png', 'Triad NPC');

CREATE OR REPLACE FUNCTION ffxiv.get_triad_card(
	name text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
    SELECT row_to_json(c)
    FROM triad_cards as c
    WHERE c.name=$1 or c.name || ' Card'=$1;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
  SELECT json_build_object(
    'lid', i.lid,
    'licon', i.licon,
    'name', i.name,
    'category', get_category('Item'),
    'bonuses', get_item_bonuses(lid),
    'disciplines', disc,
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
    'dresser_able', i.dresser_able,
    'armoire_able', i.armoire_able,
    'meld_ilvl', i.meld_ilvl,
    'fish_conditions', get_fish_conditions(i.lid),
    'card', get_triad_card(i.name)
  )
   FROM items i
   WHERE lid = $1
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_triad_npc(
	name text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
WITH ze_rules AS
(
    SELECT n.name as npc, json_agg(r.rule) as rules
    FROM triad_npcs as n
    LEFT JOIN triad_npc_rules as r on n.name=r.npc
    WHERE n.name=$1
    GROUP BY n.name
),
ze_rewards AS
(
    SELECT npc, json_agg(card) as cards
    FROM (
        SELECT r.npc, get_triad_card(r.card) as card
        FROM triad_npc_rewards as r
        WHERE r.npc=$1
        ORDER BY r.card
    ) t
    GROUP BY npc
),
ze_deck AS
(
    SELECT npc, json_agg(card) as cards
    FROM (
        SELECT d.npc, 
            json_build_object(
                'always', always,
                'card', get_triad_card(d.card)
            ) as card
        FROM triad_npc_decks as d
        WHERE d.npc=$1
        ORDER BY d.always DESC, d.card
    ) u
    GROUP BY npc
),
ze_conditions AS
(
    SELECT npc, json_agg(quest) as quests
    FROM (
        SELECT c.npc, get_quest(c.quest) as quest
        FROM triad_npc_conditions AS c
        WHERE c.npc=$1
    ) v
    GROUP BY npc
)
SELECT row_to_json(w)
FROM 
(
    SELECT n.name, n.cost, n.loss, n.draw, n.win,
        0::int as id,
        name as lid,
        name as label,
        get_category('Triad NPC') as category,
        get_vertices(geom) as geom,
        get_bounds(geom) as bounds,
        get_centroid_coords(geom) as centroid,
        d.cards as deck,
        c.quests as requires,
        r.rules as rules,
        rew.cards as rewards
    FROM triad_npcs AS n
    LEFT JOIN ze_rules AS r ON n.name=r.npc
    LEFT JOIN ze_deck AS d ON n.name=d.npc
    LEFT JOIN ze_conditions AS c ON n.name=c.npc
    LEFT JOIN ze_rewards as rew ON n.name=rew.npc
    WHERE n.name=$1
) w;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item_triad(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT row_to_json(_)
FROM (
    SELECT first_deck, tournament, json_agg(npc) as npcs
    FROM (
        SELECT i.lid, c.name, c.first_deck, c.tournament, get_triad_npc(n.npc) as npc
        FROM items AS i
        LEFT JOIN triad_cards as c ON i.name=c.name || ' Card'
        LEFT JOIN triad_npc_rewards AS n ON i.name=n.card || ' Card'
        WHERE i.lid=$1
    ) a
    GROUP BY first_deck, tournament
) _;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item_lotteries(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT NULL::json
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item_fates(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT NULL::json
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item_achievements(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT NULL::json
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item_events(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT NULL::json
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item_sources(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT json_build_object(
 'nodes', get_item_nodes($1),
 'merchants', get_item_merchants($1),
 'crafters', get_item_crafters($1),
 'hunting', get_item_ms($1),
 'duties', get_item_duties($1),
 'maps', get_item_maps($1),
 'uses', get_item_uses($1),
 'leves', get_item_leves($1),
 'triad', get_item_triad($1),
 'lotteries', get_item_lotteries($1),
 'fates', get_item_fates($1),
 'achievements', get_item_achievements($1),
 'events', get_item_events($1)
);
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
    sightseeing.xpac || to_char(sightseeing.idx, 'FM000'::text) AS lid,
    'Sightseeing'::text AS category,
    'Sightseeing Entry'::text AS category_name,
    sightseeing.xpac || to_char(sightseeing.idx, 'FM000'::text) AS name,
    sightseeing.xpac || to_char(sightseeing.idx, 'FM000'::text) AS real_name,
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
UNION
 SELECT 0 AS id,
    tn.name as lid,
    'Triad NPC'::text AS category,
    'Triad NPC'::text AS category_name,
    tn.name::text AS name,
    tn.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM triad_npcs tn
ORDER BY 6, 8;