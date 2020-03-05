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
				(function(th, light, fish, that) {
					api('fish', fish.lid)
						.done(function(conditions) {
							// console.log(info);
							var tt = $('<div class="melsmaps-fishing-conditions-tooltip"></div>');
							tt.append(that._makeWeatherMarker(conditions));
							
							var timeMarker = $('<div class="melsmaps-fishing-tt-time"></div>').appendTo(tt);
							timeMarker.append($('<div></div>'));
							timeMarker.append(that._makeClockRectangle(conditions));
							
							light.addClass('melsmaps-is-a-tooltip');
							light.attr('data-melsmaps-tooltip', tt[0].outerHTML);
							// console.log(tt[0].outerHTML);
							if(conditions.folklore) {
								th.append($('<div class="melsmaps-fishing-folklore" title="Tome of Regional Folklore"></div>'));
							}
							if(conditions.snagging) {
								th.append($('<div class="melsmaps-fishing-snagging" title="Snagging"></div>'));
							}
							if(conditions.fishEyes) {
								th.append($('<div class="melsmaps-fishing-fisheyes" title="Fish Eyes"></div>'));
							}
							if(conditions.predator) {
								for(var i in conditions.predator) {
									var pred = conditions.predator[i];
									$('<div class="melsmaps-fishing-predator" title="Predator: ' + pred.n + 'x ' + pred.prey.name + '"><img src="' + pred.prey.licon + '" width=24 height=24><p>'+pred.n+'</p></div>')
										.appendTo(th);
								}
							}
						})
						.fail(function(jqXHR, textStatus, errorThrown) {
							console.error("Something happened while fetching fishing conditions for " + fish.name);
						});
				})(th, light, fish, this);
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
	},
	
	_makeClockRectangle: function(conditions) {
		if(conditions.start_time && conditions.end_time) {
			if(conditions.end_time < conditions.start_time) {
				// morning
				var l1 = 0;
				var w1 = conditions.end_time/4;
				// night
				var l2 = conditions.start_time/4;
				var w2 = (24-conditions.start_time)/4;
				return $('<div><div style="height: 1rem; background-color: green; width: ' + w1 + 'rem; position: relative; left: ' + l1 + 'rem;"></div><div style="height: 1rem; background-color: green; width: ' + w2 + 'rem; position: relative; left: ' + l2 + 'rem; top: -1rem;"></div></div>');
			} else {
				var width = (conditions.end_time - conditions.start_time)/4;
				var left = conditions.start_time/4;
				return $('<div><div style="height: 1rem; background-color: green; width: ' + width + 'rem; position: relative; left: ' + left + 'rem;"></div></div>');
			}
		} else {
			return $('<div><div style="height: 1rem; background-color: green; width: 6rem;"></div></div>');
		}
	},
	
	_makeWeatherMarker: function(conditions) {
		var weatherMarker = $('<div class="melsmaps-fishing-tt-weather"></div>');
		if(conditions.curr_weathers) {
			if(conditions.prev_weathers) {
				for(var i in conditions.prev_weathers) {
					var name = conditions.prev_weathers[i];
					weatherMarker.append($('<img src="icons/weather/' + name + '.png">'));
				}
				weatherMarker.append($('<span>&rarr;</span>'));
			}
			for(var i in conditions.curr_weathers) {
				var name = conditions.curr_weathers[i];
				weatherMarker.append($('<img src="icons/weather/' + name + '.png">'));
			}
		}
		return weatherMarker;
	}
});
Selectable.Fishing.Source = {
    getLine: function(node, item) {

        // console.log("Getting line for node " + node.name);
        var baitname = '?';
        var rate = '?';
        if(node && node.trail && node.rate) {
            baitname = (node.trail.length > 1 ? 'mooching' : node.trail[0].name);
            rate = node.rate;
        }
        node.category.iconSize = 24;
		var light = $('<div class="melsmaps-fishing-light"></div>');
        var img = node.category.getGoldIcon();
        var a = $('<a></a>')
            .html(node.name + ' (' + rate + '% with ' + baitname + ') (lvl ' + node.level + ')');
        var li = $('<li class="melsmaps-fishing-source melsmaps-item-source-link"></li>')
			.append(light)
            .append(img)
            .append(a)
            .attr('title', 'Click to pan to the node');
        li.data('selectable', Selectable.get(node));
		li.data('fishing-conditions', item.fish_conditions);
		li.data('zone-name', node.zone);
		if(Fish.isFishable(item.fish_conditions, node.zone)) {
			light.addClass('green').removeClass('red');
		} else {
			light.addClass('red').removeClass('green');
		}
        return li;
    }
};