Selectable = {
    getItemTooltippedLi: function(tooltippable) {
        return Selectable.Item.Tooltip.get(tooltippable).getTooltippedLi();
    },
    getItemTooltippedLiWithInterest: function(tooltippable) {
        return Selectable.Item.Tooltip.get(tooltippable).getTooltippedLiWithInterest();
    },
    getItemGatheringLine: function(gatherable) {
        return Selectable.Item.Tooltip.get(gatherable).getTooltippedDiv();
    },
    getItemTooltippedImage: function(tooltippable) {
        return Selectable.Item.Tooltip.get(tooltippable).getTooltippedImage();
    },
    getItemLiWithHunting: function(tooltippable, huntingInfo) {
        return Selectable.Item.Tooltip.get(tooltippable).getTooltippedLiWithExtraText(huntingInfo);
    },
    getLeveTooltip: function(tooltippable) {
        return Selectable.Leve.Tooltip.get(tooltippable).getTooltip();
    },
    getQuestTooltip: function(tooltippable) {
        return Selectable.Quest.Tooltip.get(tooltippable).getTooltip();
    },
    getNPCLink: function(npc) {
        return $('<a></a>')
            .addClass('melsmaps-npc-link')
            .attr('data-melsmaps-npc-name', npc.name)
            .html(npc.name + ' in ' + npc.zone.name);
    },
    getSourceLine: function(source, item, hq, nq) {
        if(!source.category.getName)
            source.category = new Category(source.category);
        switch(source.category.getName()) {
            case 'Logging':
            case 'Harvesting':
            case 'Mining':
            case 'Quarrying':
                return Selectable.Gathering.Source.getLine(source);
            case 'Fishing':
                return Selectable.Fishing.Source.getLine(source, item);
            case 'Merchant':
                return Selectable.Merchant.Source.getLine(source, item);
            case 'Recipe':
                return Selectable.Recipe.Source.getLine(source);
            case 'Spawn':
                return Selectable.Spawn.Source.getLine(source, item, hq, nq);
			case 'Trial':
			case 'Dungeon':
			case 'Raid':
				return Selectable.Duty.Source.getLine(source);
            case 'Leve':
                return Selectable.Leve.Source.getLine(source);
            default:
                console.error("Can't find which kind of item source category '" + source.category.getName() + "' is.");
        }
    },
    get: function(searchable) {
        switch(searchable.category.getName()) {
            case 'Item':
                return new Selectable.Item(searchable);
            case 'Region':
                return new Selectable.Region(searchable);
            case 'Zone':
                return new Selectable.Zone(searchable);
            case 'Area':
                return new Selectable.Area(searchable);
			case 'Trial':
				return new Selectable.Trial(searchable);
			case 'Dungeon':
			case 'Raid':
				return new Selectable.MappedDuty(searchable);
            case 'Logging':
            case 'Harvesting':
            case 'Mining':
            case 'Quarrying':
                return new Selectable.Gathering(searchable);
            case 'Fishing':
                return new Selectable.Fishing(searchable);
            case 'Monster':
                return new Selectable.Mob(searchable);
            case 'Merchant':
                return new Selectable.Merchant(searchable);
			case 'Sightseeing':
				return new Selectable.Sightseeing(searchable);
            case 'NPC':
                return new Selectable.NPC(searchable);
            case 'Levemete':
                return new Selectable.Levemete(searchable);
            case 'Leve':
                return new Selectable.Leve(searchable);
            case 'Quest':
                return new Selectable.Quest(searchable);
            default:
                console.error("Can't find which kind of select-able category '" + searchable.category.getName() + "' is.");
        }
    },
    
    getFull: function(full) {
		var t = null;
        if(!full.category.getName)
            full.category = new Category(full.category);
        var searchable = {
            id: full.id,
            lid: full.lid,
            category: full.category,
            name: full.name,
            real_name: full.name,
            mode: full.mode,
            sort_order: 0
        };
		switch(full.category.getName()) {
			case 'Trial':
				t = new Selectable.Trial(null);
				break;
			case 'Dungeon':
			case 'Raid':
				t = new Selectable.MappedDuty(null);
				break;
            case 'Item':
                t = new Selectable.Item(null);
                t._info = $.when(full);
                t._sources = api.item.sources(full.lid);
                break;
            case 'NPC':
                t = new Selectable.NPC(null);
                break;
            case 'Leve':
                t = new Selectable.Leve(null);
                break;
            case 'Levemete':
                t = new Selectable.Levemete(null);
                break;
            case 'Logging':
            case 'Harvesting':
            case 'Mining':
            case 'Quarrying':
                t = new Selectable.Gathering(null);
                break;
            case 'Fishing':
                t = new Selectable.Fishing(null);
                break;
            case 'Spawn':
                t = new Selectable.Spawn(null);
                break;
            case 'Merchant':
                t = new Selectable.Merchant(null);
                break;
            default:
                console.error("Can't find which kind of full select-able category '" + searchable.category.getName() + "' is.");
		}
        t._searchable = searchable;
		t._full = $.when(full);
		return t;
    }
}
Selectable.prototype = {
    onSelect: function() {
        console.log("Selected this");
        console.log(this);
    }
}