-- pg_dump -F c -f ffxiv20190708.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190712.backup

CREATE TABLE quest_action_requirements (
    questlid text references quests(lid),
    action text references requirements(name),
    primary key (questlid, action)
);
GRANT SELECT ON quest_action_requirements TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON quest_action_requirements TO ffxivrw;
CREATE OR REPLACE FUNCTION ffxiv.adjust_geom_to_less_marker()
    RETURNS trigger
    LANGUAGE 'plpgsql'
	SECURITY DEFINER 
AS $BODY$
    DECLARE
        old_hull_id integer;
        old_cluster_id integer;
        n_markers integer;
        n_mmumob_markers integer;
        n_mm_mmumobs integer;
        new_cluster geometry(MultiPolygon, 4326);
        new_hull geometry(Polygon, 4326);
    BEGIN
        select gid INTO STRICT old_hull_id
			from mob_spawns as ms 
			WHERE st_contains(geom, OLD.geom) AND ms.mmumob=OLD.mmumob;
        SELECT gid INTO STRICT old_cluster_id
			FROM mobs_clustered as mc
			WHERE st_contains(geom, OLD.geom) AND mc.mmumob=OLD.mmumob;
        select count(gid) into strict n_markers
			from xivdb_mobs as m
			where m.mmumob=OLD.mmumob AND m.gid<>OLD.gid AND st_contains((select ms.geom from mob_spawns as ms where gid=old_hull_id), m.geom);
        -- was it the only marker for this mmumob AT THIS LOCATION? if so, delete from mc and ms
        IF n_markers < 1 THEN
            DELETE FROM mobs_clustered WHERE mmumob=OLD.mmumob;
            DELETE FROM mob_spawns WHERE mmumob=OLD.mmumob;
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
            WHERE mmumob=OLD.mmumob AND gid=old_cluster_id;
            UPDATE mob_spawns SET geom=new_hull WHERE gid=old_hull_id;
        END IF;
        RETURN OLD;
	EXCEPTION
		WHEN TOO_MANY_ROWS THEN
			RAISE NOTICE 'adjust_geom_to_less_marker failed for xivdb_mobs #%; old hull is % and old marker is %', OLD.gid, old_hull_id, old_cluster_id;
			RAISE EXCEPTION 'adjust_geom_to_less_marker failed for xivdb_mobs #%', OLD.gid USING ERRCODE='P0003';
    END;
$BODY$;

-- repeat several times...
DELETE FROM xivdb_mobs
	WHERE gid IN
		(SELECT MAX(gid)
		FROM xivdb_mobs 
		GROUP BY ST_AsBinary(geom), mmumob, x, y
		HAVING COUNT(gid) > 1);

ALTER TABLE xivdb_mobs ADD CONSTRAINT xivdb_mobs_geom_key UNIQUE (mmumob, geom);

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

ALTER TABLE duty_maps DROP CONSTRAINT duty_maps_raster_fkey;
DROP TRIGGER add_duty_map_from_raster ON duty_map_rasters;
DROP TRIGGER set_duty_lid ON duty_map_rasters;
DROP TABLE duty_map_rasters;

ALTER TABLE duty_maps RENAME TO duty_maps_t;
CREATE VIEW duty_maps AS
SELECT gid, duty, name, code, a, b, 
st_xmin(geom::box3d) as c,
st_xmax(geom::box3d) as d,
e, f, 
st_ymax(geom::box3d) as g,
st_ymin(geom::box3d) as h,
(st_xmax(geom::box3d) - st_xmin(geom::box3d)) / (b - a)::double precision AS mxge,
st_xmin(geom::box3d) - (st_xmax(geom::box3d) - st_xmin(geom::box3d)) / (b - a)::double precision * a::double precision AS nxge,
(b - a)::double precision / (st_xmax(geom::box3d) - st_xmin(geom::box3d)) AS mxeg,
a::double precision - (b - a)::double precision / (st_xmax(geom::box3d) - st_xmin(geom::box3d)) * st_xmin(geom::box3d) AS nxeg,
(st_ymin(geom::box3d) - st_ymax(geom::box3d)) / (f - e)::double precision AS myge,
st_ymax(geom::box3d) - (st_ymin(geom::box3d) - st_ymax(geom::box3d)) / (f - e)::double precision * e::double precision AS nyge,
(e - f)::double precision / (st_ymax(geom::box3d) - st_ymin(geom::box3d)) AS myeg,
f::double precision - (e - f)::double precision / (st_ymax(geom::box3d) - st_ymin(geom::box3d)) * st_ymin(geom::box3d) AS nyeg,
geom
FROM duty_maps_t;
DROP TRIGGER compute_coefficients ON duty_maps_t;
ALTER TABLE duty_maps_t DROP COLUMN c, DROP COLUMN d, DROP COLUMN g, DROP COLUMN h;


CREATE TRIGGER add_duty_map_from_raster
AFTER UPDATE ON duty_map_rasters
FOR EACH ROW EXECUTE FUNCTION add_duty_map();

CREATE TRIGGER set_duty_lid
BEFORE UPDATE ON duty_map_rasters
FOR EACH ROW EXECUTE FUNCTION find_which_duty();