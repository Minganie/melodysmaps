-- pg_dump -F c -f ffxiv20190624.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190705.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190625.backup
-- ALTER DATABASE ffxiv SET search_path TO ffxiv, public;

-- Remove old tables that didn't know you could pay or buy with more than one item
DROP TABLE IF EXISTS bought_where_payment;
DROP TABLE IF EXISTS bought_where;
DROP TABLE IF EXISTS merchant_prices_list;
DROP TABLE IF EXISTS merchant_goods_list;
DROP TABLE IF EXISTS merchant_sales;
DROP TABLE IF EXISTS merchant_second_tabs;
DROP TABLE IF EXISTS merchant_first_tabs;
DROP TABLE IF EXISTS merchant_currency_tabs;
DROP TABLE IF EXISTS merchant_goods;
DROP TABLE IF EXISTS merchant_prices;
DROP TYPE IF EXISTS merchant_sale_type;
DROP TYPE IF EXISTS merchant_good_type;
DROP TYPE IF EXISTS merchant_price_type;

-- I'll deal with lids later
DROP TRIGGER add_merchant_lid ON ffxiv.merchants;
DROP TRIGGER replace_merchant_lid ON ffxiv.merchants;
DROP TRIGGER add_duty_lid ON ffxiv.duties_each;
DROP TRIGGER replace_duty_lid ON ffxiv.duties_each;

-- For realz now
DROP VIEW vsearchables;

ALTER TABLE merchants 
    --ADD CONSTRAINT merchants_mobile_fkey FOREIGN KEY (lid) REFERENCES mobiles(lid),
    DROP CONSTRAINT merchants_pkey,
    DROP CONSTRAINT merchants_lid_key,
    ADD CONSTRAINT merchants_pkey PRIMARY KEY (lid),
    DROP COLUMN gid,
    DROP COLUMN name, 
    DROP COLUMN geom;
ALTER TABLE mobiles 
    ALTER COLUMN geom TYPE geometry(MultiPoint, 4326) USING ST_Multi(geom),
    DROP COLUMN x,
    DROP COLUMN y,
    DROP COLUMN map;
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
 SELECT 0 AS id,
    m.lid,
    'Merchant'::text AS category,
    'Merchant Stall'::text AS category_name,
    ((mm.name || ' ('::text) || (SELECT z.name FROM zones as z where ST_contains(z.geom, st_geometryn(mm.geom, 1)) LIMIT 1)) || ')'::text AS name,
    mm.name AS real_name,
    NULL::text AS mode,
    NULL::integer AS sort_order
   FROM merchants as m
     JOIN mobiles as mm ON m.lid=mm.lid
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
-- because I've discovered npcs can be in several spots, geom is multipoint now
-- I'm going to need a function to create a multipoint geom now from a series of (x,y,zone)
CREATE TYPE zoned_coords AS (x real, y real, zone text);
CREATE OR REPLACE FUNCTION get_multipoint(VARIADIC c zoned_coords[])
    RETURNS geometry(MultiPoint, 4326)
    LANGUAGE 'sql'
AS $BODY$
    SELECT ST_Collect(get_xiv_zone_geom(x, y, zone))
    FROM 
    (
        SELECT (c).x as x, (c).y as y, (c).zone as zone
        FROM(SELECT unnest(c) as c)a
    )b;
$BODY$;

CREATE TYPE merchant_sale_type AS ENUM ('Gil', 'Currency', 'Seals', 'Credits');
CREATE TABLE merchant_first_tabs (
    merchant text references merchants(lid),
    type merchant_sale_type not null,
    tab      text,
    PRIMARY KEY (merchant, type, tab)
);
GRANT SELECT ON merchant_first_tabs TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_first_tabs TO ffxivrw;

CREATE TABLE merchant_second_tabs (
    merchant text,
    type merchant_sale_type not null,
    tab      text,
    subtab   text,
    FOREIGN KEY (merchant, type, tab) REFERENCES merchant_first_tabs(merchant, type, tab),
    PRIMARY KEY (merchant, type, tab, subtab)
);
GRANT SELECT ON merchant_second_tabs TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_second_tabs TO ffxivrw;

