Selectable.Fishing = function(searchable) {
    this._searchable = searchable;
	if(searchable && searchable.id) {
		var that = this;
		this._full = api("nodes", searchable.id);
	} else if(searchable && searchable.gid) {
		var that = this;
		this._full = api("nodes", searchable.gid);
	}
};
Selectable.Fishing.prototype = $.extend({}, Selectable.Gathering.prototype, {
    
    _getPopupContent: function(popupable) {
		var html = $('<table></table>');
		var ok = (popupable && popupable.baits && popupable.fishes && popupable.fishing_table);
		
		if(ok) {
			// Header: target fish
            var thead = $('<thead></thead>')
                .appendTo(html);
            var trh = $('<tr></tr>')
                .appendTo(thead);
            $('<th></th>')
                .appendTo(trh);
			for(var i in popupable.fishes) {
				var fish = popupable.fishes[i];
                var th = $('<th></th>')
                    .appendTo(trh);
                th.append(Selectable.getItemTooltippedImage(fish));
			}
			
			// Body: bait and rates
            var tbody = $('<tbody></tbody>')
                .appendTo(html);
			for(var i in popupable.baits) {
				var tr = $('<tr></tr>')
                    .appendTo(tbody);
				var bait = popupable.baits[i];
                var td = $('<td></td>')
                    .appendTo(tr);
                td.append(Selectable.getItemTooltippedImage(bait));
				for(var j in popupable.fishes) {
					var rate = popupable.fishing_table[i][j];
                    $('<td></td>')
                        .html(rate && rate != '0.00' && rate != '0,00' ? rate : '')
                        .appendTo(tr);
				}
			}
		}
		return html;
	}
});
Selectable.Fishing.Source = {
    getLine: function(node) {
        // console.log("Getting line for node " + node.name);
        var baitname = '?';
        var rate = '?';
        if(node && node.trail && node.rate) {
            baitname = (node.trail.length > 1 ? 'mooching' : node.trail[0].name);
            rate = node.rate;
        }
        node.category.iconSize = 24;
        var img = node.category.getGoldIcon();
        var a = $('<a></a>')
            .html(node.name + ' (' + rate + '% with ' + baitname + ') (lvl ' + node.level + ')');
        var li = $('<li></li>')
            .addClass('melsmaps-item-source-link')
            .append(img)
            .append(a)
            .attr('title', 'Click to pan to the node');
        li.data('selectable', Selectable.get(node));
        return li;
    }
};