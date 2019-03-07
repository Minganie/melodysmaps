-- new duty mode after normal, hard, extreme and savage
insert into modes (name, sort_order) values ('Ultimate', 3);

-- now duties have a banner image from Lodestone
alter table duties_each add column banner_url text;

-- lid is the real unique id of these things, make it mandatory
alter table duties_each alter column lid set not null;
-- Oh, and fix your bugs, too.
DROP TRIGGER add_duty_lid ON ffxiv.duties_each;
CREATE TRIGGER add_duty_lid
    AFTER INSERT
    ON ffxiv.duties_each
    FOR EACH ROW
    EXECUTE PROCEDURE ffxiv.add_lid();

DROP TRIGGER replace_duty_lid ON ffxiv.duties_each;
CREATE TRIGGER replace_duty_lid
    AFTER UPDATE 
    ON ffxiv.duties_each
    FOR EACH ROW
    EXECUTE PROCEDURE ffxiv.replace_lid();
		
-- adjust dependent table to make use of lid rather than (name, mode)
-- chests
alter table duty_chests add column duty_ref text references duties_each (lid);
update duty_chests as dc set duty_ref=de.lid
from duties_each as de
where dc.duty = de.name and dc.mode = de.mode;
alter table duty_chests alter column duty_ref set not null;
alter table duty_chests drop constraint duty_chests_duty_fkey;
alter table duty_chests drop column duty;
alter table duty_chests drop column mode;
alter table duty_chests rename column duty_ref to duty;
alter table duty_chests add constraint duty_chests_ukey unique (duty, x, y);
-- boss encounters
alter table duty_bosses add column duty_ref text references duties_each (lid);
update duty_bosses as db set duty_ref=de.lid
from duties_each as de
where db.duty = de.name and db.mode = de.mode;
alter table duty_bosses alter column duty_ref set not null;
-- make boss loot and boss tokens ref the gid of the encounter instead of duty name+mode+boss, otherwise can't drop constraint
-- loot
alter table duty_boss_loot add column boss_ref int references duty_bosses (gid);
update duty_boss_loot as dbl set boss_ref = db.gid
  from duty_bosses as db
  where dbl.duty = db.duty and dbl.mode = db.mode and dbl.boss = db.name;
alter table duty_boss_loot alter column boss_ref set not null;
alter table duty_boss_loot add constraint duty_boss_loot_ukey unique(boss_ref, itemlid);
alter table duty_boss_loot drop constraint duty_boss_loot_duty_fkey;
alter table duty_boss_loot drop column duty, drop column mode, drop column boss;
alter table duty_boss_loot rename column boss_ref to boss;
-- tokens
alter table duty_boss_tokens add column boss_ref int references duty_bosses (gid);
update duty_boss_tokens as dbt set boss_ref = db.gid
  from duty_bosses as db
  where dbt.duty = db.duty and dbt.mode = db.mode and dbt.boss = db.name;
alter table duty_boss_tokens alter column boss_ref set not null;
alter table duty_boss_tokens add primary key (boss_ref, token);
alter table duty_boss_tokens drop constraint duty_boss_tokens_duty_fkey;
alter table duty_boss_tokens drop column duty, drop column mode, drop column boss;
alter table duty_boss_tokens rename column boss_ref to encounter;
-- drop derelict constraints on duty_bosses
alter table duty_bosses drop constraint duty_bosses_duty_mode_name_key;
alter table duty_bosses drop column duty;
alter table duty_bosses drop column mode;
alter table duty_bosses rename column duty_ref to duty;
alter table duty_bosses drop column lid;
-- duty maps
alter table duty_maps add column duty_ref text references duties_each (lid);
update duty_maps as dm set duty_ref = de.lid
  from duties_each as de
  where dm.duty = de.name and dm.mode = de.mode;
alter table duty_maps alter column duty_ref set not null;
alter table duty_maps add constraint duty_maps_ukey unique (duty_ref, name);
alter table duty_maps drop constraint duty_maps_duty_mode_name_key;
alter table duty_maps drop constraint duty_maps_duty_fkey;
alter table duty_maps drop column duty, drop column mode;
alter table duty_maps rename column duty_ref to duty;
-- duty trash
alter table duty_trash_drops add column duty_ref text references duties_each (lid);
update duty_trash_drops as dtd set duty_ref = de.lid
  from duties_each as de
  where dtd.duty = de.name and dtd.mode = de.mode;
