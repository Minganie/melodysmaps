-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

CREATE TABLE quest_action_requirements (
    questlid text references quests(lid),
    action text references requirements(name),
    primary key (questlid, action)
);
GRANT SELECT ON quest_action_requirements TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON quest_action_requirements TO ffxivrw;

CREATE TYPE required_duty_type AS ENUM ('Stage', 'Duty');
DROP VIEW IF EXISTS duty_requirements;
CREATE VIEW duty_requirements AS 
select 'Duty'::required_duty_type as t, name, mode, lid, level from duties_each
union
select 'Stage'::required_duty_type as t, name, 'Regular' as mode, name as lid, 50 from carnivale_stages
order by 2,3;

ALTER TABLE quest_requirements RENAME TO quest_duty_requirements;
ALTER TABLE quest_duty_requirements 
	DROP CONSTRAINT quest_requirements_dutylid_fkey;

CREATE FUNCTION check_req_duty()
	RETURNS trigger
    LANGUAGE 'plpgsql'
	VOLATILE
AS $BODY$
	DECLARE
		_lid text;
	BEGIN
		SELECT lid INTO STRICT _lid FROM duty_requirements WHERE lid=NEW.dutylid;
		RETURN NEW;
	END;
$BODY$;

CREATE TRIGGER check_req_duty
    AFTER INSERT OR UPDATE 
    ON ffxiv.quest_duty_requirements
    FOR EACH ROW
    EXECUTE PROCEDURE ffxiv.check_req_duty();

CREATE OR REPLACE FUNCTION find_duty_requirement(
	name text,
	diff text)
    RETURNS text
    LANGUAGE 'plpgsql'
    STABLE 
AS $BODY$
DECLARE
 _diff text;
 _lid text;
BEGIN
  IF $2 IS NULL THEN
    _diff := 'Regular';
  ELSE
    _diff := $2;
  END IF;
  SELECT lid INTO STRICT _lid FROM duty_requirements WHERE duty_requirements.name=$1 AND duty_requirements.mode=_diff;
 RETURN _lid;
END;
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_quest(
	questlid text)
    RETURNS json
    LANGUAGE 'sql'
	STABLE
AS $BODY$

with quest as (
 select * from quests where lid=$1
), 
rewards as 
(
select questlid, 
    json_agg(rewards) as rewards 
from (select questlid, 
        (select row_to_json(_) from (select get_item(itemlid) as item, n, classjob as class_job, gender, optional) as _) as rewards
    from quest_rewards 
    where questlid=$1)a
group by questlid
), 
other as 
(
select questlid, 
    json_agg(reward) as other
from (select questlid, (select row_to_json(_) from (select other, icon) as _) as reward
    from quest_rewards_others
    where questlid=$1)a
group by questlid
), 
dreq as 
(
select questlid, json_agg(requirements) as duty_requirements 
from 
    (
 select $1, (select row_to_json(_) from (select t::text as type, lid, name, mode, level) as _) as requirements
 from duty_requirements as de
 where de.lid in (select dutylid
	from quest_duty_requirements 
	where questlid=$1)
    )a
group by questlid
),
areq as
(
select questlid, json_agg(requirements) as action_requirements
from (
	select questlid, get_requirement(action) as requirements
	from quest_action_requirements
	where questlid=$1
)a
group by questlid
)

select (select row_to_json(_) from (select q.lid, q.name, q.category as quest_category, q.banner, q.area, q.zone, q.quest_type, 
    get_mobile(q.quest_giver) as quest_giver, q.level, q.level_requirement, q.class_requirement, q.gc, q.gc_rank, q.xp, 
    q.gil, q.bt, q.bt_currency_n, q.bt_currency, q.bt_reputation, q.gc_seals, q.starting_class, 
    q.tomestones, q.tomestones_n, q.ventures, q.seasonal, r.rewards, o.other, dreq.duty_requirements, areq.action_requirements) as _)
from quest as q
 left join rewards as r on q.lid=r.questlid
 left join other as o on q.lid=o.questlid
 left join dreq on q.lid=dreq.questlid
 left join areq on q.lid=areq.questlid
$BODY$;