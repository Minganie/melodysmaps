-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

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