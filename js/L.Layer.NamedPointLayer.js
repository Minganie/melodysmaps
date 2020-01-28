L.Layer.NamedPointLayer = L.Layer.NamedLayer.extend({
    
    onRemove: function(map) {
        L.Layer.NamedLayer.prototype.onRemove.call(this, map);
        
        if(map && this._pointLayer) {
            map.removeLayer(this._pointLayer);
        }
    },
    
    show: function() {
		// console.log('NamedPointLayer::show');
        this._visible = true;
        if(this._map && this._map.addLayer && this._pointLayer)
            this._map.addLayer(this._pointLayer);
    },
    
    hide: function() {
        this._visible = false;
        if(this._map && this._map.removeLayer && this._pointLayer)
            this._map.removeLayer(this._pointLayer);
    },
	
	bindPopup: function(popup, options) {
		if(this._pointLayer)
			this._pointLayer.eachLayer(function(layer) {
				layer.bindPopup(popup, (options || {}));
			});
	},
	
	openPopup: function() {
		if(this._pointLayer) {
			this._pointLayer.eachLayer(function(layer) {
				layer.openPopup();
			});
		}
	},
    
    getLegendLabel: function() {
		// console.log('getLegendLabel');
        var url = 'https://melodysmaps.com/icons/map/none.png';
        if(this.options && this.options.pointStyle && this.options.pointStyle.icon &&
           this.options.pointStyle.icon.options && this.options.pointStyle.icon.options.iconUrl)
            url = this.options.pointStyle.icon.options.iconUrl;
            
        var label = '<span><img src="' + url + '" width="16" height="16" alt="' +
            (this.options.name || '') + ' icon" class="melsmaps-legend-image" />' + 
            (this.options.name || '') + '</span>';
        
        return label;
    }
});

L.namedPointLayer = function(features, options) {
    return new L.Layer.NamedPointLayer(features, options);
};