CREATE TYPE merchant_good_type AS ENUM ('Items', 'Venture', 'Action');
CREATE TYPE merchant_price_type AS ENUM ('Gil', 'Items', 'Tokens and Items', 'Tokens', 'Seals', 'FCC');
CREATE TABLE merchant_sales (
    id SERIAL PRIMARY KEY,
    merchant text references merchants(lid),
    type merchant_sale_type NOT NULL,
    tab text,
    subtab text,
    -- GOOD
    good_type merchant_good_type not null,
    venture int,
    actionName text,
    actionIcon text,
    actionEffect text,
    actionDuration int,
    -- PRICE
    price_type merchant_price_type not null,
    gil int,
    token_name text,
    token_n int,
    seals int,
    rank text references grand_company_ranks(name),
    gc text references grand_companies(name),
    fcc_rank int,
    fcc_credits int,
    
    FOREIGN KEY (merchant, type, tab) REFERENCES merchant_first_tabs(merchant, type, tab),
    FOREIGN KEY (merchant, type, tab, subtab) REFERENCES merchant_second_tabs (merchant, type, tab, subtab)
);
GRANT SELECT ON merchant_sales TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_sales TO ffxivrw;
GRANT USAGE ON merchant_sales_id_seq TO ffxivro;

CREATE TABLE merchant_goods_list (
    merchant_sale int REFERENCES merchant_sales(id) ON DELETE CASCADE,
    item text references items(lid),
    hq boolean,
    n int not null,
    primary key(merchant_sale, item, hq)
);
GRANT SELECT ON merchant_goods_list TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_goods_list TO ffxivrw;

CREATE TABLE merchant_prices_list (
    merchant_sale int REFERENCES merchant_sales(id) ON DELETE CASCADE,
    item text references items(lid),
    hq boolean,
    n int not null,
    primary key(merchant_sale, item, hq)
);
GRANT SELECT ON merchant_prices_list TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_prices_list TO ffxivrw;

-- now fix all the get_* functions involving shops

