-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

CREATE OR REPLACE FUNCTION ffxiv.get_leves(
	levemete text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    STABLE 
AS $BODY$

select json_object_agg(type, leves) 
from
	(
		select type, json_agg(leve) as leves 
		from
			(
				select type, get_leve(name) as leve
				from leves
				where levemete=$1
				order by job, lvl, name
			)a
		group by type
	)b

$BODY$;