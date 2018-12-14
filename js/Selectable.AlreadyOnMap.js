Selectable.AlreadyOnMap = function(searchable) {
    this._searchable = searchable;
};
Selectable.AlreadyOnMap.prototype = $.extend({}, Selectable.prototype, {
    onSelect: function() {
		this._full.then(function(full) {
			melsmap.flyToBounds(full.bounds);
		});
    }
});