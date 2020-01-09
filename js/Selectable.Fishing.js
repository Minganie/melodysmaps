Selectable.Fishing = function(searchable) {
    this._searchable = searchable;
	if(searchable && (searchable.id || searchable.gid)) {
		var that = this;
		this._full = api("nodes", searchable.id || searchable.gid);
	}
};
Selectable.Fishing.prototype = $.extend({}, Selectable.Gathering.prototype, {
    
    _getPopupContent: function(popupable) {
		var html = $('<div class="melsmaps-fishing-popup"></div>');
		var conds = $('<div></div>').appendTo(html);
		var time = $('<div class="melsmaps-fishing-clock"></div>').appendTo(conds);
		var weather = $('<div class="melsmaps-fishing-weather-watcher" data-melsmaps-zone="' + popupable.zone + '"></div>').appendTo(conds);
		var table = $('<table></table>').appendTo(html);
		var ok = (popupable && popupable.baits && popupable.fishes && popupable.fishing_table);
		var zone = popupable.zone;
		var node = popupable.name;
		
		if(ok) {
			// Header: target fish
            var thead = $('<thead></thead>')
                .appendTo(table);
            var trh = $('<tr></tr>')
                .appendTo(thead);
            $('<th></th>')
                .appendTo(trh);
			for(var i in popupable.fishes) {
				var fish = popupable.fishes[i];
				var f = fish.name;
				var info = gt.bell.fish.find(function(entry) {return entry.name===f && entry.title===node;});
                var th = $('<th class="melsmaps-fish" data-melsmaps-fish="' + fish.name + '"></th>')
                    .appendTo(trh);
                th.append(Selectable.getItemTooltippedImage(fish));
				var light = $('<div class="melsmaps-fishing-light"></div>').appendTo(th);
				if(info) {
					var tt = $('<div class="melsmaps-fishing-conditions-tooltip"></div>');
					var timeMarker = $('<div class="melsmaps-fishing-tt-time"></div>').appendTo(tt);
					timeMarker.append($('<div></div>'));
					if(info.during) {
						if(info.during.end < info.during.start) {
							// morning
							var l1 = 0;
							var w1 = info.during.end/4;
							// night
							var l2 = info.during.start/4;
							var w2 = (24-info.during.start)/4;
							var inter = $('<div><div style="height: 1rem; background-color: green; width: ' + w1 + 'rem; position: relative; left: ' + l1 + 'rem;"></div><div style="height: 1rem; background-color: green; width: ' + w2 + 'rem; position: relative; left: ' + l2 + 'rem; top: -1rem;"></div></div>');
						} else {
							var width = (info.during.end - info.during.start)/4;
							var left = info.during.start/4;
							var inter = $('<div><div style="height: 1rem; background-color: green; width: ' + width + 'rem; position: relative; left: ' + left + 'rem;"></div></div>');
						}
					} else {
						var inter = $('<div><div style="height: 1rem; background-color: green; width: 6rem;"></div></div>');
					}
					timeMarker.append(inter);
					var weatherMarker = $('<div class="melsmaps-fishing-tt-weather"></div>').appendTo(tt);
					if(info.weather) {
						for(var i in info.weather) {
							var name = info.weather[i];
							weatherMarker.append($('<img src="icons/weather/' + name + '.png">'));
						}
					}
					light.addClass('melsmaps-is-a-tooltip');
					light.attr('data-melsmaps-tooltip', tt[0].outerHTML);
					// console.log(tt[0].outerHTML);
					if(info.folklore === 1) {
						th.append($('<div class="melsmaps-fishing-folklore" title="Tome of Regional Folklore"></div>'));
					}
					if(info.snagging === 1) {
						th.append($('<div class="melsmaps-fishing-snagging" title="Snagging"></div>'));
					}
					if(info.fishEyes === 1) {
						th.append($('<div class="melsmaps-fishing-fisheyes" title="Fish Eyes"></div>'));
					}
					if(info.predator === 1) {
						th.append($('<div class="melsmaps-fishing-predator"></div>'));
						console.log(f + " is a predator fish");
						conosole.log(info.predator);
					}
				}
			}
			
			// Body: bait and rates
            var tbody = $('<tbody></tbody>')
                .appendTo(table);
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