-- currency was a mess of items + others, remove it and keep only the "tokens" in currency tab in game
DROP TABLE IF EXISTS immaterials;
CREATE TABLE immaterials(
    name text PRIMARY KEY,
    icon text not null
);
GRANT SELECT ON immaterials TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON immaterials TO ffxivrw;
INSERT INTO immaterials(name, icon) VALUES 
    ('Gil', 'icons/currency/gil.png'),
    ('Company Credits', 'icons/currency/freecompanycredits.png'), 
    ('Wolf Mark', 'https://img.finalfantasyxiv.com/lds/h/k/OPI7V9dIFw_6-OmnV02TG-ZARw.png'),
    ('Allied Seal', 'https://img.finalfantasyxiv.com/lds/h/x/5loDl_ED5NG37Aa8mPwnGFxUQ8.png'),
    ('Centurio Seal', 'https://img.finalfantasyxiv.com/lds/h/d/vq92ub8-5YUHdRKR1pZ24aQ0mE.png'), 
    ('Storm Seals', 'https://img.finalfantasyxiv.com/lds/h/U/CCNK6X-ZCF7GuNMs8wCscgepGM.png'), 
    ('Serpent Seals', 'https://img.finalfantasyxiv.com/lds/h/N/Ixq2noiX81fAWg5gn1j2_1T1hg.png'), 
    ('Flame Seals', 'https://img.finalfantasyxiv.com/lds/h/h/7LOaAVLlcypX_l9QjCvZQy5Ot0.png'), 
    ('Yellow Crafters''s Scrip', 'https://img.finalfantasyxiv.com/lds/h/b/RFlwSqbdB54J0HLFqvJ0TNU7kU.png'), 
    ('Yellow Gatherers''s Scrip', 'https://img.finalfantasyxiv.com/lds/h/D/qp79vkP79nFgPeDrx53Er59OPg.png'),
    ('White Crafters''s Scrip', 'https://img.finalfantasyxiv.com/lds/h/U/rJKUbxNkQVeN72t6rfKgBPbAoI.png'), 
    ('White Gatherers''s Scrip', 'https://img.finalfantasyxiv.com/lds/h/F/Jud8K4-LquMpsdmomg3-NLbTTY.png'),
    ('Allagan Tomestone of Poetics', 'https://img.finalfantasyxiv.com/lds/h/p/yLKCqTGCJ_XMtEbBMBnPMlJR8s.png'),
    ('Titan Cobaltpiece', 'https://img.finalfantasyxiv.com/lds/h/I/pfJyIgGQrDNczK2kC25Bz-ezMo.png'),
    ('Rainbowtide Psashp', 'https://img.finalfantasyxiv.com/lds/h/g/7qgI94imE1F4mkoIdFe4U9dE80.png'),
    ('Sylphic Goldleaf', 'https://img.finalfantasyxiv.com/lds/h/i/tseLKFAHet6_DsP9qTvIanx9Pc.png'),
    ('Ixali Oaknot', 'https://img.finalfantasyxiv.com/lds/h/n/Q5Wvc6byqyJO6xOTsqodWVseA8.png'),
    ('Steel Amalj''ok', 'https://img.finalfantasyxiv.com/lds/h/a/gPSbmFS9zkkyhWQF_qviwczJYk.png'),
    ('Vanu Whitebone', 'https://img.finalfantasyxiv.com/lds/h/4/cKP9n0UbuxMAficgw-QPT2cSMI.png'),
    ('Carved Kupo Nut', 'https://img.finalfantasyxiv.com/lds/h/8/fSIyOkmSt3xoogPFnWFdNN65_U.png'),
    ('Ananta Dreamstaff', 'https://img.finalfantasyxiv.com/lds/h/V/6SS4KVY-PXgKkXiK1iT2TNrE_c.png'),
    ('Black Copper Gil', 'https://img.finalfantasyxiv.com/lds/h/D/EF4K6-InlG87wu0aSQyNJ7xz_A.png'),
    ('Kojin Sango', 'https://img.finalfantasyxiv.com/lds/h/Y/-jYbCURBTKmYaSCTokNqtf2mcM.png'),
    ('Namazu Koban', 'https://img.finalfantasyxiv.com/lds/h/v/oq0mt2vhDKy57eMiDv-zOUy2nc.png'),
    ('Allagan Tomestone of Goetia', 'https://img.finalfantasyxiv.com/lds/h/V/azNdNNaNg7gYB4jT7_fCvBUTsM.png')
    ;
ALTER TABLE quests DROP CONSTRAINT quests_bt_currency_fkey,
    ADD CONSTRAINT quests_bt_currency_fkey FOREIGN KEY (bt_currency) REFERENCES currency(name);
ALTER TABLE beast_tribes 
    DROP CONSTRAINT beast_tribes_currency_key,
    ADD CONSTRAINT beast_tribes_currency_fkey FOREIGN KEY (currency) REFERENCES immaterials(name);
-- and here you run into that little landmine of duty chests... give them index like the encounters, sigh...
ALTER TABLE duty_chests
    DROP CONSTRAINT duty_chests_ukey,
    ADD CONSTRAINT duty_chests_ukey UNIQUE (duty, idx);
ALTER TABLE pvps 
    ALTER COLUMN rank_3_xp DROP NOT NULL,
    ALTER COLUMN rank_3_wolf DROP NOT NULL;
