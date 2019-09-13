-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

CREATE OR REPLACE FUNCTION ffxiv.adjust_geom_to_less_marker()
    RETURNS trigger
    LANGUAGE 'plpgsql'
	SECURITY DEFINER 
AS $BODY$
    DECLARE
        old_hull_id integer;
		old_hull geometry(Polygon, 4326);
        old_cluster_id integer;
		old_cluster geometry(MultiPolygon, 4326);
		n_hulls integer;
        n_markers integer;
		
        n_mmumob_markers integer;
        n_mm_mmumobs integer;
        new_cluster geometry(MultiPolygon, 4326);
        new_hull geometry(Polygon, 4326);
    BEGIN
		-- pre-delete cluster and hull
        select gid, geom INTO STRICT old_hull_id, old_hull
			from mob_spawns as ms 
			WHERE st_contains(geom, OLD.geom) AND ms.mmumob=OLD.mmumob;
			
        SELECT gid, geom INTO STRICT old_cluster_id, old_cluster
			FROM mobs_clustered as mc
			WHERE st_contains(geom, OLD.geom) AND mc.mmumob=OLD.mmumob;
		
		-- post delete hulls for this mmumob intersecting pre-delete hull
		SELECT count(*) INTO STRICT n_hulls
			FROM
			(SELECT st_multi(ST_UnaryUnion(grp)) as geom
            FROM
            (
                SELECT unnest(ST_ClusterWithin(st_buffer(geom, 0.07), 0.5)) AS grp 
                FROM xivdb_mobs
                WHERE mmumob=OLD.mmumob AND gid <> OLD.gid
                GROUP BY mmumob
            ) sq)a
		WHERE st_intersects(a.geom, old_hull);
		
		-- Darn it, does it need to be split?
		CASE
			-- No: all clear
			WHEN n_hulls = 1 THEN
				select count(gid) into strict n_markers
					from xivdb_mobs as m
					where m.mmumob=OLD.mmumob AND m.gid<>OLD.gid AND st_contains(old_hull, m.geom);        
				-- was it the only marker for this mmumob AT THIS LOCATION? if so, delete from mc and ms
				IF n_markers < 1 THEN
					DELETE FROM mobs_clustered WHERE gid=old_cluster_id;
					DELETE FROM mob_spawns WHERE gid=old_hull_id;
				ELSE
				    -- adjust mc and ms
					SELECT geom INTO STRICT new_cluster
					FROM
					(SELECT st_multi(ST_UnaryUnion(grp)) as geom
					FROM
					(
						SELECT unnest(ST_ClusterWithin(st_buffer(geom, 0.07), 0.5)) AS grp 
						FROM xivdb_mobs
						WHERE mmumob=OLD.mmumob AND gid <> OLD.gid
						GROUP BY mmumob
					) sq)a
					ORDER BY st_distance(a.geom, OLD.geom) ASC
					LIMIT 1;
					
					UPDATE mobs_clustered SET geom=new_cluster WHERE gid=old_cluster_id;
					
					SELECT st_convexhull(geom) INTO STRICT new_hull
					FROM mobs_clustered
					WHERE gid=old_cluster_id;
					
					UPDATE mob_spawns SET geom=new_hull WHERE gid=old_hull_id;
				END IF;
					
			-- Yes: I'll figure it out later, for now put a helpful error message
			WHEN n_hulls > 1 THEN
				RAISE EXCEPTION 'Edge case: removing xivdb_mobs #% would split its hull into several parts', OLD.gid;
			ELSE
				RAISE EXCEPTION 'Can''t imagine how you got here, didn''t find any hulls for xivdb_mobs #%?', OLD.gid;
		END CASE;
        RETURN OLD;
    END;
$BODY$;

