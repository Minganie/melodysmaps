L.Layer.NamedLayer = L.Layer.extend({
    _pointLayer: null,
    _visible: null,
    _map: null,
    
    options: {
        pointStyle: {
            opacity: 0,
            className: 'melsmaps-tooltip'
        }
    },
    
    tooltipOptions: { 
        permanent: true, 
        direction: 'center',
        offset: [0, -10]
    },
    
    initialize: function(features, options) {
		var getCentroid = function (arr) {
			var sumX = 0;
			var sumY = 0;
			for(var i in arr[0]) {
				// console.log(arr[0][i]);
				sumX += arr[0][i][0];
				sumY += arr[0][i][1];
			}
			return [sumX/arr[0].length, sumY/arr[0].length];
		}
        this._bounds = [[90,180], [-90,-180]];
        
        L.setOptions(this, options);
        var geoms = [];
        var centroids = [];
        // console.log(features);
		
        for(var i in features) {
            var feature = features[i];
            // console.log(feature);
            this._bounds[0][1] = Math.min(this._bounds[0][1], feature.bounds[0][1]);
            this._bounds[0][0] = Math.min(this._bounds[0][0], feature.bounds[0][0]);
            this._bounds[1][0] = Math.max(this._bounds[1][0], feature.bounds[1][0]);
            this._bounds[1][1] = Math.max(this._bounds[1][1], feature.bounds[1][1]);
            // console.log(this._bounds);
            // console.log('minx < maxx ? ' + (this._bounds[0][1] < this._bounds[1][1]));
            // console.log('miny < maxy ? ' + (this._bounds[0][0] < this._bounds[1][0]));
            // console.log(feature.centroid);
            
            this.options.pointStyle.className = this.options.nameClass || this.options.pointStyle.className;
			if(feature.geom.length && feature.geom.length > 1) {
				for(var j in feature.geom) {
					var centroid = getCentroid(feature.geom[j]);
					// console.log(centroid);
					var point = L.marker(centroid, this.options.pointStyle);
					if(!this.options.searchable)
						point.bindTooltip((feature.name ? feature.name : '' ).toString(), { 
							permanent: true, 
							direction: 'center',
							offset: [0, -10],
							className: this.options.pointStyle.className
						});
					centroids.push(point);
				}
			} else {
				var point = L.marker(feature.centroid, this.options.pointStyle);
				if(!this.options.searchable)
					point.bindTooltip((feature.name ? feature.name : '' ).toString(), { 
						permanent: true, 
						direction: 'center',
						offset: [0, -10],
						className: this.options.pointStyle.className
					});
				centroids.push(point);
			}
            geoms.push(feature.geom);
        }
        
        this._pointLayer = L.layerGroup(centroids);
        this.makeOtherGeometries(geoms);
    },
    
    makeOtherGeometries: function(features) {
        // console.log("NamedLayer::makeOtherGeometries");
        // console.log(features);
    },
    
    bindTooltip: function(tooltip, options) {
        var className = this.options.nameClass || this.options.pointStyle.className || '';
        var opts = options || this.tooltipOptions;
        opts.className = className;
        
        if(this._pointLayer)
            this._pointLayer.eachLayer(function(layer) {
                layer.bindTooltip(tooltip, opts);
            });
    },
	    
    onAdd: function(map) {
        // console.log("NamedLayer::onAdd " + this.options.name);
        this._map = map;
        // console.log(this._map);
        // console.log(this);
        if(!(this.options.minZoom || this.options.maxZoom)) {
            this.show();
            this._visible = true;
        } else 
            this.showOrHide({target: map});
        
        if(this.options.minZoom || this.options.maxZoom) {
            map.on('zoomend', this.showOrHide, this);
        }
    },
    
    onRemove: function(map) {
        map.off('zoomend', this.showOrHide);
    },
    
    showOrHide: function(evt) {
		// console.log('showOrHide');
		// console.log(this);
        this._map = evt.target;
		// if(this.options && this.options.name && this.options.name=="Wharf Rat") {
			// console.log("minzoom: " + this.options.minZoom);
			// console.log("maxzoom: " + this.options.maxZoom);
			// console.log("checked: " + this.checked);
			// console.log("curzoom: " + this._map.getZoom());
		// }
        if(this._map.getZoom() <= this.options.maxZoom &&
            this._map.getZoom() >= this.options.minZoom &&
			this.checked !== false) {
				// console.log('show');
				// console.log(this.show);
                this.show();
        } else {
			// console.log('hide');
			// console.log(this.hide);
            this.hide();
        }
    },
    
    getLegendGroup: function() {
        var group = 'Misc';
        if(this.options && this.options.legendGroup)
            group = this.options.legendGroup;
        return group;
    },
    
    getBounds: function() {
        return this._bounds;
    }
});

L.namedLayer = function(features, options) {
    return new L.Layer.NamedLayer(features, options);
};