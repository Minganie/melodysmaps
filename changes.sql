CREATE OR REPLACE FUNCTION ffxiv.get_modes(
	duty text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$

SELECT json_object_agg(
        de.mode, 
        json_build_object(
        'mode', de.mode,
        'level', de.level,
        'nruns', de.nruns,
        'bosses', get_boss_loot(de.id),
        'chests', get_chests(de.id),
        'trash_drops', get_trash_drops(de.id)
    ))
FROM duties AS d
    JOIN duties_each AS de ON d.name = de.name
WHERE d.name=$1
GROUP BY d.name

$BODY$;