CREATE OR REPLACE FUNCTION adjust_to_new_marker()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
    DECLARE
        new_cluster geometry(MultiPolygon, 4326);
        new_hull geometry(Polygon, 4326);
		n_clusters integer;
		n_hulls integer;
		old_clusters integer[];
		old_hulls integer[];
    BEGIN
		-- post insert cluster and hull
		SELECT geom INTO STRICT new_cluster
			FROM
            (SELECT st_multi(ST_UnaryUnion(grp)) as geom
            FROM
            (
                SELECT unnest(ST_ClusterWithin(st_buffer(geom, 0.07), 0.5)) AS grp 
                FROM xivdb_mobs
                WHERE mmumob=NEW.mmumob
                GROUP BY mmumob
            ) sq)a
			ORDER BY st_distance(a.geom, NEW.geom) ASC
			LIMIT 1;
		SELECT st_convexhull(new_cluster) INTO STRICT new_hull;
		
		-- how many current clusters and hulls intersect with new cluster and hull?
		SELECT count(gid) INTO STRICT n_clusters
			FROM mobs_clustered AS mc
			WHERE mmumob=NEW.mmumob AND st_intersects(mc.geom, new_cluster);
		SELECT count(gid) INTO STRICT n_hulls
			FROM mob_spawns AS ms
			WHERE ms.mmumob=NEW.mmumob AND ST_intersects(ms.geom, new_cluster);
		
		-- darn it, do you need to merge things???
		CASE
			WHEN n_clusters=0 AND n_hulls=0 THEN
				-- new info
                INSERT INTO mobs_clustered (mmumob, geom) VALUES (NEW.mmumob, new_cluster);
                INSERT INTO mob_spawns (mmumob, geom) VALUES (NEW.mmumob, new_hull);
			WHEN n_clusters=1 AND n_hulls=1 THEN
				-- existing cluster and hull in need of updating
				UPDATE mobs_clustered SET geom=new_cluster WHERE mmumob=NEW.mmumob AND st_intersects(geom, new_cluster);
				UPDATE mob_spawns SET geom=new_hull WHERE mmumob=NEW.mmumob AND st_intersects(geom, new_hull);
			WHEN n_clusters>1 AND n_clusters>1 THEN
				-- clusters: keep the first one, delete others;
				old_clusters = array(SELECT gid
				FROM mobs_clustered WHERE mmumob=NEW.mmumob AND st_intersects(geom, new_cluster) order by gid);
				UPDATE mobs_clustered SET geom=new_cluster WHERE gid=old_clusters[1];
				DELETE FROM mobs_clustered WHERE gid IN (select unnest(old_clusters[2:]));
			
				-- hulls: keep the first one; add nkilled; delete others
				old_hulls = array(SELECT gid FROM mob_spawns WHERE mmumob=NEW.mmumob AND st_intersects(geom, new_cluster) order by gid);
				UPDATE mob_spawns SET 
					geom=new_hull,
					nkilled=nkilled+(SELECT sum(nkilled) FROM mob_spawns as ms WHERE gid in (select unnest(old_hulls[2:])))
				WHERE gid=old_hulls[1];
				DELETE FROM mob_spawns WHERE gid IN (select unnest(old_hulls[2:]));
			ELSE
				RAISE EXCEPTION 'Even edgier cases: different answers to "do I need to merge" from clusters and hulls';
		END CASE;
        RETURN NEW;
    END;
$BODY$;



