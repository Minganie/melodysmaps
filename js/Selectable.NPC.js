Selectable.NPC = function(searchable) {
    this._searchable = searchable;
    if(!this._full && this._searchable && this._searchable.id){
        this._full = api("npcs", this._searchable.id);
    }
};
Selectable.NPC.prototype = $.extend({}, Selectable.DefaultPoint.prototype, {
    _getPopupContent: function() {
        return $('<span></span>');
    },
    _getPopupSubtitle: function(popupable) {
        return $("<h2>" + popupable.category.getName() + "</h2>");
    },
	getTooltip: function(tooltippable) {
        var html = $('<div></div>')
            .addClass('melsmaps-tooltip');
        $('<span></span>')
            .append($('<span>' + tooltippable.name + '</span>'))
            .appendTo(html);
        return html[0];
	}
});