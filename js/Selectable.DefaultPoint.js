Selectable.DefaultPoint = function(searchable) {
    this._searchable = searchable;
};
Selectable.DefaultPoint.prototype = $.extend({}, Selectable.HasPopupAndTooltip.prototype, {
    _addToMap: function(group) {
        var that = this;
        return this._full.then(function(full) {
            var point = L.namedPointLayer([full], {
                name: full.name, 
                minZoom: 7,
                maxZoom: 10,
                inLegend: true,
                legendGroup: group,
                pointStyle: full.category.getPointStyle(),
                nameClass: 'melsmaps-tooltip',
                searchable: {}
            }).addTo(melsmap);
            point.bindTooltip(that.getTooltip(full), {
                permanent: true,
                className: 'melsmaps-tooltip',
                direction: 'right',
                offset: [5, 0]
            });
            point.bindPopup(that.getPopup(full));
            return point; 
        });

	}
});