ALTER FUNCTION find_best_rate STABLE;
ALTER FUNCTION find_duty_lid STABLE;
ALTER FUNCTION find_simple_catch_rate STABLE;
ALTER FUNCTION get_actual_zone STABLE;
ALTER FUNCTION get_aetheryte STABLE;
ALTER FUNCTION get_aetherytes STABLE;
ALTER FUNCTION get_area STABLE;
ALTER FUNCTION get_areas STABLE;
ALTER FUNCTION get_baits STABLE;
ALTER FUNCTION get_best_baits STABLE;
ALTER FUNCTION get_bounds IMMUTABLE;
ALTER FUNCTION get_bounds_multi_point IMMUTABLE;
ALTER FUNCTION get_bounds_multi_poly IMMUTABLE;
ALTER FUNCTION get_bounds_point IMMUTABLE;
ALTER FUNCTION get_categories STABLE;
ALTER FUNCTION get_category STABLE;
ALTER FUNCTION get_centroid_coords IMMUTABLE;
ALTER FUNCTION get_chest_loot STABLE;
ALTER FUNCTION get_chests STABLE;
ALTER FUNCTION get_chocobo STABLE;
ALTER FUNCTION get_chocobos STABLE;
ALTER FUNCTION get_crystals STABLE;
ALTER FUNCTION get_current STABLE;
ALTER FUNCTION get_currents STABLE;
ALTER FUNCTION get_default_map STABLE;
ALTER FUNCTION get_discipline STABLE;
ALTER FUNCTION get_disciplines STABLE;
ALTER FUNCTION get_duties STABLE;
ALTER FUNCTION get_duty STABLE;
ALTER FUNCTION get_duty_each STABLE;
ALTER FUNCTION get_encounter_loot STABLE;
ALTER FUNCTION get_fish_conditions STABLE;
ALTER FUNCTION get_fishes STABLE;
ALTER FUNCTION get_fishing_table STABLE;
ALTER FUNCTION get_game_coords IMMUTABLE;
ALTER FUNCTION get_game_coords_point IMMUTABLE;
ALTER FUNCTION get_hunting_drops STABLE;
ALTER FUNCTION get_immaterial(text, text) STABLE;
ALTER FUNCTION get_immaterial(text) STABLE;
ALTER FUNCTION get_item STABLE;
ALTER FUNCTION get_item_bonuses STABLE;
ALTER FUNCTION get_item_crafters STABLE;
ALTER FUNCTION get_item_duties STABLE;
ALTER FUNCTION get_item_effects STABLE;
ALTER FUNCTION get_item_interests STABLE;
ALTER FUNCTION get_item_leves STABLE;
ALTER FUNCTION get_item_maps STABLE;
ALTER FUNCTION get_item_merchants STABLE;
ALTER FUNCTION get_item_ms STABLE;
ALTER FUNCTION get_item_nodes STABLE;
ALTER FUNCTION get_item_sources STABLE;
ALTER FUNCTION get_item_uses STABLE;
ALTER FUNCTION get_leve STABLE;
ALTER FUNCTION get_levemete STABLE;
ALTER FUNCTION get_leves STABLE;
ALTER FUNCTION get_materials STABLE;
ALTER FUNCTION get_merchant STABLE;
ALTER FUNCTION get_merchant_good STABLE;
ALTER FUNCTION get_merchant_price STABLE;
ALTER FUNCTION get_merchant_sale STABLE;
ALTER FUNCTION get_merchant_tabs STABLE;
ALTER FUNCTION get_merchants STABLE;
ALTER FUNCTION get_mob STABLE;
ALTER FUNCTION get_mob_spawn STABLE;
ALTER FUNCTION get_mobile STABLE;
ALTER FUNCTION get_mobile_zone_names STABLE;
ALTER FUNCTION get_mobile_zones STABLE;
ALTER FUNCTION get_modes STABLE;
ALTER FUNCTION get_moogle STABLE;
ALTER FUNCTION get_moogles STABLE;
ALTER FUNCTION get_multipoint STABLE;
ALTER FUNCTION get_node STABLE;
ALTER FUNCTION get_node_gathering STABLE;
ALTER FUNCTION get_npc STABLE;
ALTER FUNCTION get_npc_from_id STABLE;
ALTER FUNCTION get_quest STABLE;
ALTER FUNCTION get_recipe STABLE;
ALTER FUNCTION get_region STABLE;
ALTER FUNCTION get_regions STABLE;
ALTER FUNCTION get_requirement STABLE;
ALTER FUNCTION get_search STABLE;
ALTER FUNCTION get_trash_drops STABLE;
ALTER FUNCTION get_vertices IMMUTABLE;
ALTER FUNCTION get_vertices_multi_point IMMUTABLE;
ALTER FUNCTION get_vertices_multi_poly IMMUTABLE;
ALTER FUNCTION get_vertices_point IMMUTABLE;
ALTER FUNCTION get_vista STABLE;
ALTER FUNCTION get_vista_weathers STABLE;
ALTER FUNCTION get_vistas STABLE;
ALTER FUNCTION get_xiv_duty_geom STABLE;
ALTER FUNCTION get_xiv_zone_geom STABLE;
ALTER FUNCTION get_zone STABLE;
ALTER FUNCTION get_zone_abbrev STABLE;
ALTER FUNCTION get_zones STABLE;
ALTER FUNCTION is_coi STABLE;
ALTER FUNCTION is_wrong STABLE;

CREATE TYPE hunt_rank AS ENUM ('B Rank', 'A Rank', 'S Rank', 'SS Rank');
ALTER TABLE mm_mobiles ADD COLUMN rank hunt_rank;

-- when unique doesn't mean what you think it does... but first let's fix "is_fate"
UPDATE mm_unique_mobiles as mu
SET is_fate = true
FROM requirements as r
	WHERE mu.requires=r.name;
