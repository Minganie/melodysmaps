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
