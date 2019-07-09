L.Layer.NamedMultiPointLayer = L.Layer.NamedLayer.extend({
    _multiPointLayer: null,
    _twoLayers: null,
    
    makeOtherGeometries: function(features) {
        if(features[0].length > 1) {
            var points = [];
            for(var i in features[0]) {
                var geom = features[0][i];
                var marker = L.marker(geom, this.options.pointStyle);
                points.push(marker);
            }
            this._multiPointLayer = L.layerGroup(points);
            this._twoLayers = L.layerGroup([this._multiPointLayer]);
        } else
            this._twoLayers = L.layerGroup([this._pointLayer]);
    },
 
    onRemove: function(map) {
        L.Layer.NamedLayer.prototype.onRemove.call(this, map);
        
        if(map && this._twoLayers) {
            map.removeLayer(this._twoLayers);
        }
    },
    
    show: function() {
		// console.log('NamedPointLayer::show');
        this._visible = true;
        if(this._map && this._map.addLayer && this._twoLayers)
            this._map.addLayer(this._twoLayers);
    },
    
    hide: function() {
        this._visible = false;
        if(this._map && this._map.removeLayer && this._twoLayers)
            this._map.removeLayer(this._twoLayers);
    },
	
	bindPopup: function(popup, options) {
        if(!this._multiPointLayer)
			this._pointLayer.eachLayer(function(layer) {
				layer.bindPopup(popup, (options || {}));
			});
		else
			this._multiPointLayer.eachLayer(function(layer) {
				layer.bindPopup(popup, (options || {}));
                layer.getPopup().update();
			});
	},
	
	openPopup: function() {
        if(!this._multiPointLayer)
            this._pointLayer.eachLayer(function(layer) {
				layer.openPopup();
			});
        else {
            (this._multiPointLayer.getLayers()[0]).openPopup();
        }
	},
    
    bindTooltip: function(tooltip, options) {
        if(!this._multiPointLayer)
            this._pointLayer.eachLayer(function(layer) {
                layer.bindTooltip(tooltip, options);
            });
        else
            this._multiPointLayer.eachLayer(function(layer) {
                layer.bindTooltip(tooltip, options);
            });
    },
    
    getLegendLabel: function() {
		// console.log('getLegendLabel');
        var url = 'http://melodysmaps.com/icons/map/none.png';
        if(this.options && this.options.pointStyle && this.options.pointStyle.icon &&
           this.options.pointStyle.icon.options && this.options.pointStyle.icon.options.iconUrl)
            url = this.options.pointStyle.icon.options.iconUrl;
            
        var label = '<span><img src="' + url + '" width="16" height="16" alt="' +
            (this.options.name || '') + ' icon" class="melsmaps-legend-image" />' + 
            (this.options.name || '') + '</span>';
        
        return label;
    }
});

L.namedMultiPointLayer = function(features, options) {
    return new L.Layer.NamedMultiPointLayer(features, options);
};