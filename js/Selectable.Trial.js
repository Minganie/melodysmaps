Selectable.Trial = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.real_name)
        this._full = api("duties", searchable.real_name);
};
Selectable.Trial.prototype = $.extend({}, Selectable.HasPopup.prototype, {
    onSelect: function() {
        this._full.then(function(full) {
			melsmap.flyToBounds(full.bounds);
			melsmap.once('zoomend', function() {
				var lyr = melsmap.getDutyLayer(full.name);
				lyr.openPopup();
			});
		});
    },
    _getPopupSubtitle: function(popupable) {
		return $('<h2></h2>')
            .html(popupable.category.getName());
	},
	_getPopupContent: function(popupable) {
        var html = $('<ul></ul>')
            .addClass('duty trial');
		var rm = null;
        var hm = null;
        var xm = null;
        var duties = (popupable && popupable.modes ? popupable.modes : null);
        if(duties) {
            for(var mode in duties) {
                var duty = duties[mode];
                var boss = duty.bosses[0];
                
                if(boss && boss.boss) {
                    switch(mode) {
                        case 'Regular':
                            var boss_li = $('<li></li>')
                                .addClass('mode');
                            rm = boss_li;
                            break;
                        case 'Hard':
                            var boss_li = $('<li></li>')
                                .addClass('mode');
                            hm = boss_li;
                            break;
                        case 'Extreme':
                            var boss_li = $('<li></li>')
                                .addClass('mode');
                            xm = boss_li;
                            break;
                        default:
                            console.error("Can't find which trial mode '" + mode + "' is");
                    }
                    var h2 = $('<h2></h2>')
                        .appendTo(boss_li);
                    $('<img />')
                        .attr({
                            src: 'http://www.melodysmaps.com/icons/map/boss.png',
                            width: 24,
                            height: 24,
                            alt: ''
                        })
                        .appendTo(h2);
                    $('<span></span>')
                        .html(boss.boss + ' (' + mode + ') (level ' + duty.level + ')')
                        .appendTo(h2);
                    var boss_ul = $('<ul></ul>')
                        .appendTo(boss_li);
                    
                    if(boss.tokens) {
                        for(var i in boss.tokens) {
                            var token = boss.tokens[i];
                            var li = $('<li></li>');
                            $('<span></span>')
                                .html(token.qty + ' ')
                                .appendTo(li);
                            $('<img />')
                                .attr({
                                    src: token.token.icon,
                                    width: 24,
                                    height: 24,
                                    alt: token.token.name + ' icon'
                                })
                                .appendTo(li);
                            $('<span></span>')
                                .html(token.token.name)
                                .appendTo(li);
                            
                            boss_ul.append(li);
                        }
                    }
                    
                    if(boss.items) {
                        for(var j in boss.items) {
                            var item = boss.items[j];
							if(item){
                                boss_ul.append(Selectable.getItemTooltippedLi(item));
                            }
                        }
                    }
                }
            }
        }
        return html.append(rm).append(hm).append(xm);
	}
});
Selectable.Duty = {
    Source: {
        getLine: function(duty) {
            duty.category.iconSize = 24;
            var img = duty.category.getGoldIcon();
            var a = $('<a></a>')
                .html(duty.name + ' (' + duty.mode + ')' + ' (lvl ' + duty.level + ')');
            var li = $('<li></li>')
                .append(img)
                .append(a)
                .addClass('melsmaps-item-source-link')
                .attr('title', 'Click to pan to the duty');
            li.data('selectable', Selectable.getFull(duty));
            return li;
        }
    }
};