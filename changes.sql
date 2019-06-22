-- pg_restore.exe -U postgres -d postgres --create D:\Programmes\xampp\htdocs\melodysmaps\ffxivall20190521.backup
-- pg_restore.exe -U postgres -d postgres --create C:\xampp\htdocs\melodysmaps\ffxivall20190524.backup
ALTER DATABASE ffxiv SET search_path TO ffxiv, public;

CREATE OR REPLACE VIEW ffxiv.vbaits AS
 SELECT items.lcat3 as category,
    items.lid,
    items.licon,
    items.name,
    items.level
   FROM items
  WHERE items.lcat3 = 'Bait'::text;
GRANT SELECT ON TABLE ffxiv.vbaits TO ffxivro;

CREATE OR REPLACE VIEW ffxiv.vfishes AS
 SELECT items.lcat3 as category,
    items.lid,
    items.licon,
    items.name,
    items.level
   FROM items
  WHERE items.lcat3 = 'Seafood'::text 
  OR items.name = 'Gigantpole'::text 
  OR items.lcat3 = 'Bone'::text AND items.name ~~ '%Coral%'::text 
  OR items.name = 'Magic Bucket'::text 
  OR items.name = 'Tiny Tortoise'::text 
  OR items.name = 'Castaway Chocobo Chick'::text 
  OR items.name ~~ 'Timeworn%'::text;
GRANT SELECT ON TABLE ffxiv.vfishes TO ffxivro;

CREATE TABLE rarity (
    name text primary key
);
GRANT SELECT ON TABLE ffxiv.rarity TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON TABLE ffxiv.rarity TO ffxivro;
INSERT INTO rarity (name) VALUES ('Common'), ('Uncommon'), ('Rare'), ('Epic'), ('Magic');

ALTER TABLE items DROP COLUMN category;
ALTER TABLE items ADD COLUMN rarity text REFERENCES rarity(name);
ALTER TABLE items ADD COLUMN disc text REFERENCES discipline_groups(name);
DROP TABLE item_discipline;
DROP TRIGGER IF EXISTS add_item_lid ON ffxiv.items;
DROP TRIGGER IF EXISTS replace_item_lid ON ffxiv.items;

drop function if exists get_item_disciplines(text);
CREATE OR REPLACE FUNCTION ffxiv.get_item(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
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
    'meld_ilvl', i.meld_ilvl,
    'fish_conditions', get_fish_conditions(i.lid)
  )
   FROM items i
   WHERE lid = $1
$BODY$;


-- RUN MOLESTONE HERE

INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA PLD', 'Gladiator');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA PLD', 'Paladin');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ARC BRD', 'Archer');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ARC BRD', 'Bard');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('MRD WAR', 'Marauder');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('MRD WAR', 'Warrior');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('CNJ WHM', 'Conjurer');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('CNJ WHM', 'White Mage');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ROG NIN', 'Rogue');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ROG NIN', 'Ninja');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ACN SMN SCH', 'Arcanist');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ACN SMN SCH', 'Summoner');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ACN SMN SCH', 'Scholar');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ACN SMN', 'Arcanist');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ACN SMN', 'Summoner');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL MNK', 'Pugilist');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL MNK', 'Monk');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('LNC DRG', 'Lancer');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('LNC DRG', 'Dragoon');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('BLU', 'Blue Mage');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('THM BLM', 'Thaumaturge');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('THM BLM', 'Black Mage');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('THM ACN BLM SMN RDM BLU', 'Thaumaturge');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('THM ACN BLM SMN RDM BLU', 'Black Mage');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('THM ACN BLM SMN RDM BLU', 'Arcanist');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('THM ACN BLM SMN RDM BLU', 'Summoner');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('THM ACN BLM SMN RDM BLU', 'Red Mage');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('THM ACN BLM SMN RDM BLU', 'Blue Mage');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL MNK SAM', 'Pugilist');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL MNK SAM', 'Monk');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL MNK SAM', 'Samurai');
INSERT INTO discipline_group_lists (disc_group, disc) 
select 'Disciple of Magic', name from dom;
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ARC ROG BRD NIN MCH', 'Archer');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ARC ROG BRD NIN MCH', 'Rogue');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ARC ROG BRD NIN MCH', 'Bard');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ARC ROG BRD NIN MCH', 'Ninja');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ARC ROG BRD NIN MCH', 'Machinist');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL ROG MNK NIN SAM', 'Pugilist');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL ROG MNK NIN SAM', 'Rogue');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL ROG MNK NIN SAM', 'Monk');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL ROG MNK NIN SAM', 'Ninja');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL ROG MNK NIN SAM', 'Samurai');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('CNJ WHM SCH AST', 'Conjurer');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('CNJ WHM SCH AST', 'White Mage');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('CNJ WHM SCH AST', 'Scholar');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('CNJ WHM SCH AST', 'Astrologian');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA THM PLD BLM', 'Gladiator');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA THM PLD BLM', 'Thaumaturge');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA THM PLD BLM', 'Paladin');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA THM PLD BLM', 'Black Mage');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD LNC PLD WAR DRG DRK', 'Gladiator');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD LNC PLD WAR DRG DRK', 'Marauder');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD LNC PLD WAR DRG DRK', 'Lancer');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD LNC PLD WAR DRG DRK', 'Paladin');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD LNC PLD WAR DRG DRK', 'Warrior');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD LNC PLD WAR DRG DRK', 'Dragoon');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD LNC PLD WAR DRG DRK', 'Dark Knight');
INSERT INTO discipline_group_lists (disc_group, disc) 
select 'Disciple of War', name from dow;
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL LNC MNK DRG SAM', 'Pugilist');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL LNC MNK DRG SAM', 'Lancer');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL LNC MNK DRG SAM', 'Monk');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL LNC MNK DRG SAM', 'Dragoon');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('PGL LNC MNK DRG SAM', 'Samurai');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ARC BRD MCH', 'Archer');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ARC BRD MCH', 'Bard');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('ARC BRD MCH', 'Machinist');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD PLD WAR DRK', 'Gladiator');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD PLD WAR DRK', 'Marauder');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD PLD WAR DRK', 'Paladin');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD PLD WAR DRK', 'Warrior');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA MRD PLD WAR DRK', 'Dark Knight');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA CNJ THM PLD WHM BLM', 'Gladiator');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA CNJ THM PLD WHM BLM', 'Conjurer');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA CNJ THM PLD WHM BLM', 'Thaumaturge');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA CNJ THM PLD WHM BLM', 'Paladin');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA CNJ THM PLD WHM BLM', 'White Mage');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA CNJ THM PLD WHM BLM', 'Black Mage');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA CNJ PLD WHM', 'Gladiator');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA CNJ PLD WHM', 'Conjurer');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA CNJ PLD WHM', 'Paladin');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA CNJ PLD WHM', 'White Mage');
INSERT INTO discipline_group_lists (disc_group, disc) 
select 'All Classes', name from disciplines;


--------- SHOPS
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

DROP TRIGGER add_merchant_lid ON ffxiv.merchants;
DROP TRIGGER replace_merchant_lid ON ffxiv.merchants;

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