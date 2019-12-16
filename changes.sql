-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

CREATE OR REPLACE FUNCTION ffxiv.get_node(
	nodegid bigint)
    RETURNS json
    LANGUAGE 'sql'
    STABLE 
AS $BODY$
SELECT json_build_object(
 'gid', n.gid,
 'category', get_category(n.category),
 'zone', (select name from zones as z where st_contains(z.geom, n.geom)),
 'level', n.level,
 'name', n.name,
 'requirement', get_requirement(n.requires),
 'geom', get_vertices(n.geom),
 'bounds', get_bounds(n.geom),
 'centroid', get_centroid_coords(n.geom),
 'gathering', get_node_gathering(gid),
 'fishes', get_fishes(gid),
 'baits', get_baits(gid),
 'fishing_table', get_fishing_table(gid),
 'best_baits', get_best_baits(gid)
)
FROM nodes AS n
WHERE gid=$1
$BODY$;