UPDATE mm_unique_mobiles SET is_fate=false WHERE is_fate IS NULL;
ALTER TABLE mm_unique_mobiles ALTER COLUMN is_fate SET NOT NULL;
ALTER TABLE mm_unique_mobiles ALTER COLUMN level SET NOT NULL;
-- let's make unique really unique...
-- current unique on : name, zone, level, hp, mp, fate_id, is_fate, requires
-- now name, zone, level and is_fate are not null, so always present
-- hp, mp, fate_id and requires are nullable, so coalesce them...
-- BUT FIRST, remove duplicates (sigh)
-- and even before that, let's make data state consistent between mmo, mmu, markers, clusters and hulls

CREATE VIEW bad_mmo AS
SELECT mmo.name, mmo.rank, mmu.id as mmu, mo.gid as marker, mc.gid as cluster, ms.gid as hull
FROM mm_mobiles as mmo
	left join mm_unique_mobiles as mmu ON mmo.name = mmu.name
	left join xivdb_mobs AS mo ON mmu.id=mo.mmumob
	left join mobs_clustered AS mc ON mo.mmumob = mc.mmumob
	left join mob_spawns AS ms ON ms.mmumob = mc.mmumob
where mmu.id IS null OR mo.gid IS NULL OR mc.gid IS NULL OR ms.gid IS NULL;

CREATE VIEW bad_mmu AS
SELECT mmu.name, mmu.id as mmu, mo.gid as marker, mc.gid as cluster, ms.gid as hull
FROM mm_unique_mobiles as mmu
	left join xivdb_mobs AS mo ON mmu.id=mo.mmumob
	left join mobs_clustered AS mc ON mo.mmumob = mc.mmumob
	left join mob_spawns AS ms ON ms.mmumob = mc.mmumob
where mo.gid IS NULL OR mc.gid IS NULL OR ms.gid IS NULL;

CREATE VIEW bad_markers AS
SELECT mmu.name, mmu.id as mmu, mo.gid as marker, mc.gid as cluster, ms.gid as hull
FROM xivdb_mobs AS mo
	join mm_unique_mobiles as mmu ON mo.mmumob=mmu.id
	left join mobs_clustered AS mc ON mo.mmumob = mc.mmumob AND st_contains(mc.geom, mo.geom)
	left join mob_spawns AS ms ON ms.mmumob = mc.mmumob AND st_contains(ms.geom, mo.geom)
where mc.gid IS NULL OR ms.gid IS NULL;

CREATE OR REPLACE VIEW bad_clusters AS
SELECT mc.gid as cluster, ms.gid as hull, mo.gid as marker
FROM mobs_clustered AS mc
	LEFT JOIN mob_spawns AS ms ON mc.mmumob = ms.mmumob AND st_contains(ms.geom, mc.geom)
	LEFT JOIN xivdb_mobs AS mo ON mc.mmumob = mo.mmumob AND st_contains(mc.geom, mo.geom)
WHERE ms.gid IS NULL OR mo.gid IS NULL;

CREATE VIEW bad_hulls AS
SELECT ms.gid as hull, mc.gid as cluster, mo.gid as marker
FROM mob_spawns AS ms
	LEFT JOIN mobs_clustered AS mc ON ms.mmumob = mc.mmumob AND st_contains(ms.geom, mc.geom)
	LEFT JOIN xivdb_mobs AS mo ON ms.mmumob = mo.mmumob AND st_contains(ms.geom, mo.geom)
WHERE mc.gid IS NULL OR mo.gid IS NULL;
CREATE VIEW other_bad_hulls AS
SELECT a.gid AS agid, b.gid AS bgid
FROM mob_spawns as a, mob_spawns as b
WHERE a.gid<>b.gid AND a.mmumob=b.mmumob AND st_intersects(a.geom, b.geom);

DELETE FROM mobs_clustered WHERE gid=170;
-- move offending marker south
-- fill gap with new markers
-- recreate marker
INSERT INTO xivdb_mobs (x, y, mmumob, geom) values (19.3, 10.2, 1528, st_geomfromtext('POINT(77.5777446418032 30.5937568544928)', 4326));


BEGIN;
ALTER TABLE mm_unique_mobiles DROP CONSTRAINT mm_unique_mobiles_ukey;
CREATE UNIQUE INDEX mm_unique_mobiles_ukey ON mm_unique_mobiles 
(
	name, zone, is_fate, level,
	(COALESCE(hp, -1)),
	(COALESCE(mp, -1)),
	(COALESCE(fate_id, '-1')),
	(COALESCE(requires, 'a'))
);
END;
GRANT USAGE ON mm_unique_mobiles_id_seq TO ffxivro;

