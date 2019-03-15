Selectable.MappedDuty = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.real_name)
        this._full = api("duties", searchable.real_name);
};
Selectable.MappedDuty.prototype = $.extend({}, Selectable.HasPopup.prototype, {
    _addToMap: function(group) {
        this._full.then(function(full) {
            var name = full.name;
            var icon = full.category.getName().toLowerCase();
            var layer = melsmap.getDutyLayer(name);
            layer.options.inLegend = true;
            layer.getLegendGroup = function() {return group;};
            layer.getLegendLabel = function() {
                return '<span><img src="http://melodysmaps.com/icons/map/' + icon 
                + '.png" width="16" height="16" alt="' +
                (name || '') + ' icon" class="melsmaps-legend-image" />' + 
                (name || '') + '</span>';
            };
            layer.addTo(melsmap);
        });
    },
    onSelect: function() {
		var that = this;
        $('#duty').dutyBox('instance').setDuty(that);
		this._full.then(function(full) {
			melsmap.flyToBounds(full.bounds);
		});
	},
    _getPopupSubtitle: function(popupable) {
		return $('<h2></h2>')
            .html(popupable.category.getName());
	},
	_getPopupContent: function(popupable) {
		var html = $('<div></div>')
            .addClass('div-as-list');
		var rm = null;
		var hm = null;
		var xm = null;
		var sm = null;
		var um = null;
		if(popupable && popupable.modes) {
			for(var i in popupable.modes) {
				var duty = popupable.modes[i];
				switch(i) {
					case 'Regular':
						rm = $('<button></button>')
							.addClass('melsmaps-duties-link');
						var btn = rm;
						break;
					case 'Hard':
						hm = $('<button></button>')
							.addClass('melsmaps-duties-link');
						var btn = hm;
						break;
					case 'Extreme':
						rm = $('<button></button>')
							.addClass('melsmaps-duties-link');
						var btn = xm;
						break;
					case 'Savage':
						sm = $('<button></button>')
							.addClass('melsmaps-duties-link');
						var btn = sm;
						break;
					case 'Ultimate':
						um = $('<button></button>')
							.addClass('melsmaps-duties-link');
						var btn = um;
						break;
					default:
						console.error('Unknown mapped duty difficulty: ' + i);
				}
                $('<span></span>')
                    .html('See the map for ')
                    .appendTo(btn);
                $('<span></span>')
                    .addClass('duty-name')
                    .html(popupable.name)
                    .appendTo(btn);
                btn.append(' (');
                $('<span></span>')
                    .addClass('duty-mode')
                    .html(i)
                    .appendTo(btn);
                btn.append(' (level ');
                $('<span></span>')
                    .addClass('duty-level')
                    .html(duty.level)
                    .appendTo(btn);
                btn.append('))');
                $('<span></span>')
                    .addClass('duty-cat')
                    .attr('style', 'display: none;')
                    .html(popupable.category.getName())
                    .appendTo(btn);
			}
			html.append(rm)
                .append(hm)
                .append(xm)
				.append(sm)
				.append(um);
		} else {
			html.append($('<p>Waiting on Mel to generate content...</p>'));
		}
		return html;
	}
});