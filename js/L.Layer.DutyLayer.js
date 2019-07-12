L.Layer.DutyLayer = L.Layer.NamedPointLayer.extend({
    
    _trials: null,
    _dungeons: null,
    _raids: null,
    // _threeLayers: null,
	_visible: null,
    
    initialize: function(features, options) {
        L.setOptions(this, options);
        
        var trials = [];
        var dungeons = [];
        var raids = [];
        
        for(var i in features) {
            var feature = features[i];
            console.log(feature);
            
            var icon = null;
            var group = null;
            switch(feature.category.getName()) {
                case 'Trial':
                    icon = this.options.icons.trial;
                    group = trials;
                    break;
                case 'Dungeon':
                    icon = this.options.icons.dungeon;
                    group = dungeons;
                    break;
                case 'Raid':
                    icon = this.options.icons.raid;
                    group = raids;
                    break;
            }
			
            var point = L.marker(feature.centroid, {icon : icon});
			
			// Tooltip
            point.bindTooltip((feature.name || '').toString(), { 
                permanent: true, 
                direction: 'right',
                className: this.options.pointStyle.className,
                legendGroup: feature.cat
            });
			
			// Popup
            (function(feat, layer) {
				var duty = Selectable.getFull(feat);
                duty._full.then(function(full) {
                    layer.bindPopup(duty.getPopup(full));
                });
            })(feature, point);
            group.push(point);
        }
        function getLabel(dutyType) {
            switch(dutyType) {
                case 'Trials':
                    var url = options.icons.trial.options.iconUrl;
                    break;
                case 'Dungeons':
                    var url = options.icons.dungeon.options.iconUrl;
                    break;
                case 'Raids':
                    var url = options.icons.raid.options.iconUrl;
                    break;
                default:
                    console.error("L.Layer.DutyLayer::66 - Can't find which type of duty '" + dutyType + "' is");
            }
            var label = '<span><img src="' + url + '" width="16" height="16" alt="' +
                dutyType + ' icon" class="melsmaps-legend-image" />' + 
                dutyType + '</span>';
			
            return label;
        }
        
        this._trials = L.layerGroup(trials, { label: getLabel('Trials') });
        this._dungeons = L.layerGroup(dungeons, { label: getLabel('Dungeons') });
        this._raids = L.layerGroup(raids, { label: getLabel('Raids') });
        // this._threeLayers = L.layerGroup([this._trials, this._dungeons, this._raids]);
		// console.log('init worked');
    },
    
    onRemove: function(map) {
        L.Layer.NamedLayer.prototype.onRemove.call(this, map);
        
        if(map && map.removeLayer && this._trials && this._dungeons && this._raids) {
            map.removeLayer(this._trials);
            map.removeLayer(this._dungeons);
            map.removeLayer(this._raids);
        }
    },
    
    show: function() {
		// console.log('show');
		// console.log(this._trials);
		// console.log(this._dungeons);
		// console.log(this._raids);
		// console.log(this._map);
        this._visible = true;
        if(this._map && this._map.addLayer && this._trials && this._dungeons && this._raids) {
            this._map.addLayer(this._trials);
            this._map.addLayer(this._dungeons);
            this._map.addLayer(this._raids);
        }
    },
    
    hide: function() {
        this._visible = false;
        if(this._map && this._map.removeLayer && this._trials && this._dungeons && this._raids) {
            this._map.removeLayer(this._trials);
            this._map.removeLayer(this._dungeons);
            this._map.removeLayer(this._raids);
        }
    },
    
    getLayers: function() {
		// console.log('getLayers');
        return [this._trials, this._dungeons, this._raids];
    }
});

L.dutyLayer = function(features, options) {
    return new L.Layer.DutyLayer(features, options);
};