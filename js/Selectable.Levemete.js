Selectable.Levemete = function(searchable) {
    this._searchable = searchable;
	if(searchable && searchable.lid) {
		var that = this;
		this._full = api("levemetes", searchable.lid);
	}
};
Selectable.Levemete.prototype = $.extend({}, Selectable.DefaultPoint.prototype, {
	_getPopupSubtitle: function(popupable) {
        return $("<h2>" + (popupable.settlement ? popupable.settlement : '?' ) + " (lvl " + (popupable.min_lvl ? popupable.min_lvl : '?') + "-" + (popupable.max_lvl ? popupable.max_lvl : '?') + ")</h2>");
    },
	_getPopupContent: function(popupable) {
		var html = $('<table></table>')
            .addClass('melsmaps-levemete');
		if(popupable && popupable.leves) {
			for(var i in popupable.leves) {
                var lev = popupable.leves[i];
				var leve = Selectable.getFull(lev);
				// console.log(leve);
                var tr = $('<tr></tr>')
                    .addClass('melsmaps-is-a-leve-tooltip')
                    .attr('data-melsmaps-tooltip', Selectable.getLeveTooltip(lev).prop('outerHTML'))
                    .appendTo(html);
                $('<td></td>')
                    .append(leve.getIcon(lev))
                    .appendTo(tr);
                $('<td>' + lev.name + '</td>')
                    .appendTo(tr);
                $('<td>(lvl ' + lev.lvl + ')</td>')
                    .appendTo(tr);
			}
		}
		return html;
	}
});