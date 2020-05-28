Selectable.Sightseeing = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.real_name) {
        this._full = api("vistas", searchable.real_name);
    }
    var ss = this;
    $(map).on('tick', function(e, time) {
        ss._full.then(function(sightseeing) {
            var img = $(map).find('img.melsmaps-legend-image[alt="' + sightseeing.label + ' icon"]');
            if(ss.isSeeable(sightseeing, time)) {
                img.attr('src', 'icons/map/sightseeing_on.png');
            } else {
                img.attr('src', 'icons/map/sightseeing_off.png');
            }
        });
    });
}
Selectable.Sightseeing.prototype = $.extend({}, Selectable.DefaultPoint.prototype, {
    onSelect: function() {
        $('#vista').vistaBox("instance").setVista(this);
    },
    
    showOnMap: function(group) {
        var that = this;
        this._full.then(function(full) {
            that._addToMap(group).then(function(lyr) {
                melsmap.once('zoomend', function() {
                    lyr.openPopup();
                });
            });
            melsmap.flyToBounds(full.bounds);
        });
    },
    
    _getPopupHeader: function(popupable) {
        var html = $('<div></div>');
        popupable.category.getGoldIcon()
            .appendTo(html);
        var span = $('<span></span>')
            .appendTo(html);
        $('<h1></h1>')
            .html('Vista #' + popupable.name)
            .appendTo(span);
        $('<div></div>')
            .addClass('leaflet-control-layers-separator')
            .appendTo(span);
        this._getPopupSubtitle(popupable)
            .appendTo(span);
        
        return html;
    },
    
    _getPopupSubtitle: function(popupable) {
        return $('<h2></h2>')
            .html('Sightseeing entry in ' + popupable.zone);
    },
    
    _getPopupContent: function(popupable) {
        var html = $('<div></div>');
        var plug = $('#vista').vistaBox('instance');
        html.append(plug._formatTime(popupable));
        html.append(plug._formatWeather(popupable));
        html.append(plug._formatEmote(popupable));
        return html;
    },
    
    isSeeable: function(sightseeing, time) {
        var zone = sightseeing.zone;
        if(zone.indexOf('Gridania') !== -1)
            zone = 'Gridania';
        var sky = gt.skywatcher.getViewModel()[zone];
        
        // time
        var tok = true;
        if(sightseeing.debut && sightseeing.fin) {
            var currentHour = parseInt(time.substring(0,2), 10);
            var debut = parseInt(sightseeing.debut.substring(0,2), 10);
            var fin = parseInt(sightseeing.fin.substring(0,2), 10);
            if(fin > debut) {
                tok = currentHour >= debut && currentHour < fin;
            } else {
                tok = currentHour >= debut || currentHour < fin;
            }
        }
        
        // weather
        var wok = true;
        if(sightseeing.weather) {
            wok = sightseeing.weather.includes(sky[1]);
        }
        
        return tok && wok;
    }
});