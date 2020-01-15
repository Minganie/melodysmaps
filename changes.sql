-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

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
	from (
		select 
			questlid, 
			(select row_to_json(_) from (select get_item(itemlid) as item, n, classjob as class_job, gender, optional) as _) as rewards
		from quest_rewards 
		where questlid=$1
	)a
	group by questlid
), 
other as 
(
	select questlid, 
		json_agg(reward) as other
	from (
		select questlid, (select row_to_json(_) from (select other, icon) as _) as reward
		from quest_rewards_others
		where questlid=$1
	)a
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
    q.gil, q.bt, q.bt_currency_n, get_immaterial(q.bt_currency) as bt_currency, q.bt_reputation, q.gc_seals, q.starting_class, 
    get_immaterial(q.tomestones) as tomestones, q.tomestones_n, q.ventures, q.seasonal, r.rewards, o.other, dreq.duty_requirements, areq.action_requirements) as _)
from quest as q
 left join rewards as r on q.lid=r.questlid
 left join other as o on q.lid=o.questlid
 left join dreq on q.lid=dreq.questlid
 left join areq on q.lid=areq.questlid
$BODY$;