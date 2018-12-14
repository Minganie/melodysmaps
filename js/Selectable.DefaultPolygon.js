Selectable.DefaultPolygon = function(searchable) {
    this._searchable = searchable;
};
Selectable.DefaultPolygon.prototype = $.extend({}, Selectable.HasPopupAndTooltip.prototype, {
    _addToMap: function(group) {
        var that = this;
        return this._full.then(function(full) {
            var poly = L.namedPolygonLayer([full], {
                name: full.name,
                minZoom: 7,
                maxZoom: 10,
                inLegend: true,
                legendGroup: group,
                polygonStyle: full.category.getPolygonStyle(),
                nameClass: 'melsmaps-tooltip',
                searchable: {}
            }).addTo(melsmap);
            poly.bindTooltip(that.getTooltip(full), {
                permanent: true,
                className: 'melsmaps-tooltip',
                direction: 'right',
                offset: [5, 0]
            });
            poly.bindPopup(that.getPopup(full));
            return poly;
        });
    }
});