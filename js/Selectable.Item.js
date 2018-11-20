Selectable.Item = function(searchable) {
    this._searchable = searchable;
    this._info = api.item.info(searchable.lid);
    this._sources = api.item.sources(searchable.lid);
}
Selectable.Item.prototype = $.extend({}, Selectable.prototype, {
    onSelect: function() {
        $('#item').ItemBox("instance").setItem(this);
    }
});