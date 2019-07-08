Selectable.Merchant = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.lid) {
        this._full = api("merchants", searchable.lid);
    }
};
Selectable.Merchant.prototype = $.extend({}, Selectable.DefaultPoint.prototype, {
    getTooltip: function(tooltippable) {
		return tooltippable.name;
	},
	
    _getPopupSubtitle: function(popupable) {
        var zone = (popupable && popupable.zone && popupable.zone.name ? popupable.zone.name : "?")
        return $('<h2></h2>')
            .append(zone)
            .append(' Merchant');
    },
	
	_getPopupContent: function(popupable) {
		var html = $('<div></div>')
            .addClass('melsmaps-merchant-popup');
		var tablist = '';
		var tabContent = '';
		
		
		var supraTabList = $('<ul></ul>')
            .appendTo(html);
		var firstc = true;
		var firstt = true;
		var firstst = true;
		// console.log(popupable.all_tabs);
		var c = 0;
		for(var i in popupable.all_tabs) {
            var supraTabName = i;
			var supraTabInv = popupable.all_tabs[i];
			// console.log(supraTabInv);
			var available = ($.isEmptyObject(supraTabInv) ? 'available' : 'unavailable');
			if(firstc && available == 'available') {
				var active = ' active';
				firstc = false;
			} else
				var active = '';
			var supraTabHtml = $('<div></div>')
                .addClass('tab-content tab-content-' + c + active)
                .appendTo(html);
            $('<li></li>')
                .addClass(available + active + ' tab-name-' + c)
                .html(supraTabName)
                .appendTo(supraTabList);
			if(supraTabInv) {
				if(supraTabInv["zero"]) {
					// ZERO TABS
					// console.log("Zero tabs in supra tab " + supraTabName);
                    // console.log(supraTabInv["zero"]);
					supraTabHtml.append(this._makeTabList(supraTabInv["zero"]));
				} else {
					// ONE OR TWO TABS
					console.log("One or two tabs in supra tab " + supraTabName);
					var tabList = $('<ul></ul>')
                        .appendTo(supraTabHtml);
					var tabs = $('<div></div>')
                        .appendTo(supraTabHtml);
					var t = 0;
					for(var tab in supraTabInv) {
						var tabInv = supraTabInv[tab];
						if(firstt) {
							var active = ' active';
							firstt = false;
						} else
							var active = '';
						var tabContent = $('<div></div>')
                            .addClass('tab-content tab-content-' + c + '-' + t + active)
                                .appendTo(tabs);
                        $('<li></li>')
                            .addClass('available' + active + ' tab-name-' + c + '-' + t)
                            .html(tab)
                            .appendTo(tabList);
						console.log(tabInv);
						if(!this._hasTabs(tabInv)) {
							tabContent.append(this._makeTabList(tabInv));
						} else {
							console.log("Found subtabs for " + supraTabName + " " + tab);
							var subTabList = $('<ul></ul>')
                                .appendTo(tabContent);
							var subtabs = $('<div></div>')
                                .appendTo(tabContent);
							var st = 0;
							for(var subtab in tabInv) {
								console.log("Treating subtab " + subtab);
								var subTabInv = tabInv[subtab];
								console.log(subTabInv);
								if(firstst) {
									var active = ' active';
									firstst = false;
								} else
									var active = '';
								var subTabContent = $('<div></div>')
                                    .addClass('tab-content tab-content-' + c + '-' + t + '-' + st + active)
                                    .appendTo(subtabs);
                                $('<li></li>')
                                    .addClass('available' + active + ' tab-name-' + c + '-' + t + '-' + st)
                                    .html(subtab)
                                    .appendTo(subTabList);
								subTabContent.append(this._makeTabList(subTabInv));
								st++;
							}
						}
						t++;
					}
				}
			}
			++c;
		}
		
		return html;
	},
	
	// _makeTab(json) {
		// var tabList = '<ul>';
		// var tabs = '<div>';
		// return {
			// tablist: tabList + '</ul>',
			// tabs: tabs + '</div>'
		// };
	// },
	
	
	_makeTabList: function(list) {
        console.log(list);
		var html = $('<table></table>');
		for(var i in list) {
            var tr = $('<tr></tr>')
                .appendTo(html);
			var row = list[i];
			var good = row.good;
			var price = row.price;
			console.log(row);
			
            var td = $('<td></td>')
                .append(Selectable.getItemTooltippedImage(good))
                .appendTo(tr);
            $('<td></td>')
                .html(good.name)
                .appendTo(tr);
			var priceTd = $('<td></td>')
                .appendTo(tr);
            var priceUl = $('<ul></ul>')
                .appendTo(priceTd);
			var iconTd = $('<td></td>')
                .appendTo(tr);
            var iconUl = $('<ul></ul>')
                .appendTo(iconTd);
			var nameTd = $('<td></td>')
                .appendTo(tr);
            var nameUl = $('<ul></ul>')
                .appendTo(nameTd);
			for(var i in price) {
				var p = price[i];
				// console.log(p);
				$('<li></li>')
                    .html(p.price.toLocaleString('en'))
                    .appendTo(priceUl);
				$('<li><img src="' + p.currency.icon + '" title="' + p.currency.name + '" alt="Currency icon" width="32" height="32" /></li>')
                    .appendTo(iconUl);
				$('<li></li>')
                    .html((p.currency.name ? p.currency.name : ''))
                    .appendTo(nameUl);
			}
			
			if(row && row.requirement) {
                $('<td></td>')
                    .append(row.requirement.getDiv())
                    .appendTo(tr);
			}
		}
		return html;
	}
});
Selectable.Merchant.Source = {
    getLine: function(merchant) {
        merchant.iconSize = 24;
        var img = merchant.category.getGoldIcon();
        var a = $('<a></a>')
            .html(merchant.name + ' (' + merchant.zone.name + ')');
        var li = $('<li></li>')
            .addClass('melsmaps-item-source-link')
            .append(img)
            .append(a)
            .attr('title', 'Click to pan to the merchant');
        li.data('selectable', Selectable.getFull(merchant));
        return li;
    }
};