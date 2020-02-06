Selectable.Recipe = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.lid) {
        this._full = api("recipes", searchable.lid);
    }
};
Selectable.Recipe.prototype = $.extend({}, Selectable.prototype, {
    onSelect: function() {
        $('#recipe').recipeBox('instance').setRecipe(this);
    }
});
Selectable.Recipe.Source = {
    getLine: function(recipe) {
        var tt = Selectable.Recipe.Tooltip.get(recipe).getTooltip();
        var img = $('<img />')
            .attr('src', 'icons/disciplines/' + recipe.discipline.toLowerCase() + '.png')
            .attr('width', 24)
            .attr('height', 24);
        var li = $('<li class="melsmaps-recipe-tooltip"></li>')
            .append(img)
            .attr('data-melsmaps-tooltip', tt[0].outerHTML)
            .append($('<span>' + recipe.name + ' (' + recipe.discipline + ')</span>'));
        return li;
    }
};
Selectable.Recipe.Tooltip = {
    get: function(recipe) {
      return new Selectable.Recipe.Tooltip.Recipe(recipe);
    }
};

Selectable.Recipe.Tooltip.Recipe = function(recipe, className) {
    this._className = className || 'Recipe';
    this._helperId = recipe.name || 'no idea';
    this.recipe = recipe;
};
Selectable.Recipe.Tooltip.Recipe.prototype = {
    _addTop: function() {
        var div = $('<div class="melsmaps-recipe-top"></div>');
		var iconDiv = $('<div class="melsmaps-recipe-icon"></div>')
			.appendTo(div);
        $('<img alt="" width=128 height=128 />')
            .attr('src', this.recipe.licon)
            .appendTo(iconDiv);
		if(this.recipe.always_collectible) {
			$('<img alt="" src="icons/collectable.png" class="melsmaps-recipe-collectable-overlay" width=28 height=28 />')
				.appendTo(iconDiv);
		}
		$('<div></div>')
			.appendTo(iconDiv);
        var middle = $('<div></div>')
            .append($('<p>' + this.recipe.discipline + '</p>'))
            .appendTo(div);
        if(this.recipe.mastery)
            middle.append($('<p>' + this.recipe.mastery + '</p>'));
		var p = $('<p class="melsmaps-recipe-name">' + this.recipe.name + '</p>');
		if(this.recipe.always_collectible)
			p.append($('<img src="icons/collectable.png" width=14 height=14 alt="" />'));
        middle.append(p);
        middle.append($('<p>' + this.recipe.cat + '</p>'));
        var stars = '';
        if(this.recipe.n_stars)
            for(var i=0; i<this.recipe.n_stars; i++)
                stars += '&#9733;';
        $('<p></p>')
            .append($('<span>Lv. ' + this.recipe.level + stars + '</span>'))
            .appendTo(div);
        return div;
    },
    _makeItemImgAndText: function(item, number) {
        var tt = Selectable.Item.Tooltip.get(item);
        var block = $('<div class="imgAndText"></div>');
        $('<img alt="" width=32 height=32 />')
            .attr("src", item.licon)
            .appendTo(block);
        block.append($('<span>' + number + '</span>'));
        $('<span class="melsmaps-is-a-tooltip llink"></span>')
            .attr('data-melsmaps-tooltip', tt.getTooltip().outerHTML)
            .html(item.name)
            .appendTo(block);
        return block;
    },
    _addMaterials: function() {
        var div = $('<div class="melsmaps-recipe-block"></div>');
        div.append($('<h2>Materials</h2>'));
        for(var i in this.recipe.materials) {
            var mat = this.recipe.materials[i];
            div.append(this._makeItemImgAndText(mat.material, mat.n));
        }
        return div;
    },
    _addCrystals: function() {
        var div = $('<div class="melsmaps-recipe-block"></div>');
        div.append($('<h2>Crystals</h2>'));
        for(var i in this.recipe.crystals) {
            var crystal = this.recipe.crystals[i];
            div.append(this._makeItemImgAndText(crystal.material, crystal.n));
        }
        return div;
    },
    _hasConditions: function() {
        var r = this.recipe;
        return r.rec_craft || r.req_craft || r.req_contr
            || r.req_contr_qs || r.req_craft_qs || r.aspect 
            || r.specialist
            || !r.has_qs || !r.has_hq || r.has_coll
            || r.no_xp || r.equipment || r.facility_access;
    },
    _makeConditions: function() {
        var r = this.recipe;
        var d = $('<div></div>');
        d.append($('<h3>Characteristics</h3>'));
        if(r.rec_craft)
            d.append($('<p>Crafstmanship Recommended: ' + r.rec_craft + '</p>'));
        if(r.req_craft)
            d.append($('<p>Crafstmanship Required: ' + r.req_craft + '</p>'));
        if(r.req_contr)
            d.append($('<p>Control Required: ' + r.req_contr + '</p>'));
        if(r.req_contr_qs)
            d.append($('<p>Quick Synthesis Control Required: ' + r.req_contr_qs + '</p>'));
        if(r.req_craft_qs)
            d.append($('<p>Quick Synthesis Crafstmanship Required: ' + r.req_craft_qs + '</p>'));
        if(r.aspect)
            d.append($('<p>' + r.aspect + '</p>'));
        if(r.specialist)
            d.append($('<p>Specialist Recipe</p>'));
        if(!r.has_qs)
            d.append($('<p>Quick Synthesis Unavailable</p>'));
        if(!r.has_hq)
            d.append($('<p>HQ Uncraftable</p>'));
        if(r.has_coll)
            d.append($('<p>Collectable Synthesis Available</p>'));
        if(r.no_xp)
            d.append($('<p>No EXP</p>'));
        if(r.equipment)
            d.append($('<p>' + r.equipment.name + '</p>'));
        if(r.facility_access)
            d.append($('<p>' + r.facility_access + '</p>'));
		if(r.always_collectible)
			d.append($('<p>Always Synthesized as Collectable</p>'));
        return d;
    },
    _addDetails: function() {
        var div = $('<div class="melsmaps-recipe-block"></div>');
        div.append($('<h2>Recipe Details</h2>'));
        var t = '<table><tr><td>Total Crafted <span>' + this.recipe.nb + '</span></td><td>Difficulty <span>' + this.recipe.difficulty + '</span></td></tr><tr><td>Durability <span>' + this.recipe.durability + '</span></td><td>Maximum Quality <span>' + this.recipe.max_quality + '</span></td></tr><tr><td>Maximum Starting Quality <span>' + this.recipe.quality + '%</span></td><td></td></tr></table>';
        div.append($(t));
        if(this._hasConditions())
            this._makeConditions().appendTo(div);
        return div;
    },
    getTooltip: function() {
		var html = $('<div class="melsmaps-recipe-tooltip-container"></div>');
        var wrapper = $('<div class="melsmaps-recipe-tooltip-wrapper"></div>').appendTo(html);
        wrapper.append(this._addTop());
        wrapper.append(this._addMaterials());
        wrapper.append(this._addCrystals());
        wrapper.append(this._addDetails());
		return html;
	}
};