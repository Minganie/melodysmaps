CREATE OR REPLACE FUNCTION ffxiv.get_mob_spawn(
	msgid integer)
    RETURNS json
    LANGUAGE 'plpgsql'
    STABLE 
AS $BODY$
DECLARE
    ms RECORD;
    mmumob RECORD;
    mmob RECORD;
    res json;
BEGIN
    SELECT * INTO STRICT ms FROM mob_spawns WHERE gid=msgid;
    SELECT * INTO STRICT mmumob FROM mm_unique_mobiles WHERE id=ms.mmumob;
    SELECT * INTO STRICT mmob FROM mm_mobiles WHERE name=mmumob.name;
    res := json_build_object(
        'id', ms.gid,
        'lid', ms.gid,
        'level', mmumob.level,
        'name', mmumob.name,
        'label', mmumob.name || ' (' || get_zone_abbrev((select name from zones as z where st_contains(z.geom, st_centroid(ms.geom)))) || ' lvl ' || mmumob.level || ')',
        'category', get_category('Spawn'),
        'requirement', get_requirement(mmumob.requires),
        'geom', get_vertices(ms.geom),
        'bounds', get_bounds(ms.geom),
        'centroid', get_centroid_coords(ms.geom),
        'nkilled', ms.nkilled,
        'elite', mmob.elite,
        'agressive', mmob.agressive,
        'drops', get_hunting_drops(ms.gid)
    );
    RETURN res;
END;
$BODY$;