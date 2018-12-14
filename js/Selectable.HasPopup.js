Selectable.HasPopup = function(searchable) {
    this._searchable = searchable;
};
Selectable.HasPopup.prototype = $.extend({}, Selectable.prototype, {
    getPopup: function(popupable) {
        var html = $('<div></div>');
        html.append(this._getPopupHeader(popupable));
        var req = this._getPopupRequirement(popupable);
        if(req)
            html.append(req);
        var div = $('<div></div>');
        div.append(this._getPopupContent(popupable));
        html.append(div);
        return html[0];
    },
    _getPopupHeader: function(popupable) {
        var hdiv = $('<div></div>');
        var img = popupable.category.getGoldIcon();
        hdiv.append(img);
        var span = $('<span></span>');
        var h1 = $('<h1></h1>').html(popupable.name);
        var sep = $('<div></div>').addClass('leaflet-control-layers-separator');
        var subtitle = this._getPopupSubtitle(popupable);
        span.append(h1)
            .append(sep)
            .append(subtitle);
        hdiv.append(span);
        
        return hdiv;
    },
    _getPopupSubtitle: function(popupable) {
        var subtitle = $('<h2></h2>').html(popupable.category.getName() + " node (lvl " + (popupable && popupable.level ? popupable.level : "?") + ")");
        return subtitle;
    },
    _getPopupRequirement: function(popupable) {
        var requirement = (popupable && popupable.requirement) ? popupable.requirement : null;
        var html = null;
        if(requirement) {
            html = requirement.getDiv();
        }
        return html;
    }
});