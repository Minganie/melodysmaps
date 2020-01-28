Category = function(data) {
    var iconSize = 30;
    
    return {
        classy: 'Category',
        name: data.pretty_name,
        
        getRedIcon: function() {
            return img = $('<img />')
                .attr('src', data.red_icon)
                .attr('alt', data.pretty_name + ' icon')
                .attr('width', (data.iconSize ? data.iconSize : iconSize))
                .attr('height', (data.iconSize ? data.iconSize : iconSize));
        },
        
        getGoldIcon: function() {
            return img = $('<img />')
                .attr('src', data.gold_icon)
                .attr('alt', data.pretty_name + ' icon')
                .attr('width', (data.iconSize ? data.iconSize : iconSize))
                .attr('height', (data.iconSize ? data.iconSize : iconSize));
        },
        
        // getSourceIcon: function() {
            // return '<img src="' + this.getSourceIconUrl() + '" class="" width=' + iconSize + ' height=' + iconSize + ' />';
        // },
        
        // getSourceIconUrl: function() {
            // return 'http://melodysmaps.com/' + data.gold_icon;
        // },
        
        getTooltip: function() {
            return data.tooltip;
        },
        
        getName: function() {
            return data.name;
        },
        
        getPolygonStyle: function() {
            return {
                fillColor: data.fill,
                fillOpacity: 0.5,
                color: data.border,
                opacity: 1,
                weight: 1
            };
        },
		
		getPointStyle: function() {
            return {
                icon: L.icon({
					iconUrl: data.map_icon,
					iconSize: [32, 32]
				})
            };
        }
    };
};