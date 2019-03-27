CREATE OR REPLACE FUNCTION get_duty_each(dutylid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
    SELECT json_build_object(
        'id', de.id,
        'lid', de.lid,
        'name', de.name,
        'mode', de.mode,
        'banner', de.banner_url,
        'label', de.name || ' (' || de.mode || ')',
        'geom', get_vertices(d.geom),
        'bounds', get_bounds(d.geom),
        'centroid', get_centroid_coords(d.geom),
        'category', get_category(d.cat),
        'nruns', de.nruns,
        'level', de.level
    )
    FROM duties_each as de
        JOIN duties as d ON de.name=d.name
    WHERE de.lid=dutylid;
$BODY$; --619923ac984

CREATE OR REPLACE FUNCTION ffxiv.get_item_duties(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'
AS $BODY$
select json_agg(get_duty_each(lid)) as de
from
(
    select distinct lid
    from
    (
            select distinct de.duty as lid
            from duty_encounter_loot as del
                join duty_encounters as de on del.encounter = de.gid
            where del.itemlid=$1
        union
            select distinct dc.duty as lid
            from duty_chest_loot as dcl
                join duty_chests as dc on dcl.chest=dc.gid
            where dcl.itemlid=$1
        union
            select distinct duty as lid
            from duty_trash_drops as dtd
            where itemlid=$1
    ) as a
) as b
$BODY$;