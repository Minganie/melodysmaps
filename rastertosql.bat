for %%g IN ("C:\Users\Myriam\Downloads\ffxiv-maps-master\Dungeons\ARR\*_georeferenced.png") DO "C:\Program Files\PostgreSQL\11\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\rasters.sql
for %%g IN ("C:\Users\Myriam\Downloads\ffxiv-maps-master\Dungeons (Hard)\ARR\*_georeferenced.png") DO "C:\Program Files\PostgreSQL\11\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\rasters.sql
for %%g IN ("C:\Users\Myriam\Downloads\ffxiv-maps-master\Raids\ARR\*_georeferenced.png") DO "C:\Program Files\PostgreSQL\11\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\rasters.sql
PAUSE
