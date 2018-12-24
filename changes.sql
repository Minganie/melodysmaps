ALTER TABLE items ADD COLUMN dresser_able boolean;
ALTER TABLE items ADD COLUMN armoire_able boolean;
DROP TABLE fishing_weathers;
CREATE TABLE ffxiv.fishing_weathers
(
    fishlid text REFERENCES items(lid),
    weather text REFERENCES weather(name),
    catches integer,
    PRIMARY KEY(fishlid, weather)
);
GRANT SELECT ON fishing_weathers TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON fishing_weathers TO ffxivrw;
ALTER TABLE items ADD COLUMN cbhid INTEGER;
ALTER TABLE nodes ADD COLUMN cbhid INTEGER;

drop view if exists cbh_best_bait;

CREATE OR REPLACE FUNCTION is_simple_catch(nodename text, fishlids text)
  RETURNS boolean AS
$$
DECLARE
    is_complex boolean;
BEGIN
    -- if complex catch, all baits are fish at that node
    SELECT bool_and(baitlid in (select fishlid from fishing_bait_tables as fbt where fbt.node=$1))
        INTO is_complex
        from fishing_bait_tables 
        where node=$1 and fishlid=$2 and catches <> 0;
    RETURN not is_complex;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;

CREATE TYPE bait_trail AS (trail text[], rate real);

drop function if exists find_simple_catch_rate(text, text);
CREATE OR REPLACE FUNCTION find_simple_catch_rate(nodename text, fishlids text)
    RETURNS bait_trail AS
$$
DECLARE
    best_rate real;
    trail text;
BEGIN
    if not is_simple_catch($1, $2) then
        raise exception 'Fish with lid ''%'' is not a primary catch.', $2;
    end if;
    with bait_table as (
        select node, baitlid, fishlid, catches
        from fishing_bait_tables
        where node=$1
    ), totals as (
        select baitlid, sum(catches) as total
        from bait_table
        group by baitlid
    ), rates as (
        select bt.baitlid, fishlid, catches::numeric/total as rate
        from bait_table as bt
            join totals as t on bt.baitlid = t.baitlid
    ), maxes as (
        select fishlid, max(rate) as rate
        from rates
        group by fishlid
    )
    select rate 
        into best_rate
    from maxes 
    where fishlid=$2;
    
    with bait_table as (
        select node, baitlid, fishlid, catches
        from fishing_bait_tables
        where node=$1
    ), totals as (
        select baitlid, sum(catches) as total
        from bait_table
        group by baitlid
    ), rates as (
        select bt.baitlid, fishlid, catches::numeric/total as rate
        from bait_table as bt
            join totals as t on bt.baitlid = t.baitlid
    ), maxes as (
        select fishlid, max(rate) as rate
        from rates
        group by fishlid
    )
    select baitlid
        into trail
    from rates as r
        join maxes as m on r.rate=m.rate
    where r.fishlid=$2
    limit 1;
    RETURN (ARRAY[trail], best_rate);
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;

DROP FUNCTION IF EXISTS find_best_rate(text, text);
CREATE OR REPLACE FUNCTION find_best_rate(nodename text, fishlids text)
  RETURNS bait_trail AS
$$
DECLARE
    rate real := 0;
    hq_rate real := 0.1;
    baits RECORD;
    tmp real;
    trails text[];
BEGIN
    IF is_simple_catch($1, $2) THEN
        rate := (find_simple_catch_rate($1, $2)).rate;
        trails := array_cat(trails, (find_simple_catch_rate($1, $2)).trail);
    ELSE 
        FOR baits IN with bait_table as (
                select node, baitlid, fishlid, catches
                from fishing_bait_tables
                where node=$1
                ), totals as (
                    select baitlid, sum(catches) as total
                    from bait_table
                    group by baitlid
                )
                select bt.baitlid, fishlid, catches::numeric/total as rate
                from bait_table as bt
                    join totals as t on bt.baitlid = t.baitlid
                WHERE fishlid = $2 AND catches <> 0 LOOP
            IF is_simple_catch($1, baits.baitlid) THEN
                tmp := (find_simple_catch_rate($1, baits.baitlid)).rate*hq_rate*baits.rate;
                IF tmp > rate THEN
                    rate := tmp;
                    trails := array_prepend(baits.baitlid, (find_simple_catch_rate($1, baits.baitlid)).trail);
                END IF;
            ELSE 
                tmp := (find_best_rate($1, baits.baitlid)).rate*hq_rate*baits.rate;
                IF tmp > rate THEN
                    rate := tmp;
                    trails := array_prepend(baits.baitlid, (find_best_rate($1, baits.baitlid)).trail);
                END IF;
            END IF;
        END LOOP;
    END IF;
    RETURN (trails, rate);
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;