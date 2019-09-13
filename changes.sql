-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

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