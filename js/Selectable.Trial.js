Selectable.Trial = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.real_name)
        this._full = api("duties", searchable.real_name);
};
Selectable.Trial.prototype = $.extend({}, Selectable.HasPopup.prototype, {
    _addToMap: function(group) {
        this._full.then(function(full) {
            var layer = melsmap.getDutyLayer(full.name);
            layer.options.inLegend = true;
            layer.getLegendGroup = function() {return group;};
            layer.getLegendLabel = function() {
                return '<span><img src="http://melodysmaps.com/icons/map/trial.png" width="16" height="16" alt="' +
                (name || '') + ' icon" class="melsmaps-legend-image" />' + 
                (name || '') + '</span>';
            };
            layer.addTo(melsmap);
        });
    },
    onSelect: function() {
        this._full.then(function(full) {
			melsmap.flyToBounds(full.bounds);
			melsmap.once('zoomend', function() {
				var lyr = melsmap.getDutyLayer(full.name);
				lyr.openPopup();
			});
		});
    },
    _getPopupSubtitle: function(popupable) {
		return $('<h2></h2>')
            .html(popupable.category.getName());
	},
	_getPopupContent: function(popupable) {
        var html = $('<ul></ul>')
            .addClass('duty trial');
		var rm = null;
        var hm = null;
        var xm = null;
		var sm = null;
		var um = null;
        var duties = (popupable && popupable.modes ? popupable.modes : null);
        if(duties) {
            for(var mode in duties) {
                var duty = duties[mode];
                var encounter = duty.encounters[0];
                
                if(encounter && encounter.encounter) {
                    switch(mode) {
                        case 'Regular':
                            var encounter_li = $('<li></li>')
                                .addClass('mode');
                            rm = encounter_li;
                            break;
                        case 'Hard':
                            var encounter_li = $('<li></li>')
                                .addClass('mode');
                            hm = encounter_li;
                            break;
                        case 'Extreme':
                            var encounter_li = $('<li></li>')
                                .addClass('mode');
                            xm = encounter_li;
                            break;
                        default:
                            console.error("Can't find which trial mode '" + mode + "' is");
                    }
                    var h2 = $('<h2></h2>')
                        .appendTo(encounter_li);
                    $('<img />')
                        .attr({
                            src: 'http://www.melodysmaps.com/icons/map/boss.png',
                            width: 24,
                            height: 24,
                            alt: ''
                        })
                        .appendTo(h2);
                    $('<span></span>')
                        .html(encounter.encounter + ' (' + mode + ') (level ' + duty.level + ')')
                        .appendTo(h2);
                    var encounter_ul = $('<ul></ul>')
                        .appendTo(encounter_li);
                    
                    if(encounter.tokens) {
                        for(var i in encounter.tokens) {
                            var token = encounter.tokens[i];
                            var li = $('<li></li>');
                            $('<span></span>')
                                .html(token.qty + ' ')
                                .appendTo(li);
                            $('<img />')
                                .attr({
                                    src: token.token.icon,
                                    width: 24,
                                    height: 24,
                                    alt: token.token.name + ' icon'
                                })
                                .appendTo(li);
                            $('<span></span>')
                                .html(token.token.name)
                                .appendTo(li);
                            
                            encounter_ul.append(li);
                        }
                    }
                    
                    if(encounter.items) {
                        for(var j in encounter.items) {
                            var item = encounter.items[j];
							if(item){
                                encounter_ul.append(Selectable.getItemTooltippedLi(item));
                            }
                        }
                    }
                }
            }
        } else {
			rm = $('<p>Waiting on Mel to generate content...</p>');
		}
        return html.append(rm).append(hm).append(xm).append(sm).append(um);
	}
});
Selectable.Duty = {
    Source: {
        getLine: function(duty) {
            duty.category.iconSize = 24;
            var img = duty.category.getGoldIcon();
            var a = $('<a></a>')
                .html(duty.name + ' (' + duty.mode + ')' + ' (lvl ' + duty.level + ')');
            var li = $('<li></li>')
                .append(img)
                .append(a)
                .addClass('melsmaps-item-source-link')
                .attr('title', 'Click to pan to the duty');
            li.data('selectable', Selectable.getFull(duty));
            return li;
        }
    }
};