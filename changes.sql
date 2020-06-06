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
    lid text REFERENCES items(lid)
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

UPDATE triad_cards SET icon='082101.tex.png' WHERE name='Dodo';
UPDATE triad_cards SET icon='082102.tex.png' WHERE name='Tonberry';
UPDATE triad_cards SET icon='082103.tex.png' WHERE name='Sabotender';
UPDATE triad_cards SET icon='082104.tex.png' WHERE name='Spriggan';
UPDATE triad_cards SET icon='082105.tex.png' WHERE name='Pudding';
UPDATE triad_cards SET icon='082106.tex.png' WHERE name='Bomb';
UPDATE triad_cards SET icon='082107.tex.png' WHERE name='Mandragora';
UPDATE triad_cards SET icon='082108.tex.png' WHERE name='Coblyn';
UPDATE triad_cards SET icon='082109.tex.png' WHERE name='Morbol';
UPDATE triad_cards SET icon='082110.tex.png' WHERE name='Coeurl';
UPDATE triad_cards SET icon='082111.tex.png' WHERE name='Ahriman';
UPDATE triad_cards SET icon='082112.tex.png' WHERE name='Goobbue';
UPDATE triad_cards SET icon='082113.tex.png' WHERE name='Chocobo';
UPDATE triad_cards SET icon='082114.tex.png' WHERE name='Amalj''aa';
UPDATE triad_cards SET icon='082115.tex.png' WHERE name='Ixal';
UPDATE triad_cards SET icon='082116.tex.png' WHERE name='Sylph';
UPDATE triad_cards SET icon='082117.tex.png' WHERE name='Kobold';
UPDATE triad_cards SET icon='082118.tex.png' WHERE name='Sahagin';
UPDATE triad_cards SET icon='082119.tex.png' WHERE name='Tataru Taru';
UPDATE triad_cards SET icon='082120.tex.png' WHERE name='Moogle';
UPDATE triad_cards SET icon='082121.tex.png' WHERE name='Siren';
UPDATE triad_cards SET icon='082122.tex.png' WHERE name='Ultros & Typhon';
UPDATE triad_cards SET icon='082123.tex.png' WHERE name='Demon Wall';
UPDATE triad_cards SET icon='082124.tex.png' WHERE name='Succubus';
UPDATE triad_cards SET icon='082125.tex.png' WHERE name='Chimera';
UPDATE triad_cards SET icon='082126.tex.png' WHERE name='Blue Dragon';
UPDATE triad_cards SET icon='082127.tex.png' WHERE name='Scarface Bugaal Ja';
UPDATE triad_cards SET icon='082128.tex.png' WHERE name='Momodi Modi';
UPDATE triad_cards SET icon='082129.tex.png' WHERE name='Baderon Tenfingers';
UPDATE triad_cards SET icon='082130.tex.png' WHERE name='Mother Miounne';
UPDATE triad_cards SET icon='082131.tex.png' WHERE name='Livia sas Junius';
UPDATE triad_cards SET icon='082132.tex.png' WHERE name='Rhitahtyn sas Arvina';
UPDATE triad_cards SET icon='082133.tex.png' WHERE name='Biggs & Wedge';
UPDATE triad_cards SET icon='082134.tex.png' WHERE name='Gerolt';
UPDATE triad_cards SET icon='082135.tex.png' WHERE name='Frixio';
UPDATE triad_cards SET icon='082136.tex.png' WHERE name='Mutamix Bubblypots';
UPDATE triad_cards SET icon='082137.tex.png' WHERE name='Memeroon';
UPDATE triad_cards SET icon='082138.tex.png' WHERE name='Behemoth';
UPDATE triad_cards SET icon='082139.tex.png' WHERE name='Gilgamesh & Enkidu';
UPDATE triad_cards SET icon='082140.tex.png' WHERE name='Ifrit';
UPDATE triad_cards SET icon='082141.tex.png' WHERE name='Titan';
UPDATE triad_cards SET icon='082142.tex.png' WHERE name='Garuda';
UPDATE triad_cards SET icon='082143.tex.png' WHERE name='Good King Moggle Mog XII';
UPDATE triad_cards SET icon='082144.tex.png' WHERE name='Raya-O-Senna & A-Ruhn-Senna';
UPDATE triad_cards SET icon='082145.tex.png' WHERE name='Godbert Manderville';
UPDATE triad_cards SET icon='082146.tex.png' WHERE name='Thancred';
UPDATE triad_cards SET icon='082147.tex.png' WHERE name='Nero tol Scaeva';
UPDATE triad_cards SET icon='082148.tex.png' WHERE name='Papalymo & Yda';
UPDATE triad_cards SET icon='082149.tex.png' WHERE name='Y''shtola';
UPDATE triad_cards SET icon='082150.tex.png' WHERE name='Urianger';
UPDATE triad_cards SET icon='082151.tex.png' WHERE name='The Ultima Weapon';
UPDATE triad_cards SET icon='082152.tex.png' WHERE name='Odin';
UPDATE triad_cards SET icon='082153.tex.png' WHERE name='Ramuh';
UPDATE triad_cards SET icon='082154.tex.png' WHERE name='Leviathan';
UPDATE triad_cards SET icon='082155.tex.png' WHERE name='Shiva';
UPDATE triad_cards SET icon='082156.tex.png' WHERE name='Minfilia';
UPDATE triad_cards SET icon='082157.tex.png' WHERE name='Lahabrea';
UPDATE triad_cards SET icon='082158.tex.png' WHERE name='Cid Garlond';
UPDATE triad_cards SET icon='082159.tex.png' WHERE name='Alphinaud & Alisaie';
UPDATE triad_cards SET icon='082160.tex.png' WHERE name='Louisoix Leveilleur';
UPDATE triad_cards SET icon='082161.tex.png' WHERE name='Bahamut';
UPDATE triad_cards SET icon='082162.tex.png' WHERE name='Hildibrand & Nashu Mhakaracca';
UPDATE triad_cards SET icon='082163.tex.png' WHERE name='Nanamo Ul Namo';
UPDATE triad_cards SET icon='082164.tex.png' WHERE name='Gaius van Baelsar';
UPDATE triad_cards SET icon='082165.tex.png' WHERE name='Merlwyb Bloefhiswyn';
UPDATE triad_cards SET icon='082166.tex.png' WHERE name='Kan-E-Senna';
UPDATE triad_cards SET icon='082167.tex.png' WHERE name='Raubahn Aldynn';
UPDATE triad_cards SET icon='082168.tex.png' WHERE name='Warrior of Light';
UPDATE triad_cards SET icon='082169.tex.png' WHERE name='Firion';
UPDATE triad_cards SET icon='082170.tex.png' WHERE name='Onion Knight';
UPDATE triad_cards SET icon='082171.tex.png' WHERE name='Cecil Harvey';
UPDATE triad_cards SET icon='082172.tex.png' WHERE name='Bartz Klauser';
UPDATE triad_cards SET icon='082173.tex.png' WHERE name='Terra Branford';
UPDATE triad_cards SET icon='082174.tex.png' WHERE name='Cloud Strife';
UPDATE triad_cards SET icon='082175.tex.png' WHERE name='Squall Leonhart';
UPDATE triad_cards SET icon='082176.tex.png' WHERE name='Zidane Tribal';
UPDATE triad_cards SET icon='082177.tex.png' WHERE name='Tidus';
UPDATE triad_cards SET icon='082178.tex.png' WHERE name='Shantotto';
UPDATE triad_cards SET icon='082179.tex.png' WHERE name='Vaan';
UPDATE triad_cards SET icon='082180.tex.png' WHERE name='Lightning';
UPDATE triad_cards SET icon='082181.tex.png' WHERE name='Gaelicat';
UPDATE triad_cards SET icon='082182.tex.png' WHERE name='Vanu Vanu';
UPDATE triad_cards SET icon='082183.tex.png' WHERE name='Gnath';
UPDATE triad_cards SET icon='082184.tex.png' WHERE name='Yugiri Mistwalker';
UPDATE triad_cards SET icon='082185.tex.png' WHERE name='Fat Chocobo';
UPDATE triad_cards SET icon='082186.tex.png' WHERE name='Griffin';
UPDATE triad_cards SET icon='082187.tex.png' WHERE name='Tioman';
UPDATE triad_cards SET icon='082188.tex.png' WHERE name='Estinien';
UPDATE triad_cards SET icon='082189.tex.png' WHERE name='Lucia goe Junius';
UPDATE triad_cards SET icon='082190.tex.png' WHERE name='Ysayle';
UPDATE triad_cards SET icon='082191.tex.png' WHERE name='Hilda';
UPDATE triad_cards SET icon='082192.tex.png' WHERE name='Matoya';
UPDATE triad_cards SET icon='082193.tex.png' WHERE name='Count Edmont de Fortemps';
UPDATE triad_cards SET icon='082194.tex.png' WHERE name='Byblos';
UPDATE triad_cards SET icon='082195.tex.png' WHERE name='Haurchefant';
UPDATE triad_cards SET icon='082196.tex.png' WHERE name='Aymeric';
UPDATE triad_cards SET icon='082197.tex.png' WHERE name='Ravana';
UPDATE triad_cards SET icon='082198.tex.png' WHERE name='Bismarck';
UPDATE triad_cards SET icon='082199.tex.png' WHERE name='Nidhogg';
UPDATE triad_cards SET icon='082200.tex.png' WHERE name='Midgardsormr';
UPDATE triad_cards SET icon='082201.tex.png' WHERE name='Deepeye';
UPDATE triad_cards SET icon='082202.tex.png' WHERE name='Archaeornis';
UPDATE triad_cards SET icon='082203.tex.png' WHERE name='Paissa';
UPDATE triad_cards SET icon='082204.tex.png' WHERE name='Dhalmel';
UPDATE triad_cards SET icon='082205.tex.png' WHERE name='Bandersnatch';
UPDATE triad_cards SET icon='082206.tex.png' WHERE name='Crawler';
UPDATE triad_cards SET icon='082207.tex.png' WHERE name='Poroggo';
UPDATE triad_cards SET icon='082208.tex.png' WHERE name='Vedrfolnir';
UPDATE triad_cards SET icon='082209.tex.png' WHERE name='Coeurlregina';
UPDATE triad_cards SET icon='082210.tex.png' WHERE name='Progenitrix';
UPDATE triad_cards SET icon='082211.tex.png' WHERE name='Belladonna';
UPDATE triad_cards SET icon='082212.tex.png' WHERE name='Echidna';
UPDATE triad_cards SET icon='082213.tex.png' WHERE name='Pipin Tarupin';
UPDATE triad_cards SET icon='082214.tex.png' WHERE name='Julyan Manderville';
UPDATE triad_cards SET icon='082215.tex.png' WHERE name='Moglin';
UPDATE triad_cards SET icon='082216.tex.png' WHERE name='Charibert';
UPDATE triad_cards SET icon='082217.tex.png' WHERE name='Roundrox';
UPDATE triad_cards SET icon='082218.tex.png' WHERE name='Senor Sabotender';
UPDATE triad_cards SET icon='082219.tex.png' WHERE name='Regula van Hydrus';
UPDATE triad_cards SET icon='082220.tex.png' WHERE name='Archbishop Thordan VII';
UPDATE triad_cards SET icon='082221.tex.png' WHERE name='Honoroit';
UPDATE triad_cards SET icon='082222.tex.png' WHERE name='Hoary Boulder & Coultenet';
UPDATE triad_cards SET icon='082223.tex.png' WHERE name='Brachiosaur';
UPDATE triad_cards SET icon='082224.tex.png' WHERE name='Darkscale';
UPDATE triad_cards SET icon='082225.tex.png' WHERE name='Fenrir';
UPDATE triad_cards SET icon='082226.tex.png' WHERE name='Kraken';
UPDATE triad_cards SET icon='082227.tex.png' WHERE name='Vicegerent to the Warden';
UPDATE triad_cards SET icon='082228.tex.png' WHERE name='Manxome Molaa Ja Ja';
UPDATE triad_cards SET icon='082229.tex.png' WHERE name='Ferdiad';
UPDATE triad_cards SET icon='082230.tex.png' WHERE name='Calcabrina';
UPDATE triad_cards SET icon='082231.tex.png' WHERE name='Kuribu';
UPDATE triad_cards SET icon='082232.tex.png' WHERE name='Phlegethon';
UPDATE triad_cards SET icon='082233.tex.png' WHERE name='Artoirel de Fortemps';
UPDATE triad_cards SET icon='082234.tex.png' WHERE name='Emmanellain de Fortemps';
UPDATE triad_cards SET icon='082235.tex.png' WHERE name='Xande';
UPDATE triad_cards SET icon='082236.tex.png' WHERE name='Brute Justice';
UPDATE triad_cards SET icon='082237.tex.png' WHERE name='Sephirot';
UPDATE triad_cards SET icon='082238.tex.png' WHERE name='F''lhaminn';
UPDATE triad_cards SET icon='082239.tex.png' WHERE name='Vidofnir';
UPDATE triad_cards SET icon='082240.tex.png' WHERE name='Cloud of Darkness';
UPDATE triad_cards SET icon='082241.tex.png' WHERE name='Lolorito Nanarito';
UPDATE triad_cards SET icon='082242.tex.png' WHERE name='Gibrillont';
UPDATE triad_cards SET icon='082243.tex.png' WHERE name='Laniaitte de Haillenarte';
UPDATE triad_cards SET icon='082244.tex.png' WHERE name='Rhoswen';
UPDATE triad_cards SET icon='082245.tex.png' WHERE name='Carvallain de Gorgagne';
UPDATE triad_cards SET icon='082246.tex.png' WHERE name='Kal Myhk';
UPDATE triad_cards SET icon='082247.tex.png' WHERE name='Waukkeon';
UPDATE triad_cards SET icon='082248.tex.png' WHERE name='Curator';
UPDATE triad_cards SET icon='082249.tex.png' WHERE name='Mistbeard';
UPDATE triad_cards SET icon='082250.tex.png' WHERE name='Unei & Doga';
UPDATE triad_cards SET icon='082251.tex.png' WHERE name='Tiamat';
UPDATE triad_cards SET icon='082252.tex.png' WHERE name='Calofisteri';
UPDATE triad_cards SET icon='082253.tex.png' WHERE name='Hraesvelgr';
UPDATE triad_cards SET icon='082254.tex.png' WHERE name='Apkallu';
UPDATE triad_cards SET icon='082255.tex.png' WHERE name='Colibri';
UPDATE triad_cards SET icon='082256.tex.png' WHERE name='Magitek Death Claw';
UPDATE triad_cards SET icon='082257.tex.png' WHERE name='Liquid Flame';
UPDATE triad_cards SET icon='082258.tex.png' WHERE name='Lost Lamb';
UPDATE triad_cards SET icon='082259.tex.png' WHERE name='Delivery Moogle';
UPDATE triad_cards SET icon='082260.tex.png' WHERE name='Magitek Colossus';
UPDATE triad_cards SET icon='082261.tex.png' WHERE name='Strix';
UPDATE triad_cards SET icon='082262.tex.png' WHERE name='Tozol Huatotl';
UPDATE triad_cards SET icon='082263.tex.png' WHERE name='Alexander Prime';
UPDATE triad_cards SET icon='082264.tex.png' WHERE name='Brendt, Brennan, & Bremondt';
UPDATE triad_cards SET icon='082265.tex.png' WHERE name='Heavensward Thancred';
UPDATE triad_cards SET icon='082266.tex.png' WHERE name='Heavensward Y''shtola';
UPDATE triad_cards SET icon='082267.tex.png' WHERE name='Nael van Darnus';
UPDATE triad_cards SET icon='082268.tex.png' WHERE name='Sophia';
UPDATE triad_cards SET icon='082269.tex.png' WHERE name='Opo-opo';
UPDATE triad_cards SET icon='082270.tex.png' WHERE name='Adamantoise';
UPDATE triad_cards SET icon='082271.tex.png' WHERE name='Magitek Vanguard';
UPDATE triad_cards SET icon='082272.tex.png' WHERE name='Magitek Gunship';
UPDATE triad_cards SET icon='082273.tex.png' WHERE name='Gold Saucer Attendant';
UPDATE triad_cards SET icon='082274.tex.png' WHERE name='Lava Scorpion';
UPDATE triad_cards SET icon='082275.tex.png' WHERE name='Magitek Predator';
UPDATE triad_cards SET icon='082276.tex.png' WHERE name='Magitek Sky Armor';
UPDATE triad_cards SET icon='082277.tex.png' WHERE name='The Griffin';
UPDATE triad_cards SET icon='082278.tex.png' WHERE name='Roland';
UPDATE triad_cards SET icon='082279.tex.png' WHERE name='Diabolos Hollow';
UPDATE triad_cards SET icon='082280.tex.png' WHERE name='Armored Weapon';
UPDATE triad_cards SET icon='082281.tex.png' WHERE name='Gigi';
UPDATE triad_cards SET icon='082282.tex.png' WHERE name='Zurvan';
UPDATE triad_cards SET icon='082283.tex.png' WHERE name='Namazu';
UPDATE triad_cards SET icon='082284.tex.png' WHERE name='Kojin';
UPDATE triad_cards SET icon='082285.tex.png' WHERE name='Ananta';
UPDATE triad_cards SET icon='082286.tex.png' WHERE name='M''naago';
UPDATE triad_cards SET icon='082287.tex.png' WHERE name='Kotokaze';
UPDATE triad_cards SET icon='082288.tex.png' WHERE name='Mammoth';
UPDATE triad_cards SET icon='082289.tex.png' WHERE name='Phoebad';
UPDATE triad_cards SET icon='082290.tex.png' WHERE name='Susano';
UPDATE triad_cards SET icon='082291.tex.png' WHERE name='Lakshmi';
UPDATE triad_cards SET icon='082292.tex.png' WHERE name='Grynewaht';
UPDATE triad_cards SET icon='082293.tex.png' WHERE name='Rasho';
UPDATE triad_cards SET icon='082294.tex.png' WHERE name='Cirina';
UPDATE triad_cards SET icon='082295.tex.png' WHERE name='Magnai';
UPDATE triad_cards SET icon='082296.tex.png' WHERE name='Sadu';
UPDATE triad_cards SET icon='082297.tex.png' WHERE name='Shinryu';
UPDATE triad_cards SET icon='082298.tex.png' WHERE name='Yotsuyu';
UPDATE triad_cards SET icon='082299.tex.png' WHERE name='Krile';
UPDATE triad_cards SET icon='082300.tex.png' WHERE name='Lyse';
UPDATE triad_cards SET icon='082301.tex.png' WHERE name='Zenos yae Galvus';
UPDATE triad_cards SET icon='082302.tex.png' WHERE name='Hien';
UPDATE triad_cards SET icon='082303.tex.png' WHERE name='Mossling';
UPDATE triad_cards SET icon='082304.tex.png' WHERE name='Chapuli';
UPDATE triad_cards SET icon='082305.tex.png' WHERE name='Qiqirn Meateater';
UPDATE triad_cards SET icon='082306.tex.png' WHERE name='Hrodric Poisontongue';
UPDATE triad_cards SET icon='082307.tex.png' WHERE name='Fordola rem Lupis';
UPDATE triad_cards SET icon='082308.tex.png' WHERE name='Rofocale';
UPDATE triad_cards SET icon='082309.tex.png' WHERE name='Argath Thadalfus';
UPDATE triad_cards SET icon='082310.tex.png' WHERE name='Raubahn & Pipin';
UPDATE triad_cards SET icon='082311.tex.png' WHERE name='Koja';
UPDATE triad_cards SET icon='082312.tex.png' WHERE name='Ango';
UPDATE triad_cards SET icon='082313.tex.png' WHERE name='Guidance Node';
UPDATE triad_cards SET icon='082314.tex.png' WHERE name='Tansui';
UPDATE triad_cards SET icon='082315.tex.png' WHERE name='Genbu';
UPDATE triad_cards SET icon='082316.tex.png' WHERE name='Byakko';
UPDATE triad_cards SET icon='082317.tex.png' WHERE name='Arenvald Lentinus';
UPDATE triad_cards SET icon='082318.tex.png' WHERE name='Lupin';
UPDATE triad_cards SET icon='082319.tex.png' WHERE name='Hancock';
UPDATE triad_cards SET icon='082320.tex.png' WHERE name='Hisui & Kurenai';
UPDATE triad_cards SET icon='082321.tex.png' WHERE name='Wanyudo & Katasharin';
UPDATE triad_cards SET icon='082322.tex.png' WHERE name='Hatamoto';
UPDATE triad_cards SET icon='082323.tex.png' WHERE name='Yukinko';
UPDATE triad_cards SET icon='082324.tex.png' WHERE name='Qitian Dasheng';
UPDATE triad_cards SET icon='082325.tex.png' WHERE name='Hiruko';
UPDATE triad_cards SET icon='082326.tex.png' WHERE name='Happy Bunny';
UPDATE triad_cards SET icon='082327.tex.png' WHERE name='Louhi';
UPDATE triad_cards SET icon='082328.tex.png' WHERE name='Tsukuyomi';
UPDATE triad_cards SET icon='082329.tex.png' WHERE name='Yiazmat';
UPDATE triad_cards SET icon='082330.tex.png' WHERE name='Gosetsu';
UPDATE triad_cards SET icon='082331.tex.png' WHERE name='Karakuri Hanya';
UPDATE triad_cards SET icon='082332.tex.png' WHERE name='Muud Suud';
UPDATE triad_cards SET icon='082333.tex.png' WHERE name='Tokkapchi';
UPDATE triad_cards SET icon='082334.tex.png' WHERE name='Mist Dragon';
UPDATE triad_cards SET icon='082335.tex.png' WHERE name='Suzaku';
UPDATE triad_cards SET icon='082336.tex.png' WHERE name='Pazuzu';
UPDATE triad_cards SET icon='082337.tex.png' WHERE name='Penthesilea';
UPDATE triad_cards SET icon='082338.tex.png' WHERE name='Asahi sas Brutus';
UPDATE triad_cards SET icon='082339.tex.png' WHERE name='Yojimbo & Daigoro';
UPDATE triad_cards SET icon='082340.tex.png' WHERE name='Omega';
UPDATE triad_cards SET icon='082341.tex.png' WHERE name='Stormblood Tataru Taru';
UPDATE triad_cards SET icon='082342.tex.png' WHERE name='Dvergr';
UPDATE triad_cards SET icon='082343.tex.png' WHERE name='Ejika Tsunjika';
UPDATE triad_cards SET icon='082344.tex.png' WHERE name='Prometheus';
UPDATE triad_cards SET icon='082345.tex.png' WHERE name='Provenance Watcher';
UPDATE triad_cards SET icon='082346.tex.png' WHERE name='Seiryu';
UPDATE triad_cards SET icon='082347.tex.png' WHERE name='Alpha';
UPDATE triad_cards SET icon='082348.tex.png' WHERE name='Great Gold Whisker';
UPDATE triad_cards SET icon='082349.tex.png' WHERE name='Stormblood Gilgamesh';
UPDATE triad_cards SET icon='082350.tex.png' WHERE name='Ultima, the High Seraph';
UPDATE triad_cards SET icon='082351.tex.png' WHERE name='Stormblood Alphinaud & Alisaie';
UPDATE triad_cards SET icon='082352.tex.png' WHERE name='Noctis Lucis Caelum';
UPDATE triad_cards SET icon='082353.tex.png' WHERE name='Amaro';
UPDATE triad_cards SET icon='082354.tex.png' WHERE name='Evil Weapon';
UPDATE triad_cards SET icon='082355.tex.png' WHERE name='Lord and Lady Chai';
UPDATE triad_cards SET icon='082356.tex.png' WHERE name='Gigantender';
UPDATE triad_cards SET icon='082357.tex.png' WHERE name='Feo Ul';
UPDATE triad_cards SET icon='082358.tex.png' WHERE name='Runar';
UPDATE triad_cards SET icon='082359.tex.png' WHERE name='Grenoldt';
UPDATE triad_cards SET icon='082360.tex.png' WHERE name='Philia';
UPDATE triad_cards SET icon='082361.tex.png' WHERE name='Titania';
UPDATE triad_cards SET icon='082362.tex.png' WHERE name='Eros';
UPDATE triad_cards SET icon='082363.tex.png' WHERE name='Storge';
UPDATE triad_cards SET icon='082364.tex.png' WHERE name='Formidable';
UPDATE triad_cards SET icon='082365.tex.png' WHERE name='Lyna';
UPDATE triad_cards SET icon='082366.tex.png' WHERE name='Jongleurs of Eulmore';
UPDATE triad_cards SET icon='082367.tex.png' WHERE name='Innocence';
UPDATE triad_cards SET icon='082368.tex.png' WHERE name='Shadowbringers Y''shtola';
UPDATE triad_cards SET icon='082369.tex.png' WHERE name='Shadowbringers Urianger';
UPDATE triad_cards SET icon='082370.tex.png' WHERE name='Ran''jit';
UPDATE triad_cards SET icon='082371.tex.png' WHERE name='Hades';
UPDATE triad_cards SET icon='082372.tex.png' WHERE name='Ardbert';
UPDATE triad_cards SET icon='082373.tex.png' WHERE name='Hobgoblin';
UPDATE triad_cards SET icon='082374.tex.png' WHERE name='Porxie';
UPDATE triad_cards SET icon='082375.tex.png' WHERE name='Iguana';
UPDATE triad_cards SET icon='082376.tex.png' WHERE name='Nu Mou';
UPDATE triad_cards SET icon='082377.tex.png' WHERE name='Fuath';
UPDATE triad_cards SET icon='082378.tex.png' WHERE name='Leannan Sith';
UPDATE triad_cards SET icon='082379.tex.png' WHERE name='Seeker of Solitude';
UPDATE triad_cards SET icon='082380.tex.png' WHERE name='Oracle of Light';
UPDATE triad_cards SET icon='082381.tex.png' WHERE name='Archaeotania';
UPDATE triad_cards SET icon='082382.tex.png' WHERE name='9S';
UPDATE triad_cards SET icon='082383.tex.png' WHERE name='Flower Basket';
UPDATE triad_cards SET icon='082384.tex.png' WHERE name='Qitari';
UPDATE triad_cards SET icon='082385.tex.png' WHERE name='Gnoll';
UPDATE triad_cards SET icon='082386.tex.png' WHERE name='Lizbeth';
UPDATE triad_cards SET icon='082387.tex.png' WHERE name='Batsquatch';
UPDATE triad_cards SET icon='082388.tex.png' WHERE name='Forgiven Obscenity';
UPDATE triad_cards SET icon='082389.tex.png' WHERE name='Huaca';
UPDATE triad_cards SET icon='082390.tex.png' WHERE name='Unknown';
UPDATE triad_cards SET icon='082391.tex.png' WHERE name='Ruby Weapon';
UPDATE triad_cards SET icon='082392.tex.png' WHERE name='Therion';
UPDATE triad_cards SET icon='082393.tex.png' WHERE name='Varis yae Galvus';

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
    join triad_npc_rules as r on n.name=r.npc
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
    JOIN ze_rules AS r ON n.name=r.npc
    JOIN ze_deck AS d ON n.name=d.npc
    JOIN ze_conditions AS c ON n.name=c.npc
    JOIN ze_rewards as rew ON n.name=rew.npc
    WHERE n.name=$1
) w;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item_triad(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT json_agg(get_triad_npc(npc)) as npcs
FROM 
(
    SELECT DISTINCT npc
    FROM triad_npc_decks
    WHERE card || ' Card' = (SELECT name FROM items WHERE lid=$1)
) a;
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
 'triad', get_item_triad($1)
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