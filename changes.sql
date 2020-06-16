CREATE TABLE fates (
    name text PRIMARY KEY,
    level int NOT NULL,
    category text NOT NULL,
    xp int NOT NULL,
    gil int NOT NULL,
    gems int NOT NULL DEFAULT 0,
    gc_seals int NOT NULL DEFAULT 0,
    delivery_item text,
    delivery_npc text,
    achievement text REFERENCES achievements(lid),
    gold_n int,
    gold_reward text REFERENCES items(lid),
    silver_n int,
    silver_reward text REFERENCES items(lid),
    bronze_n int,
    bronze_reward text REFERENCES items(lid),
    fail_n int,
    fail_reward text REFERENCES items(lid),
    geom geometry(MultiPoint, 4326)
);
GRANT SELECT ON fates TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON fates TO ffxivrw;
CREATE INDEX fates_gix ON ffxiv.fates USING gist (geom);

CREATE TABLE fate_enemies (
    fate text REFERENCES fates(name),
    enemy text,
    PRIMARY KEY (fate, enemy)
);
GRANT SELECT ON fate_enemies TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON fate_enemies TO ffxivrw;

CREATE TABLE fate_allies (
    fate text REFERENCES fates(name),
    ally text,
    PRIMARY KEY (fate, ally)
);
GRANT SELECT ON fate_allies TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON fate_allies TO ffxivrw;

CREATE TABLE fate_rewards (
    fate text REFERENCES fates(name),
    n int CHECK (n > 0),
    reward text REFERENCES items(lid),
    PRIMARY KEY (fate, reward)
);
GRANT SELECT ON fate_rewards TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON fate_rewards TO ffxivrw;

CREATE OR REPLACE FUNCTION find_item_lid(name text)
    RETURNS text
    LANGUAGE 'plpgsql'
    STABLE
AS $BODY$
DECLARE
    _lid text;
BEGIN
    IF $1 IS NULL
        THEN _lid := NULL;
    ELSIF $1 = 'Stolen Foodstuffs'
        THEN _lid := NULL;
    ELSE
        SELECT i.lid INTO STRICT _lid FROM items AS i WHERE lower(i.name) = lower($1);
    END IF;
    RETURN _lid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE EXCEPTION 'No item found with name "%" ???', $1;
        WHEN TOO_MANY_ROWS THEN
          RAISE EXCEPTION 'More than one item with name "%" ???',  $1;
END;
$BODY$;

CREATE OR REPLACE FUNCTION find_achievement_lid(name text)
    RETURNS text
    LANGUAGE 'plpgsql'
    STABLE
AS $BODY$
DECLARE
    _lid text;
BEGIN
    IF $1 IS NULL
        THEN _lid := NULL;
    ELSE
        SELECT a.lid INTO STRICT _lid FROM achievements AS a WHERE lower(a.name) = lower($1);
    END IF;
    RETURN _lid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE EXCEPTION 'No achievement found with name "%" ???', $1;
        WHEN TOO_MANY_ROWS THEN
          RAISE EXCEPTION 'More than one achievement with name "%" ???',  $1;
END;
$BODY$;

-- Deal with achievs, cause you gotta do that now...
DROP TRIGGER add_achievement_lid ON ffxiv.achievements;
DROP TRIGGER replace_achievement_lid ON ffxiv.achievements;

ALTER TABLE achievements
    ADD COLUMN category2 text,
    ADD COLUMN category3 text,
    ADD COLUMN points int CHECK (points>=0),
    ADD COLUMN licon text,
    ADD COLUMN description text,
    ADD COLUMN title_male text,
    ADD COLUMN title_female text,
    ADD COLUMN item text REFERENCES items(lid);
    
-- FIX The Magitek Is Back in the Peaks
-- FIX Nothing Like a Trappin' Life in the Tempest

DROP VIEW IF EXISTS foi;
CREATE OR REPLACE VIEW foi AS
SELECT DISTINCT *
FROM (
    select f.name, f.level, (select z.name from zones as z where st_contains(z.geom, f.geom)) as zone, 
        CASE i.lcat3
            WHEN 'Orchestrion Roll' THEN 'Orchestrion'
            WHEN 'Minion' THEN 'Minion'
            WHEN 'Triple Triad Card' THEN 'Card'
            ELSE 'Item' 
        END as reward_type, i.name as reward
    from fates as f
    join items as i on f.gold_reward=i.lid
    where gold_reward is not null
    UNION
    select f.name, f.level, (select z.name from zones as z where st_contains(z.geom, f.geom)) as zone, 
        CASE i.lcat3
            WHEN 'Orchestrion Roll' THEN 'Orchestrion'
            WHEN 'Minion' THEN 'Minion'
            WHEN 'Triple Triad Card' THEN 'Card'
            ELSE 'Item' 
        END as reward_type, i.name as reward
    from fates as f
    join items as i on f.silver_reward=i.lid
    where silver_reward is not null
    UNION
    select f.name, f.level, (select z.name from zones as z where st_contains(z.geom, f.geom)) as zone, 
        CASE i.lcat3
            WHEN 'Orchestrion Roll' THEN 'Orchestrion'
            WHEN 'Minion' THEN 'Minion'
            WHEN 'Triple Triad Card' THEN 'Card'
            ELSE 'Item' 
        END as reward_type, i.name as reward
    from fates as f
    join items as i on f.bronze_reward=i.lid
    where bronze_reward is not null
    UNION
    select f.name, f.level, (select z.name from zones as z where st_contains(z.geom, f.geom)) as zone, 
        CASE i.lcat3
            WHEN 'Orchestrion Roll' THEN 'Orchestrion'
            WHEN 'Minion' THEN 'Minion'
            WHEN 'Triple Triad Card' THEN 'Card'
            ELSE 'Item' 
        END as reward_type, i.name as reward
    from fates as f
    join items as i on f.fail_reward=i.lid
    where fail_reward is not null
    UNION
    select f.name, f.level, (select z.name from zones as z where st_contains(z.geom, f.geom)) as zone, 
        CASE i.lcat3
            WHEN 'Orchestrion Roll' THEN 'Orchestrion'
            WHEN 'Minion' THEN 'Minion'
            WHEN 'Triple Triad Card' THEN 'Card'
            ELSE 'Item' 
        END as reward_type, i.name as reward
    FROM fate_rewards as fr
    left join fates as f on fr.fate=f.name
    left join items as i on fr.reward=i.lid
)f
ORDER BY 3, 2
;
GRANT SELECT ON foi TO ffxivro;