CREATE OR REPLACE VIEW ffxiv.vdungeons AS
 SELECT 0::int as id,
    d.lid,
    d.name ||
        CASE d.mode
            WHEN 'Regular'::text THEN ''::text
            WHEN 'Hard'::text THEN ' (Hard)'::text
            WHEN 'Extreme'::text THEN ' (Extreme)'::text
            WHEN 'Savage'::text THEN ' (Savage)'::text
            WHEN 'Ultimate'::text THEN ' (Ultimate)'::text
            ELSE NULL::text
        END AS name,
    d.name AS real_name,
    d.mode,
    m.sort_order
   FROM duties dn
     JOIN duties_each d ON d.name = dn.name
     JOIN modes m ON d.mode = m.name
  WHERE dn.cat = 'Dungeon'::text
  ORDER BY d.name, m.sort_order;
CREATE OR REPLACE VIEW ffxiv.vraids AS
 SELECT 0::int as id,
    d.lid,
    d.name ||
        CASE d.mode
            WHEN 'Regular'::text THEN ''::text
            WHEN 'Hard'::text THEN ' (Hard)'::text
            WHEN 'Extreme'::text THEN ' (Extreme)'::text
            WHEN 'Savage'::text THEN ' (Savage)'::text
            WHEN 'Ultimate'::text THEN ' (Ultimate)'::text
            ELSE NULL::text
        END AS name,
    d.name AS real_name,
    d.mode,
    m.sort_order
   FROM duties dn
     JOIN duties_each d ON d.name = dn.name
     JOIN modes m ON d.mode = m.name
  WHERE dn.cat = 'Raid'::text
  ORDER BY d.name, m.sort_order;
CREATE OR REPLACE VIEW ffxiv.vtrials AS
 SELECT 0::int as id,
    d.lid,
    d.name ||
        CASE d.mode
            WHEN 'Regular'::text THEN ''::text
            WHEN 'Hard'::text THEN ' (Hard)'::text
            WHEN 'Extreme'::text THEN ' (Extreme)'::text
            WHEN 'Savage'::text THEN ' (Savage)'::text
            WHEN 'Ultimate'::text THEN ' (Ultimate)'::text
            ELSE NULL::text
        END AS name,
    d.name AS real_name,
    d.mode,
    m.sort_order
   FROM duties dn
     JOIN duties_each d ON dn.name = d.name
     JOIN modes m ON d.mode = m.name
  WHERE dn.cat = 'Trial'::text
  ORDER BY d.name, m.sort_order;
BEGIN;
    ALTER TABLE duty_encounters
        DROP CONSTRAINT duty_bosses_duty_ref_fkey;
    ALTER TABLE duty_chests
        DROP CONSTRAINT duty_chests_duty_ref_fkey;
    ALTER TABLE duty_maps
        DROP CONSTRAINT duty_maps_duty_ref_fkey;
    ALTER TABLE duty_trash_drops
        DROP CONSTRAINT duty_trash_drops_duty_ref_fkey;
    ALTER TABLE quest_requirements
        DROP CONSTRAINT quest_requirements_dutylid_fkey;
    ALTER TABLE duties_each
        DROP CONSTRAINT duties_each_pkey,
        DROP CONSTRAINT duties_each_lid_key,
        ADD CONSTRAINT duties_each_pkey PRIMARY KEY (lid),
        DROP COLUMN id;
    ALTER TABLE duty_encounters
        ADD CONSTRAINT duty_bosses_duty_ref_fkey FOREIGN KEY (duty) REFERENCES ffxiv.duties_each (lid);
    ALTER TABLE duty_chests
        ADD CONSTRAINT duty_chests_duty_ref_fkey FOREIGN KEY (duty) REFERENCES ffxiv.duties_each (lid);
    ALTER TABLE duty_maps
        ADD CONSTRAINT duty_maps_duty_ref_fkey FOREIGN KEY (duty) REFERENCES ffxiv.duties_each (lid);
    ALTER TABLE duty_trash_drops
        ADD CONSTRAINT duty_trash_drops_duty_ref_fkey FOREIGN KEY (duty) REFERENCES ffxiv.duties_each (lid);
    ALTER TABLE quest_requirements
        ADD CONSTRAINT quest_requirements_dutylid_fkey FOREIGN KEY (dutylid) REFERENCES ffxiv.duties_each (lid);
