Selectable.Merchant = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.lid) {
        this._full = api("merchants", searchable.lid);
    }
};
Selectable.Merchant.prototype = $.extend({}, Selectable.DefaultPoint.prototype, {
    _addToMap: function(group) {
        var that = this;
        return this._full.then(function(full) {
            var point = L.namedPointLayer([full], {
                name: full.name, 
                minZoom: 7,
                maxZoom: 10,
                inLegend: true,
                legendGroup: group,
                pointStyle: full.category.getPointStyle(),
                nameClass: 'melsmaps-tooltip',
                searchable: {}
            });
            // console.log(that.getTooltip(full));
            point.bindTooltip(that.getTooltip(full), {
                permanent: true,
                className: 'melsmaps-tooltip',
                direction: 'right',
                offset: [5, 0]
            });
            point.bindPopup(that.getPopup(full));
            point.addTo(melsmap);
            return point; 
        });

	},
    
    getTooltip: function(tooltippable) {
        // console.log("get tooltip");
		return tooltippable.name;
	},
	
    _getPopupSubtitle: function(popupable) {
        return $('<h2></h2>')
            .append(popupable && popupable.zone ? popupable.zone : '?')
            .append(' Merchant');
    },
    
    _getItemLi: function(item, hq, n) {
        return $('<li></li>')
            .html(Selectable.getItemImageNameHqNumberBlock(item, hq, n));
    },
    _getItemGoodOrPrice: function(item) {
        var html = $('<td></td>');
        var ul = $('<ul></ul>').appendTo(html);
        var list = item.goods || item.items;
        for(var i in list) {
            item = list[i];
            ul.append(this._getItemLi(item.item, item.hq, item.n));
        }
        return html;
    },
    
    _getItemGood: function(good) {
        return this._getItemGoodOrPrice(good);
    },
    _getVentureGood: function(good) {
        var html = $('<td></td>');
        var immaterial = {
            name: good.item.name,
            icon: good.item.licon
        };
        $('<li></li>')
            .html(Selectable.getImmaterialImageNameNumberBlock(immaterial, good.venture))
            .appendTo(html);
        return html;
    },
    _getActionGood: function(good) {
        var html = $('<td class="melsmaps-item-name-hq-n-block"></td>');
        $('<img alt="" width=32 height=32 />')
            .attr("src", good.icon)
            .appendTo(html);
        var rightDiv = $('<div></div>')
            .appendTo(html);
        $('<p></p>')
            .html(good.name)
            .appendTo(rightDiv);
        $('<p></p>')
            .html(good.effect)
            .appendTo(rightDiv);
        $('<p></p>')
            .html('Duration: ' + good.duration + 'h')
            .appendTo(rightDiv);
        return html;
    },
    
    _getGood: function(good) {
        switch(good.type) {
            case "Items":
                return this._getItemGood(good);
            case "Venture":
                return this._getVentureGood(good);
            case "Action":
                return this._getActionGood(good);
            default:
                console.error("Unknown good type?");
                console.error(good);
        }
    },
    
    _getGilPrice: function(price) {
        var html = $('<td>' + price.n_gil.toLocaleString('en-US') + ' <img src="' + price.gil.icon + '" alt="gil" width32= height=32 /></td>');
        return html;
    },
    _getItemsPrice: function(price) {
        return this._getItemGoodOrPrice(price);
    },
    _getTokenLi: function(token, n) {
        return $('<li></li>')
            .html(Selectable.getImmaterialImageNameNumberBlock(token, n));
    },
    _getTokensItemsPrice: function(price) {
        var html = $('<td></td>');
        var ul = $('<ul></ul>')
            .appendTo(html);
        ul.append(this._getTokenLi(price.token, price.token_n));
        for(var i in price.items) {
            var item = price.items[i];
            ul.append(this._getItemLi(item.item, item.hq, item.n));
        }
        return html;
    },
    _getTokensPrice: function(price) {
        var html = $('<td></td>');
        var ul = $('<ul></ul>')
            .appendTo(html);
        ul.append(this._getTokenLi(price.token, price.token_n));
        return html;
    },
    _getSealsPrice: function(price) {
        var base;
        switch(price.gc) {
            case 'Immortal Flames':
                base = 83100;
                break;
            case 'Maelstrom':
                base = 83000;
                break;
            case 'Order of the Twin Adder':
                base = 83050;
                break;
        }
        var rankImgSrc = ('000000' + (base + price.ranki)).slice(-6) + '.tex.png';
        var html = $('<td></td>');
        var ul = $('<ul></ul>')
            .appendTo(html);
        $('<li></li>')
            .append($('<img src="' + price.token.icon + '" width=32 height=32 alt="" />'))
            .append(price.seals.toLocaleString('en-US'))
            .appendTo(ul);
        $('<li></li>')
            .append($('<img src="icons/gcranks/' + rankImgSrc + '" alt="" width=32 height=32 />'))
            .append(price.rank)
            .appendTo(ul);
        return html;
    },
    _getFCCPrice: function(price) {
        var html = $('<td></td>');
        html.append(Selectable.getImmaterialImageNameNumberBlock(price.token, price.credits));
        return html;
    },
    
    _getPrice: function(price) {
        switch(price.type) {
            case "Gil":
                return this._getGilPrice(price);
            case "Items":
                return this._getItemsPrice(price);
            case "Tokens and Items":
                return this._getTokensItemsPrice(price);
            case "Tokens":
                return this._getTokensPrice(price);
            case "Seals":
                return this._getSealsPrice(price);
            case "FCC":
                return this._getFCCPrice(price);
            default:
                console.error("Unknown price type?");
                console.error(price);
        }
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
			var available = ($.isEmptyObject(supraTabInv) ? 'unavailable' : 'available');
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
					// console.log("One or two tabs in supra tab " + supraTabName);
					var tabList = $('<ul></ul>')
                        .appendTo(supraTabHtml);
					var tabs = $('<div></div>')
                        .appendTo(supraTabHtml);
					var t = 0;
                    // console.log(supraTabInv);
					for(var j in supraTabInv["one"]) {
						var tab = supraTabInv["one"][j];
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
                            .html(tab.name)
                            .appendTo(tabList);
						// console.log(tab);
						if(tab.sales) {
							tabContent.append(this._makeTabList(tab.sales));
						} else {
							// console.log("Found subtabs for " + supraTabName + " -> " + tab.name);
							var subTabList = $('<ul></ul>')
                                .appendTo(tabContent);
							var subtabs = $('<div></div>')
                                .appendTo(tabContent);
							var st = 0;
							for(var k in tab["subtabs"]) {
								var subTab = tab["subtabs"][k];
								// console.log("Treating subtab " + subTab["name"]);
								// console.log(subTab);
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
                                    .html(subTab.name)
                                    .appendTo(subTabList);
								subTabContent.append(this._makeTabList(subTab["sales"]));
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
	
	_makeTabList: function(list) {
		var html = $('<table></table>');
		for(var i in list) {
            var tr = $('<tr></tr>')
                .appendTo(html);
			var row = list[i];
			var good = row.good;
			var price = row.price;
			// console.log(row);
            
            tr.append(this._getGood(good));
            tr.append(this._getPrice(price));
			
			// if(row && row.requirement) {
                // $('<td></td>')
                    // .append(row.requirement.getDiv())
                    // .appendTo(tr);
			// }
		}
		return html;
	}
});
Selectable.Merchant.Source = {
    getLine: function(merchant) {
        merchant.iconSize = 24;
        var img = merchant.category.getGoldIcon();
        var a = $('<a></a>')
            .html(merchant.name + ' (' + merchant.zone_names + ')');
        var li = $('<li></li>')
            .addClass('melsmaps-item-source-link')
            .append(img)
            .append(a)
            .attr('title', 'Click to pan to the merchant');
        li.data('selectable', Selectable.getFull(merchant));
        return li;
    }
};