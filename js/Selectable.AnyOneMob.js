Selectable.AnyOneMob = function(searchable) {
    this._searchable = searchable;
	if(searchable && searchable.name) {
		this._full = api("mobs", searchable.name);
	}
};
Selectable.AnyOneMob.prototype = $.extend({}, Selectable.Mob.prototype, {
    _getPopupSubtitle: function(popupable) {
        return $('<h2></h2>')
            .html('Monster');
    },
	_getPopupContent: function(popupable) {
        var url = this._getNameplateIconUrl(popupable);
        var title = this._getNameplateIconAlt(popupable);
        var img = $('<img />')
            .attr({
                src: url,
                width: 24,
                height: 24,
                title: title
            });
        return $('<p></p>')
            .append(img)
            .append(' Level: ')
            .append(this._formatLevel(popupable));
    },
    _formatLevel: function(popupable) {
        return '[' + popupable.minlvl + ' - ' + popupable.maxlvl + ']';
    }
});