COMMIT;

ALTER TABLE pvp_tokens 
    DROP CONSTRAINT pvp_tokens_token_fkey;
 -- FIX DUTIES HERE
ALTER TABLE duty_encounter_tokens 
    DROP CONSTRAINT duty_boss_tokens_token_fkey, 
    ADD CONSTRAINT duty_boss_tokens_token_fkey FOREIGN KEY (token) REFERENCES immaterials(name);
ALTER TABLE pvp_tokens 
    ADD CONSTRAINT pvp_tokens_token_fkey FOREIGN KEY (token) REFERENCES immaterials(name);
ALTER TABLE quests 
    DROP CONSTRAINT quests_tomestones_fkey, 
    ADD CONSTRAINT quests_tomestones_fkey FOREIGN KEY (tomestones) REFERENCES immaterials(name),
    DROP CONSTRAINT quests_bt_currency_fkey,
    ADD CONSTRAINT quests_bt_currency_fkey FOREIGN KEY (bt_currency) REFERENCES immaterials(name);
DROP TABLE currency;

CREATE OR REPLACE FUNCTION get_immaterial(name text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
    SELECT json_build_object(
        'name', name,
        'icon', icon
    )
    FROM immaterials
    WHERE name=$1;
$BODY$;
CREATE OR REPLACE FUNCTION get_immaterial(gc text, seals text)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    part text;
    res json;
BEGIN
    IF seals <> 'Seals' THEN
        RAISE EXCEPTION 'Trying to get seals without the magic word?';
    END IF;
    SELECT particule INTO STRICT part FROM grand_companies WHERE name=$1;
    res := get_immaterial(part || ' Seals');
    RETURN res;
END;
$BODY$;

-- Back to merchants...
CREATE OR REPLACE FUNCTION get_merchant_good (sale merchant_sales)
    returns json
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    good json;
    good_items json;
BEGIN
    CASE sale.good_type
        WHEN 'Venture'::merchant_good_type THEN
            good := json_build_object(
                'type', 'Venture',
                'venture', sale.venture,
                'item', get_item('8b5789fb581')
            );
        WHEN 'Action'::merchant_good_type THEN
            good := json_build_object(
                'type', 'Action',
                'name', sale.actionname,
                'icon', sale.actionicon,
                'effect', sale.actioneffect,
                'duration', sale.actionduration
            );
        WHEN 'Items'::merchant_good_type THEN
            SELECT json_agg(item) INTO STRICT good_items
            FROM (
                SELECT json_build_object(
                    'item', get_item(item),
                    'hq', hq,
                    'n', n
                ) as item
                FROM merchant_goods_list
                WHERE merchant_sale=sale.id
            )a;
            good := json_build_object(
                'type', 'Items',
                'goods', good_items
            );
    END CASE;
    RETURN good;
END;
$BODY$;

CREATE OR REPLACE FUNCTION get_merchant_price (sale merchant_sales)
    returns json
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    price json;
    price_items json;
BEGIN
    CASE sale.price_type
    --('Gil', 'Items', 'Tokens and Items', 'Tokens', 'Seals', 'FCC');
        WHEN 'Gil'::merchant_price_type THEN
            price := json_build_object(
                'type', 'Gil',
                'n_gil', sale.gil,
                'gil', get_immaterial('Gil')
            );
        WHEN 'Items'::merchant_price_type THEN
            SELECT json_agg(item) INTO STRICT price_items
            FROM (
                SELECT json_build_object(
                    'item', get_item(item),
                    'hq', hq,
                    'n', n
                ) as item
                FROM merchant_goods_list
                WHERE merchant_sale=sale.id
            )a;
            price := json_build_object(
                'type', 'Items',
                'items', price_items
            );
        WHEN 'Tokens and Items'::merchant_price_type THEN
            SELECT json_agg(item) INTO STRICT price_items
            FROM (
                SELECT json_build_object(
                    'item', get_item(item),
                    'hq', hq,
                    'n', n
                ) as item
                FROM merchant_goods_list
                WHERE merchant_sale=sale.id
            )a;
            price := json_build_object(
                'type', 'Tokens and Items',
                'token_name', sale.token_name,
                'token_n', sale.token_n,
                'token', get_immaterial(sale.token_name),
                'items', price_items
            );
        WHEN 'Tokens'::merchant_price_type THEN
            price := json_build_object(
                'type', 'Tokens',
                'token_name', sale.token_name,
                'token_n', sale.token_n,
                'token', get_immaterial(sale.token_name)
            );
        WHEN 'Seals'::merchant_price_type THEN
            price := json_build_object(
                'type', 'Seals',
                'seals', sale.seals,
                'rank', sale.rank,
                'gc', sale.gc,
                'token', get_immaterial(sale.gc, 'Seals')
            );
        WHEN 'FCC'::merchant_price_type THEN
            price := json_build_object(
                'type', 'FCC',
                'credits', sale.fcc_credits,
                'rank', sale.fcc_rank,,
                'token', get_immaterial('Company Credits')
            );
    END CASE;
    RETURN price;
END;
$BODY$;

CREATE OR REPLACE FUNCTION get_merchant_sale (saleid int)
    returns json
    LANGUAGE 'sql'
AS $BODY$
    SELECT json_build_object(
        'price', get_merchant_price(merchant_sales),
        'good', get_merchant_good(merchant_sales)
    )
    FROM merchant_sales
    WHERE id = $1;
$BODY$;

-- get_all_tabs(merchantlid)
-- {
    -- gil: {zero: [sale, sale...]
        -- one: [tab, tab...]
        -- }
    -- currency: []
    -- seals:
    -- credits:
-- }
-- tab= {
    -- name: ""
    -- sales: [sale, sale...]
    -- subtabs: [tab, tab...]
-- }
-- sale= {
    -- good: {item, venture, action}
    -- price: {gil, item, token, itemtoken, fcc}
-- }

CREATE OR REPLACE FUNCTION better_json_merge(leftarg json, rightarg json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    res jsonb := leftarg;
    leftargb jsonb := leftarg::jsonb;
    rightargb jsonb := rightarg::jsonb;
    leftvalue jsonb;
    rightvalue jsonb;
    overwrite jsonb;
    kv record;
BEGIN
    IF json_typeof(leftarg) = 'object' AND json_typeof(rightarg) = 'object' THEN
        FOR kv IN SELECT * FROM jsonb_each(rightargb) LOOP
            IF leftargb ? kv.key THEN
                -- merge recursively...
                leftvalue := leftargb->kv.key;
                rightvalue := kv.value;
                overwrite := leftvalue::json <+< rightvalue::json;
            ELSE
                overwrite = kv.value;
            END IF;
            res := res || jsonb_build_object(kv.key, overwrite);
        END LOOP;
    ELSIF json_typeof(leftarg) = 'array' AND json_typeof(rightarg) = 'array' THEN
        res:= leftargb || rightargb;
    ELSE
        RAISE EXCEPTION 'Incompatible json merge types: (%) <+< (%)', json_typeof(leftarg), json_typeof(rightarg);
    END IF;
    RETURN res::json;
END;
$BODY$;

CREATE OPERATOR <+< (
    FUNCTION = better_json_merge,
    LEFTARG = json,
    RIGHTARG = json
);

CREATE OR REPLACE FUNCTION get_merchant_tabs(merchantlid text)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    all_tabs json := '{}'::json;
    tabs json;
    ntabs int;
    nsubtabs int;
    _tab text;
    _subtab text;
    sale_type merchant_sale_type;
BEGIN
    FOR sale_type IN SELECT enum_range(NULL::merchant_sale_type) LOOP
        SELECT count(tab) INTO STRICT ntabs FROM merchant_first_tabs WHERE merchant=$1 and type=sale_type;
        IF ntabs = 0 THEN
            SELECT json_agg(get_merchant_sale(id)) INTO STRICT tabs FROM merchant_sales WHERE merchant=$1 AND type=sale_type;
            -- tabs = [{sale}, {sale}, ...]
            all_tabs := all_tabs <+ json_build_object(sale_type::text, json_build_object('zero', tabs));
        ELSE
            FOR _tab IN SELECT tab FROM merchant_first_tabs WHERE merchant=$1 and type=sale_type LOOP
                SELECT count(subtab) INTO STRICT nsubtabs FROM merchant_second_tabs WHERE merchant=$1 AND type=sale_type AND tab=_tab;
                IF nsubtabs = 0 THEN
                    SELECT json_build_object(
                        'name', tab,
                        'sales', sales
                    ) INTO STRICT tabs 
                    FROM (
                        SELECT tab, json_agg(get_merchant_sale(id)) as sales 
                        FROM merchant_sales 
                        WHERE merchant=$1 AND type=sale_type AND tab=_tab
                        GROUP BY tab
                    )a;
                    -- tabs = [{tab}] where tab = {name: '', sales: []}
                    all_tabs := all_tabs <+ json_build_object(sale_type::text, json_build_object('one', tabs));
                ELSE
                    FOR _subtab IN SELECT subtab FROM merchant_second_tabs WHERE merchant=$1 AND type=sale_type AND tab=_tab LOOP
                        SELECT json_build_object(
                            'name', tab,
                            'subtabs', subtabs
                        ) INTO STRICT tabs
                        FROM (
                            SELECT tab, json_agg(subtabs) as subtabs
                            FROM (
                                SELECT tab, json_build_object(
                                    'name', subtab,
                                    'sales', sales
                                ) as subtabs
                                FROM (
                                    SELECT tab, subtab, json_agg(get_merchant_sale(id)) as sales
                                    FROM merchant_sales
                                    WHERE merchant=$1 AND type=sale_type AND tab=_tab AND subtab=_subtab
                                    GROUP BY tab, subtab
                                )a
                            )b
                            GROUP BY tab
                        )c;
                        -- tabs = [{tab}] where tab = {name: '', subtabs: [{tab}, {tab}, ...]}
                        all_tabs := all_tabs <+ json_build_object(sale_type::text, json_build_object('one', tabs));
                    END LOOP;
                END IF;
            END LOOP;
        END IF;
    END LOOP;
    RETURN all_tabs;
END;
$BODY$;

DROP FUNCTION IF EXISTS get_currencies();
DROP FUNCTION IF EXISTS get_currency(text);

-- get_merchant
CREATE OR REPLACE FUNCTION ffxiv.get_merchant(
	merchantlid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$

select json_build_object(
    'id', m.gid,
    'lid', m.lid,
    'name', m.name,
    'label', m.name || ' (' || (select m.name from zones as z where st_contains(z.geom, m.geom)) || ')',
	'category', get_category('Merchant'),
    'requirement', get_requirement(requires),
	'all_tabs', get_all_tabs(lid),
    'zone', get_zone((select lid from zones as z where st_contains(z.geom, m.geom))),
	'geom', get_vertices(geom),
	'bounds', get_bounds(geom),
	'centroid', get_centroid_coords(geom)
)
from merchants as m
where lid=$1;

$BODY$;

-- get item merchants
CREATE OR REPLACE FUNCTION ffxiv.get_item_merchants(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$

SELECT json_agg(get_merchant(merchantlid)) as merchants  
FROM (
    SELECT DISTINCT ms.merchant as merchantlid
    FROM merchant_goods_list as mgl
        JOIN merchant_sales as ms ON mgl.merchant_sale=ms.id
    WHERE mgl.item=$1
)a;
$BODY$;

-- RUN THE MOLESTONE
ALTER TABLE merchants 
    ADD CONSTRAINT merchants_mobile_fkey FOREIGN KEY (lid) REFERENCES mobiles(lid);