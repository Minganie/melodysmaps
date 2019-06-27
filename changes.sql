-- pg_dump -F c -f ffxiv20190624.backup ffxiv
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190625.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190625.backup
ALTER DATABASE ffxiv SET search_path TO ffxiv, public;

-- FIX ZONES VS SUBZONES
UPDATE quests SET zone='The Dravanian Hinterlands' WHERE zone='Matoya''s Cave';
DELETE FROM zones WHERE name='Company Workshop'
    or name='Matoya''s Cave'
    or name='Topmast Apartment Lobby';
DELETE FROM invis_zones WHERE name='Company Workshop';

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

-- For realz now
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
    icon text not null,
    deprecated boolean not null DEFAULT false
);
GRANT SELECT ON immaterials TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON immaterials TO ffxivrw;
INSERT INTO immaterials(name, icon) VALUES 
    ('Gil', 'icons/currency/gil.png'), 
    ('Company Credits', ''), 
    ('Storm Seals', ''), 
    ('Serpent Seals', ''), 
    ('Flame Seals', ''), 
    ('Allagan Tomestone of Verity', ''), 
    ('Allagan Tomestone of Genesis', ''), 
    ('Allagan Tomestone of Mendacity', ''), 
    ('Allagan Tomestone of Poetics', '');
ALTER TABLE duty_encounter_tokens DROP CONSTRAINT duty_boss_tokens_token_fkey, ADD CONSTRAINT duty_boss_tokens_token_fkey FOREIGN KEY (token) REFERENCES immaterials(name);
ALTER TABLE pvp_tokens DROP CONSTRAINT pvp_tokens_token_fkey, ADD CONSTRAINT pvp_tokens_token_fkey FOREIGN KEY (token) REFERENCES immaterials(name);
ALTER TABLE quests DROP CONSTRAINT quests_tomestones_fkey, ADD CONSTRAINT quests_tomestones_fkey FOREIGN KEY (tomestones) REFERENCES immaterials(name);
DROP TABLE currency;
CREATE OR REPLACE FUNCTION get_immaterial(name text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
    SELECT json_build_object(
        'name', name,
        'icon', icon,
        'deprecated', deprecated
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

-- FIXME: beast tribe currencies are items aren't they? but the molestone for merchants isn't getting that lid...

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
    'id', gid,
    'lid', lid,
    'name', name,
    'label', name || ' (' || (select name from zones as z where st_contains(z.geom, m.geom)) || ')',
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