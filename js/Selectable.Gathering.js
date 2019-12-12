Selectable.Gathering = function(searchable) {
    this._searchable = searchable;
	if(searchable && (searchable.id || searchable.gid)) {
		var that = this;
		this._full = api("nodes", searchable.id || searchable.gid);
	}
};
Selectable.Gathering.prototype = $.extend({}, Selectable.DefaultPolygon.prototype, {
    
    _getPopupContent: function(popupable) {
		var html = null;
		if(popupable && popupable.gathering) {
            html = $('<div></div>');
			for(var i in popupable.gathering) {
				var item = popupable.gathering[i];
				if(item) {
                    html.append(Selectable.getItemGatheringLine(item));
                }
			}
		}
		return html;
	}
});

Selectable.Gathering.Source = {
    getLine: function(node) {
        node.category.iconSize = 24;
        var img = node.category.getGoldIcon();
        var a = $('<a></a>')
            .html(node.name + ' (lvl ' + node.level + ')');
        var li = $('<li></li>')
            .addClass('melsmaps-item-source-link')
            .append(img)
            .append(a)
            .attr('title', 'Click to pan to the node');
        li.data('selectable', Selectable.get(node));
        return li;
    }
};