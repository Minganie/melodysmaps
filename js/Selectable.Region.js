Selectable.Region = function(searchable) {
    this._searchable = searchable;
    this._full = api("regions", searchable.lid);
};
Selectable.Region.prototype = $.extend({}, Selectable.AlreadyOnMap.prototype, {
});