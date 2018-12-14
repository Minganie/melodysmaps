Selectable.Zone = function(searchable) {
    this._searchable = searchable;
    this._full = api("zones", searchable.lid);
};
Selectable.Zone.prototype = $.extend({}, Selectable.AlreadyOnMap.prototype, {
});