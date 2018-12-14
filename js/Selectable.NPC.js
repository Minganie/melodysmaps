Selectable.NPC = function(searchable) {
    this._searchable = searchable;
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