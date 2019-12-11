-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

CREATE OR REPLACE FUNCTION ffxiv.get_search(
	term text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    STABLE 
AS $BODY$
select json_agg(json_build_object(
	'id', id,
	'lid', lid,
	'category', get_category(category),
	'name', name,
	'real_name', real_name,
	'mode', a.mode,
	'sort_order', sort_order
))
from (
	select id, lid, category, category_name, name, real_name, mode, sort_order, 
		CASE 
			WHEN lower(name) = lower(term) THEN 1
			WHEN lower(name) LIKE lower(term || '%') THEN 2
			ELSE 3
		END AS precendence
	from vsearchables 
	where lower(name) like lower('%' || term || '%')
	order by precendence, category, sort_order, name
	LIMIT 25
) a
$BODY$;