CREATE OR REPLACE FUNCTION ffxiv.get_game_coords_point(
	geomin geometry)
    RETURNS json
    LANGUAGE 'sql'
    IMMUTABLE 
AS $BODY$
select json_build_object(
'zone', z.name,
'x', round((v.mxeg*st_x(geomin)+v.nxeg)::numeric, 1),
'y', round((v.myeg*st_y(geomin)+v.nyeg)::numeric, 1)
)
FROM vzones AS v
	JOIN zones as z ON v.name=z.name
WHERE st_contains(z.geom, geomin);
$BODY$;