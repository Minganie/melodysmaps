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
		var html = $('<div class="melsmaps-merchant-popup"></div>');
		var tabList = $('<ul></ul>')
            .appendTo(html);
		var first = true;
		var c = 0;
		if(popupable && popupable.leves) {
			for(var cat in popupable.leves) {
                var leves = popupable.leves[cat];
				
				// MAKE TAB
				var available = ($.isEmptyObject(leves) ? 'unavailable' : 'available');
				if(first && available == 'available') {
					var active = ' active';
					first = false;
				} else
					var active = '';
				var tabHtml = $('<div></div>')
					.addClass('tab-content tab-content-' + c + active)
					.appendTo(html);
				$('<li></li>')
					.addClass(available + active + ' tab-name-' + c)
					.html(cat)
					.appendTo(tabList);
				var table = $('<table></table>')
					.addClass('melsmaps-levemete')
					.appendTo(tabHtml);
					
				// FILL TAB
				for(var i in leves) {
					var full = leves[i];
					var leve = Selectable.getFull(full);
					// console.log(leve);
					var tr = $('<tr></tr>')
						.addClass('melsmaps-is-a-leve-tooltip')
						.attr('data-melsmaps-tooltip', Selectable.getLeveTooltip(full).prop('outerHTML'))
						.appendTo(table);
					$('<td></td>')
						.append(leve.getIcon(full))
						.appendTo(tr);
					$('<td>' + full.name + '</td>')
						.appendTo(tr);
					$('<td>(lvl ' + full.lvl + ')</td>')
						.appendTo(tr);
				}
				c++;
			}
		}
		return html;
	}
});