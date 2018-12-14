CREATE OR REPLACE FUNCTION ffxiv.get_item(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$
  SELECT json_build_object(
	'lid', i.lid,
    'licon', i.licon,
    'name', i.name,
    'category', get_category('Item'),
    'bonuses', get_item_bonuses(lid),
    'disciplines', get_item_disciplines(lid),
    'effects', get_item_effects(lid),
    'interests', get_item_interests(lid),
    'level', i.level,
    'g_rarity', i.g_rarity,
    'lcat2', i.lcat2,
    'lcat3', i.lcat3,
    'required_level', i.required_level,
    'is_unique', i.is_unique,
    'untradable', i.untradable,
    'advanced_melding', i.advanced_melding,
    'unsellable', i.unsellable,
    'market_prohibited', i.market_prohibited,
    'sell_price', i.sell_price,
    'note', i.note,
    'recast', i.recast,
    'damage', i.damage,
    'auto_attack', i.auto_attack,
    'delay', i.delay,
    'block_strength', i.block_strength,
    'block_rate', i.block_rate,
    'defense', i.defense,
    'magic_defense', i.magic_defense,
    'materia_slots', i.materia_slots,
    'repair_class', i.repair_class,
    'repair_level', i.repair_level,
    'repair_material', i.repair_material,
    'melding_class', i.melding_class,
    'melding_level', i.melding_level,
    'convertible', i.convertible,
    'desynth_class', i.desynth_class,
    'desynthesizable', i.desynthesizable,
    'dyeable', i.dyeable,
    'projectable', i.projectable,
    'crest_worthy', i.crest_worthy,
    'meld_ilvl', i.meld_ilvl
  )
   FROM items i
   WHERE lid = $1
$BODY$;

CREATE OR REPLACE FUNCTION ffxiv.get_item_merchants(
	itemlid text)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$
    SELECT json_agg(get_merchant(merchantlid)) as merchants
    FROM (select distinct merchantlid from bought_where AS bw
    WHERE bw.itemlid=$1)a
$BODY$;