ALTER TABLE merchants DROP CONSTRAINT merchants_requires_fkey,
ADD CONSTRAINT merchants_requires_fkey FOREIGN KEY (requires) REFERENCES requirements(name) ON UPDATE CASCADE;
-- VATH
UPDATE requirements SET name='Friendly with the Vath' WHERE name='Neutral with the Vath';
INSERT INTO requirements (name, icon) VALUES ('Trusted with the Vath', 'icons/traits/vath.png');
INSERT INTO requirements (name, icon) VALUES ('Respected with the Vath', 'icons/traits/vath.png');
INSERT INTO requirements (name, icon) VALUES ('Honored with the Vath', 'icons/traits/vath.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Vath', 'icons/traits/vath.png');
INSERT INTO requirements (name, icon) VALUES ('Bloodsworn with the Vath', 'icons/traits/vath.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Vath', 'icons/traits/vath.png');

-- VANU VANU
INSERT INTO requirements (name, icon) VALUES ('Recognized with the Vanu Vanu', 'icons/traits/vanu.png');
INSERT INTO requirements (name, icon) VALUES ('Friendly with the Vanu Vanu', 'icons/traits/vanu.png');
INSERT INTO requirements (name, icon) VALUES ('Trusted with the Vanu Vanu', 'icons/traits/vanu.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Vanu Vanu', 'icons/traits/vanu.png');
INSERT INTO requirements (name, icon) VALUES ('Bloodsworn with the Vanu Vanu', 'icons/traits/vanu.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Vanu Vanu', 'icons/traits/vanu.png');

-- MOOGLES
INSERT INTO requirements (name, icon) VALUES ('Recognized with the Moogles', 'icons/traits/moogles.png');
INSERT INTO requirements (name, icon) VALUES ('Honored with the Moogles', 'icons/traits/moogles.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Moogles', 'icons/traits/moogles.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Moogles', 'icons/traits/moogles.png');

-- ANANTA
UPDATE requirements SET name='Friendly with the Ananta' WHERE name='Neutral with the Ananta';
INSERT INTO requirements (name, icon) VALUES ('Trusted with the Ananta', 'icons/traits/ananta.png');
INSERT INTO requirements (name, icon) VALUES ('Respected with the Ananta', 'icons/traits/ananta.png');
INSERT INTO requirements (name, icon) VALUES ('Honored with the Ananta', 'icons/traits/ananta.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Ananta', 'icons/traits/ananta.png');
INSERT INTO requirements (name, icon) VALUES ('Bloodsworn with the Ananta', 'icons/traits/ananta.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Ananta', 'icons/traits/ananta.png');

-- KOJIN
UPDATE requirements SET name='Friendly with the Kojin' WHERE name='Neutral with the Kojin';
INSERT INTO requirements (name, icon) VALUES ('Trusted with the Kojin', 'icons/traits/kojin.png');
INSERT INTO requirements (name, icon) VALUES ('Respected with the Kojin', 'icons/traits/kojin.png');
INSERT INTO requirements (name, icon) VALUES ('Honored with the Kojin', 'icons/traits/kojin.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Kojin', 'icons/traits/kojin.png');
INSERT INTO requirements (name, icon) VALUES ('Bloodsworn with the Kojin', 'icons/traits/kojin.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Kojin', 'icons/traits/kojin.png');

-- NAMAZU
UPDATE requirements SET name='Friendly with the Namazu' WHERE name='Neutral with the Namazu';
INSERT INTO requirements (name, icon) VALUES ('Trusted with the Namazu', 'icons/traits/namazu.png');
INSERT INTO requirements (name, icon) VALUES ('Respected with the Namazu', 'icons/traits/namazu.png');
INSERT INTO requirements (name, icon) VALUES ('Honored with the Namazu', 'icons/traits/namazu.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Namazu', 'icons/traits/namazu.png');
INSERT INTO requirements (name, icon) VALUES ('Bloodsworn with the Namazu', 'icons/traits/namazu.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Namazu', 'icons/traits/namazu.png');

ALTER TABLE merchants DROP CONSTRAINT merchants_requires_fkey,
ADD CONSTRAINT merchants_requires_fkey FOREIGN KEY (requires) REFERENCES requirements(name);