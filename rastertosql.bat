for %%g IN ("D:\megha\Documents\RPG\ffxiv-maps\Dungeons\ARR\*.png") DO D:\Programmes\Postgres\bin\raster2pgsql.exe -a -s 3857 -F -n filename "%%g" ffxiv.duty_map_rasters >> C:\junk\rasters.sql
PAUSE
