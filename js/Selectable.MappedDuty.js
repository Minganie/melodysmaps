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
		var rm = $('<button></button>')
                    .addClass('melsmaps-duties-link');
		var hm = $('<button></button>')
                    .addClass('melsmaps-duties-link');
		var xm = $('<button></button>')
                    .addClass('melsmaps-duties-link');
		if(popupable && popupable.modes) {
			for(var i in popupable.modes) {
				var duty = popupable.modes[i];
				if(i == 'Regular')
					var btn = rm;
				else if(i == 'Hard')
					var btn = hm;
				else
					var btn = xm;
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
                .append(xm);
		}
		return html;
	}
});