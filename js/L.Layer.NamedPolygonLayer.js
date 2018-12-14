L.Layer.NamedPolygonLayer = L.Layer.NamedLayer.extend({
    _polygonLayer: null,
    _twoLayers: null,
    
    options: {
        polygonStyle: {
        }
    },
    
    makeOtherGeometries: function(geoms) {
        // console.log("NamedPolygonLayer::makeOtherGeometries");
        // console.log(geoms);
        var polygons = [];
        for(var i in geoms) {
            var geom = geoms[i];
            // console.log(feature);
            polygons.push(L.polygon(geom, this.options.polygonStyle));
        }
        
        this._polygonLayer = L.layerGroup(polygons);
        if(this._pointLayer && this._polygonLayer)
            this._twoLayers = L.layerGroup([this._polygonLayer, this._pointLayer]);
    },
    
    bindPopup: function(popup) {
        if(this._polygonLayer)
            this._polygonLayer.eachLayer(function(layer) {
                layer.bindPopup(popup);
                layer.getPopup().update();
            });
    },
    
    openPopup: function() {
        if(this._polygonLayer && this._polygonLayer.getLayers && this._polygonLayer.getLayers().length > 0) {
            var l = this._polygonLayer.getLayers()[0];
            l.openPopup();
        }
    },
    
    onRemove: function(map) {
        L.Layer.NamedLayer.prototype.onRemove.call(this, map);
        if(map && this._twoLayers)
            map.removeLayer(this._twoLayers);
    },
    
    show: function() {
        // console.log("NamedPolygonLayer::show " + this.options.name);
        // console.log(this);
		// console.log(this.input);
        // console.log(this._map);
        // console.log(this._map.addLayer);
        // console.log(this._twoLayers);
        this._visible = true;
        if(this._map && this._map.addLayer && this._twoLayers)
            this._map.addLayer(this._twoLayers);
    },
    
    hide: function() {
        this._visible = false;
        if(this._map && this._map.removeLayer && this._twoLayers)
            this._map.removeLayer(this._twoLayers);
    },
    
    getLegendLabel: function() {
        
        function isHexColor(color) {
            return color.toString().startsWith('#');
        }
        function hexToRgba(color, a) {
            var r = parseInt(color.substring(1,3), 16);
            var g = parseInt(color.substring(3,5), 16);
            var b = parseInt(color.substring(5,7), 16);
            return 'rgba(' + r + ', ' + g + ', ' + b + ', ' + a + ')';
        }
        function getBorderColor(opts) {
            if(!opts.color)
                return 'rgba(0, 0, 0, 0)';
            if(isHexColor(opts.color))
                return hexToRgba(opts.color, (opts.opacity ? opts.opacity : 0));
            else
                return opts.color;
        }
        function getFillColor(opts) {
            if(!(opts.fill && opts.fillColor))
                return 'rgba(0,0,0,0)';
            if(isHexColor(opts.fillColor))
                return hexToRgba(opts.fillColor, (opts.fillOpacity ? opts.fillOpacity : 0));
            else
                return opts.fillColor;
        }
        
        var style = '';
        
        if(this._polygonLayer && this._polygonLayer.getLayers && 
           this._polygonLayer.getLayers().length > 0 && 
           this._polygonLayer.getLayers()[0].options) {
                var opts = this._polygonLayer.getLayers()[0].options;
                // console.log(opts);
                // console.log("border: " + getBorderColor(opts) );
                // console.log("fill: " + getFillColor(opts));
                style += 'border: 2px solid ' + getBorderColor(opts) + '; ';
                style += 'background-color: ' + getFillColor(opts) + '; ';
        }
        
        var label = '<span><div class="square melsmaps-legend-image" style="' + 
            style + '"></div>' + (this.options.name || '') + '</span>';
        
        return label;
    }
});

L.namedPolygonLayer = function(features, options) {
    return new L.Layer.NamedPolygonLayer(features, options);
};