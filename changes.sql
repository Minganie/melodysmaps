-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

GRANT SELECT ON vhunting_logs TO ffxivro;

select json_object_agg(name, ranks) from (
	select name, json_object_agg(rank, kills) as ranks 
	from (
		select name, rank, json_agg(mob) as kills
		from (
			SELECT 
				name, 
				rank, 
				json_build_object(
					'name', mob,
					'geom', get_vertices(geom),
					'bounds', get_bounds(geom),
					'centroid', get_centroid_coords(geom)
				) as mob
			FROM (
				select hl.name, hl.rank, hl.level, hl.mob, a.geom
				from vhunting_logs as hl
				join (
					select mmumob.name, st_union(geom) as geom
					from mob_spawns as ms
					join mm_unique_mobiles as mmumob ON ms.mmumob=mmumob.id
					group by mmumob.name
				)a on a.name=hl.mob
				order by hl.name, hl.level
			) As lg
			order by name, rank
		)r
		group by name, rank
		order by name, rank
	)s
	group by name
	order by name
)u