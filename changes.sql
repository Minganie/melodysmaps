-- pg_restore.exe -U postgres -d postgres --create D:\Programmes\xampp\htdocs\melodysmaps\ffxivall20190521.backup
-- pg_restore.exe -U postgres -d postgres --create C:\xampp\htdocs\melodysmaps\ffxivall20190524.backup
ALTER DATABASE ffxiv SET search_path TO ffxiv, public;

DROP VIEW vbaits;
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

-- RUN MOLESTONE HERE

INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA PLD', 'Gladiator');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('GLA PLD', 'Paladin');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('', '');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('', '');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('', '');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('', '');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('', '');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('', '');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('', '');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('', '');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('', '');
INSERT INTO discipline_group_lists (disc_group, disc) VALUES ('', '');


--------- SHOPS
DROP TABLE IF EXISTS merchant_currency_tabs;
DROP TABLE IF EXISTS merchant_second_tabs;
DROP TABLE IF EXISTS merchant_first_tabs;
CREATE TABLE merchant_first_tabs (
    merchant text references merchants(lid),
    tab      text,
    PRIMARY KEY (merchant, tab)
);
GRANT SELECT ON merchant_first_tabs TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_first_tabs TO ffxivrw;

CREATE TABLE merchant_second_tabs (
    merchant text,
    tab      text,
    subtab   text,
    FOREIGN KEY (merchant, tab) REFERENCES merchant_first_tabs(merchant, tab),
    PRIMARY KEY (merchant, tab, subtab)
);
GRANT SELECT ON merchant_second_tabs TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_second_tabs TO ffxivrw;

CREATE TYPE merchant_good_type AS ENUM ('Items', 'Venture', 'Action');
CREATE TABLE merchant_good (
    id SERIAL PRIMARY KEY,
    type merchant_good_type not null,
    venture int,
    actionName text,
    actionIcon text,
    actionEffect text,
    actionDuration int
);
GRANT SELECT ON merchant_good TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_good TO ffxivrw;
CREATE TABLE merchant_good_list (
    merchant_good references merchant_good(id),
    item text references items(lid),
    hq boolean,
    primary key(merchant_good, item, hq)
);
GRANT SELECT ON merchant_good_list TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_good_list TO ffxivrw;


CREATE TYPE merchant_price_type AS ENUM ('Gil', 'Items', 'Tokens and Items', 'Tokens', 'Seals', 'FCC');
CREATE TABLE merchant_price (
    id serial primary key,
    type merchant_price_type,
    gil int,
    token_name text,
    token_n int,
    seals int,
    rank text references grand_company_ranks(name),
    gc text references grand_companies(name),
    fcc_rank int,
    fcc_credits int
);
GRANT SELECT ON merchant_price TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_price TO ffxivrw;

CREATE TABLE merchant_price_list (
    merchant_price references merchant_price(id),
    item text references items(lid),
    hq boolean,
    primary key(merchant_price, item, hq)
);
GRANT SELECT ON merchant_price_list TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_price_list TO ffxivrw;

CREATE TYPE merchant_sale_type AS ENUM ('Gil', 'Currency', 'Seals', 'Credits');
CREATE TABLE merchant_sales (
    id SERIAL PRIMARY KEY,
    merchant text references merchant(lid),
    type sale_type NOT NULL,
    tab text,
    subtab text,
    merch int not null references merchant_good(id),
    price int not null references merchant_price(id),
    FOREIGN KEY (merchant, tab) REFERENCES merchant_first_tabs(merchant, tab),
    FOREIGN KEY (merchant, tab, subtab) REFERENCES merchant_second_tabs (merchant, tab, subtab),
    UNIQUE(merchant, merch, price)
);
GRANT SELECT ON merchant_sales TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_sales TO ffxivrw;