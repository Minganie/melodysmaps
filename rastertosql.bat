for %%g IN ("D:\megha\Documents\RPG\ffxiv-maps\Dungeons\ARR\*_georeferenced.png") DO "D:\Programmes\Postgres\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\arr_rasters.sql
for %%g IN ("D:\megha\Documents\RPG\ffxiv-maps\Dungeons (Hard)\ARR\*_georeferenced.png") DO "D:\Programmes\Postgres\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\arr_rasters.sql
for %%g IN ("D:\megha\Documents\RPG\ffxiv-maps\Raids\ARR\*_georeferenced.png") DO "D:\Programmes\Postgres\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\arr_rasters.sql

for %%g IN ("D:\megha\Documents\RPG\ffxiv-maps\Dungeons\HW\*_georeferenced.png") DO "D:\Programmes\Postgres\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\hw_rasters.sql
for %%g IN ("D:\megha\Documents\RPG\ffxiv-maps\Dungeons (Hard)\HW\*_georeferenced.png") DO "D:\Programmes\Postgres\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\hw_rasters.sql
for %%g IN ("D:\megha\Documents\RPG\ffxiv-maps\Raids\HW\*_georeferenced.png") DO "D:\Programmes\Postgres\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\hw_rasters.sql

for %%g IN ("D:\megha\Documents\RPG\ffxiv-maps\Dungeons\SB\*_georeferenced.png") DO "D:\Programmes\Postgres\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\sb_rasters.sql
for %%g IN ("D:\megha\Documents\RPG\ffxiv-maps\Dungeons (Hard)\SB\*_georeferenced.png") DO "D:\Programmes\Postgres\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\sb_rasters.sql
for %%g IN ("D:\megha\Documents\RPG\ffxiv-maps\Raids\SB\*_georeferenced.png") DO "D:\Programmes\Postgres\bin\raster2pgsql.exe" -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\sb_rasters.sql
PAUSE
