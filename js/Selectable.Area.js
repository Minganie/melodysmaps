Selectable.Area = function(searchable) {
    this._searchable = searchable;
    this._full = api("areas", searchable.lid);
};
Selectable.Area.prototype = $.extend({}, Selectable.AlreadyOnMap.prototype, {
});