Selectable.HasPopupAndTooltip = function(searchable) {
    this._searchable = searchable;
};
// Standard, default behavior on select: add to map, zoom to it, open popup
Selectable.HasPopupAndTooltip.prototype = $.extend({}, Selectable.HasPopup.prototype, {
    getTooltip: function(selectable) {
        var html = $('<div></div>')
            .addClass('melsmaps-tooltip')
            .append(selectable.category.getGoldIcon());
        $('<span></span>')
            .html(selectable.name)
            .appendTo(html);
        return html[0];
	},
	
	onSelect: function() {
		var that = this;
		this._full.then(function(full) {
			that._addToMap().then(function(lyr) {
                melsmap.once('zoomend', function() {
                    lyr.openPopup();
                });
            });
			melsmap.flyToBounds(full.bounds);
		});
	},
    
    showOnMap: function(group) {
        var that = this;
        this._full.then(function(full) {
            that._addToMap(group).then(function(lyr) {
                melsmap.once('zoomend', function() {
                    lyr.openPopup();
                });
            });
            melsmap.flyToBounds(full.bounds);
        });
    }
});