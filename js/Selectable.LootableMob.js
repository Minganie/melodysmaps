Selectable.LootableMob = function(searchable) {
    this._searchable = searchable;
	if(searchable && searchable.name) {
		this._full = api("hunting", searchable.name);
	}
};
Selectable.LootableMob.prototype = $.extend({}, Selectable.Mob.prototype, {
    _getPopupContent: function(full) {
        var html = $('<ul></ul>');
        if(full && full.drops) {
            for(var i in full.drops) {
                var item = full.drops[i];
                var extra = ' (*' + this._formatHq(item.hq, full.nkilled).prop('outerHTML') + ' & ' + this._formatNq(item.nq, full.nkilled).prop('outerHTML') + ' ' + this._formatReliable(full.nkilled).prop('outerHTML') + ')';
                html.append(Selectable.getItemLiWithHunting(item.item, extra));
            }
        }
        return html;
	},

    _formatHq: function(hq, nkilled) {
        return this._getSpan(hq, nkilled, 'High');
    },
	
    _formatNq: function(nq, nkilled) {
        return this._getSpan(nq, nkilled, 'Normal');
    },
	
	_getSpan: function(nitems, nkilled, type) {
        return $('<span></span>')
            .attr('title', type + ' quality yield')
            .html(this._computeYield(nitems, nkilled) + '%');
	},
	
    _computeYield: function(nitems, nkilled) {
        return (nkilled > 0 ? (nitems*100/nkilled).toFixed(2) : '-');
    },
	
    _formatReliable: function(nkilled) {
        return $('<span></span>')
            .attr('title', 'Reliability from 1 to 5')
            .html(this._getStars(nkilled));
    },
	
    _getStars: function(nkilled) {
        if(nkilled < 5)
            return '^';
        if(nkilled < 30)
            return '^^';
        if(nkilled < 50)
            return '^^^';
        if(nkilled < 100)
            return '^^^^';
        else return '^^^^^';
    },
    
    _formatLevel: function(mob) {
        return (mob.level ? mob.level : '?');
    }
});
Selectable.LootableMob.Source = {
    getLine: function(source, item, hq, nq) {
        source.category.iconSize = 24;
        var mob = Selectable.getFull(source);
        var img = source.category.getGoldIcon();
        var nspan = mob._getNameplate(source);
        var a = $('<a></a>')
            .append(nspan)
            .append(' (*')
            .append(mob._formatHq(hq, source.nkilled))
            .append(' & ')
            .append(mob._formatNq(nq, source.nkilled))
            .append(' ')
            .append(mob._formatReliable(source.nkilled))
            .append(')');
        var li = $('<li></li>')
            .append(img)
            .append(a)
            .addClass('melsmaps-item-source-link')
            .attr('title', 'Click to pan to the hunting ground');
        li.data('selectable', mob);
        return li;
    }
};