alter table duty_trash_drops alter column duty_ref set not null;
alter table duty_trash_drops add constraint duty_trash_drops_ukey unique(duty_ref, itemlid);
alter table duty_trash_drops drop constraint duty_trash_drops_pkey;
alter table duty_trash_drops drop constraint duty_trash_drops_duty_fkey;
alter table duty_trash_drops drop column duty, drop column mode;
	
alter table hests rename to guildhests;

-- boss -> encounter
create table mobile_types (
	name text primary key
);
grant select on mobile_types to ffxivro;
grant insert, update, delete on mobile_types to ffxivrw;
insert into mobile_types values ('Enemy');
create table mobiles (
	lid text primary key,
	name text not null,
	category text not null references mobile_types(name),
	geom geometry(Point, 4326) not null
);
grant select on mobiles to ffxivro;
grant insert, update, delete on mobiles to ffxivrw;
comment on table mobiles IS 'Counterpart to Lodestone''s NPC: enemies and npc (i.e. quest giver, etc)';

alter table duty_bosses rename to duty_encounters;
-- make duty encounters recognizable from Lodestone to Mel's Maps db
alter table duty_encounters add column boss_names_ctrl text;
alter table duty_encounters add column encounter_index integer check (encounter_index >= 0);
alter table duty_encounters add constraint duty_encounters_ukey unique (duty, encounter_index);
create table duty_encounter_bosses (
	encounter int references duty_encounters (gid),
	boss text references mobiles(lid),
	primary key (encounter, boss)
);
grant select on duty_encounter_bosses to ffxivro;
grant insert, update, delete on duty_encounter_bosses to ffxivrw;

alter table duty_boss_loot rename to duty_encounter_loot;
alter table duty_boss_tokens rename to duty_encounter_tokens;
alter table duty_encounter_loot rename column boss to encounter;

-- Duty maps... now sucking less!
CREATE TABLE duty_map_rasters(
	rid serial primary key,
	rast raster,
	filename text,
	dutylid text
);
GRANT SELECT ON duty_map_rasters TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON duty_map_rasters TO ffxivrw;

CREATE OR REPLACE FUNCTION find_which_duty()
	RETURNS trigger
	LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE difficulty text;
	BEGIN
		SELECT regexp_replace(NEW.filename, '_georeferenced.png', '') INTO STRICT NEW.filename;
		CASE
			WHEN position('Hard' in NEW.filename) IS NOT NULL AND position('Hard' in NEW.filename) <> 0 THEN difficulty = 'Hard';
			WHEN position('Extreme' in NEW.filename) IS NOT NULL AND position('Extreme' in NEW.filename) <> 0 THEN difficulty = 'Extreme';
			WHEN position('Savage' in NEW.filename) IS NOT NULL AND position('Savage' in NEW.filename) <> 0 THEN difficulty = 'Savage';
			WHEN position('Ultimate' in NEW.filename) IS NOT NULL AND position('Ultimate' in NEW.filename) <> 0 THEN difficulty = 'Ultimate';
			ELSE difficulty = 'Regular';
		END CASE;
		SELECT lid INTO STRICT NEW.dutylid FROM duties_each WHERE mode=difficulty AND NEW.filename LIKE '%' || name || '%';
		RETURN NEW;
	END;
$BODY$;
CREATE TRIGGER set_duty_lid
	BEFORE INSERT
	ON duty_map_rasters
	FOR EACH ROW
	EXECUTE PROCEDURE find_which_duty();


CREATE OR REPLACE FUNCTION add_xtent_to_o()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
    BEGIN
		INSERT INTO rtestext (rid, st_envelope) values (NEW.rid, st_envelope(NEW.rast));
		RETURN NEW;
    END;
$BODY$;
CREATE TRIGGER add_xtent
    AFTER insert
    ON rtest
    FOR EACH ROW
    EXECUTE PROCEDURE add_xtent_to_o();