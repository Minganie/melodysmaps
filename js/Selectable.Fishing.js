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
                var th = $('<th class="melsmaps-fish" data-melsmaps-fish="' + fish.lid + '"></th>')
                    .appendTo(trh);
                th.append(Selectable.getItemTooltippedImage(fish));
				var light = $('<div class="melsmaps-fishing-light"></div>').appendTo(th);
				(function(th, light, fish) {
					api('fish', fish.lid)
						.done(function(info) {
							// console.log(info);
							var tt = $('<div class="melsmaps-fishing-conditions-tooltip"></div>');
							var timeMarker = $('<div class="melsmaps-fishing-tt-time"></div>').appendTo(tt);
							timeMarker.append($('<div></div>'));
							if(info.start_time && info.end_time) {
								if(info.end_time < info.start_time) {
									// morning
									var l1 = 0;
									var w1 = info.end_time/4;
									// night
									var l2 = info.start_time/4;
									var w2 = (24-info.start_time)/4;
									var inter = $('<div><div style="height: 1rem; background-color: green; width: ' + w1 + 'rem; position: relative; left: ' + l1 + 'rem;"></div><div style="height: 1rem; background-color: green; width: ' + w2 + 'rem; position: relative; left: ' + l2 + 'rem; top: -1rem;"></div></div>');
								} else {
									var width = (info.end_time - info.start_time)/4;
									var left = info.start_time/4;
									var inter = $('<div><div style="height: 1rem; background-color: green; width: ' + width + 'rem; position: relative; left: ' + left + 'rem;"></div></div>');
								}
							} else {
								var inter = $('<div><div style="height: 1rem; background-color: green; width: 6rem;"></div></div>');
							}
							timeMarker.append(inter);
							var weatherMarker = $('<div class="melsmaps-fishing-tt-weather"></div>').appendTo(tt);
							if(info.curr_weathers) {
								if(info.prev_weathers) {
									for(var i in info.prev_weathers) {
										var name = info.prev_weathers[i];
										weatherMarker.append($('<img src="icons/weather/' + name + '.png">'));
									}
									weatherMarker.append($('<span>&rarr;</span>'));
								}
								for(var i in info.curr_weathers) {
									var name = info.curr_weathers[i];
									weatherMarker.append($('<img src="icons/weather/' + name + '.png">'));
								}
							}
							light.addClass('melsmaps-is-a-tooltip');
							light.attr('data-melsmaps-tooltip', tt[0].outerHTML);
							// console.log(tt[0].outerHTML);
							if(info.folklore) {
								th.append($('<div class="melsmaps-fishing-folklore" title="Tome of Regional Folklore"></div>'));
							}
							if(info.snagging) {
								th.append($('<div class="melsmaps-fishing-snagging" title="Snagging"></div>'));
							}
							if(info.fishEyes) {
								th.append($('<div class="melsmaps-fishing-fisheyes" title="Fish Eyes"></div>'));
							}
							if(info.predator) {
								for(var i in info.predator) {
									var pred = info.predator[i];
									$('<div class="melsmaps-fishing-predator" title="Predator: ' + pred.n + 'x ' + pred.prey.name + '"><img src="' + pred.prey.licon + '" width=24 height=24><p>'+pred.n+'</p></div>')
										.appendTo(th);
								}
							}
						})
						.fail(function(jqXHR, textStatus, errorThrown) {
							console.error("Something happened while fetching fishing conditions for " + fish.name);
						});
				})(th, light, fish);
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