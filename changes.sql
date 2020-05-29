CREATE OR REPLACE FUNCTION ffxiv.get_recipe(
	recipelid text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    STABLE 
AS $BODY$
  SELECT json_build_object(
    'id', lid,
    'discipline', r.discipline, 
    'name', r.name, 
    'label', name,
    'level', r.level, 
    'cat', r.category, 
    'nb', r.nb, 
    'durability', r.durability, 
    'difficulty', r.difficulty, 
    'max_quality', r.max_quality,
    'quality', r.quality, 
    'lid', r.lid, 
    'licon', r.licon,
    'product', get_item(product),
    'materials', get_materials(lid),
    'crystals', get_crystals(lid),
    'mastery', mastery,
    'n_stars', n_stars,
    'rec_craft', rec_craft,
    'req_craft', req_craft,
    'req_contr', req_contr,
    'req_contr_qs', req_contr_qs,
    'req_craft_qs', req_craft_qs,
    'aspect', aspect,
    'specialist', specialist,
    'has_qs', has_qs,
    'has_hq', has_hq,
    'has_coll', has_coll,
    'no_xp', no_xp,
    'equipment', equipment,
    'facility_access', facility_access,
    'always_collectible', always_collectible,
    'expert', expert
)
  FROM recipes AS r
  WHERE lid=$1;
$BODY$;