Selectable.Mob = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.real_name)
        this._full = api("monsters", searchable.real_name);
};
Selectable.Mob.prototype = $.extend({}, Selectable.prototype, {
    onSelect: function() {
        var that = this;
        this._full.then(function(full) {
            var bounds = [[90,180], [-90,-180]];
            for(var i in full.spawns) {
                var spawn = full.spawns[i];
                bounds[0][1] = Math.min(bounds[0][1], spawn.bounds[0][1]);
                bounds[0][0] = Math.min(bounds[0][0], spawn.bounds[0][0]);
                bounds[1][0] = Math.max(bounds[1][0], spawn.bounds[1][0]);
                bounds[1][1] = Math.max(bounds[1][1], spawn.bounds[1][1]);
                var spawnSelectable = Selectable.getFull(spawn);
                var poly = L.namedPolygonLayer([spawn], {
                    name: spawn.label,
                    minZoom: 7,
                    maxZoom: 10,
                    inLegend: true,
                    legendGroup: full.name,
                    polygonStyle: spawn.category.getPolygonStyle(),
                    nameClass: 'melsmaps-tooltip',
                    searchable: {}
                }).addTo(melsmap);
                poly.bindTooltip(spawnSelectable.getTooltip(spawn), {
                    permanent: true,
                    className: 'melsmaps-tooltip',
                    direction: 'right',
                    offset: [5, 0]
                });
                poly.bindPopup(spawnSelectable.getPopup(spawn));
            }
            melsmap.flyToBounds(bounds);
        });
    }
});