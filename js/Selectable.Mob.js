Selectable.Mob = function(searchable) {
    this._searchable = searchable;
};
Selectable.Mob.prototype = $.extend({}, Selectable.DefaultPolygon.prototype, {
    _getNameplateIconUrl: function(mob) {
        return 'http://melodysmaps.com/icons/monster/' + 
            (mob.agressive ? 'agressive/' : 'passive/') + 
            (mob.elite ? 'elite.png' : 'normal.png');
    },
    
    _getNameplateIconAlt: function(mob) {
        return (mob.agressive ? 'Agressive ' : 'Passive ') 
            + (mob.elite ? 'elite' : 'normal');
    },
    
    _getNameplate: function(mob) {
        var img = $('<img />')
            .attr('src', this._getNameplateIconUrl(mob))
            .attr('width', 18)
            .attr('height', 18);
        var title = 'Mob is ' + this._getNameplateIconAlt(mob) + ' (lvl ' + this._formatLevel(mob) + ')';
        return $('<span></span>')
            .append(img)
            .append(mob.name)
            .attr('title', title);
    }
});