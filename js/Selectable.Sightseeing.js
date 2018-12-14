Selectable.Sightseeing = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.real_name) {
        this._full = api("vistas", searchable.real_name);
    }
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
    }
});