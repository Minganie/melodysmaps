Selectable.Leve = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.name) {
        this._full = api("leves", searchable.name);
    }
}
Selectable.Leve.prototype = $.extend({}, Selectable.prototype, {
    onSelect: function() {
        $('#leve').leveBox('instance').setLeve(this);
    },
    getIcon: function(lev) {
        var extra = null;
        var part;
        if(lev.gc && lev.gc != '') {
            switch(this._resolved.gc) {
                case 'Maelstrom':
                    part = 'maelstrom';
                    break;
                case 'Order of the Twin Adder':
                    part = 'adder';
                    break;
                case 'Immortal Flames':
                    part = 'flames';
                    break;
            }
            extra = $('<img src="http://melodysmaps.com/icons/leves/' + part + '.png" alt="Grand company icon" width=28 height=36 />');
        }
        if(lev.type == 'Battlecraft' || lev.job == 'Disciple of War or Magic')
            part = 'battlecraft';
        else if(lev.type == 'Tradecraft' || lev.type == 'Fieldcraft')
            part = lev.job.toLowerCase();
        
        var def_img = $('<img src="http://melodysmaps.com/icons/leves/' + part + '.png" alt="' + lev.job + ' leve icon" title="' + lev.job + ' leve" width=24 height=30 />');
        var span = $('<span></span>')
            .append(extra)
            .append(def_img);
        return span;
    }
});
Selectable.Leve.Source = {
    getLine: function(leve) {
        leve.category.iconSize = 24;
        var img = leve.category.getGoldIcon();
        var a = $('<a></a>')
            .html(leve.name + ' (lvl ' + leve.lvl + ')');
        var li = $('<li></li>')
            .append(img)
            .append(a)
            .addClass('melsmaps-item-source-link')
            .attr('title', 'Click to view the leve');
        li.data('selectable', Selectable.getFull(leve));
        return li;
    }
};

Selectable.Leve.Tooltip = {
    get: function(leve) {
        if(leve.model=='Benevolence')
            return new Selectable.Leve.Tooltip.Benevolence(leve);
        else if(leve.model=='Candor')
            return new Selectable.Leve.Tooltip.Candor(leve);
        else if(leve.model=='Charity')
            return new Selectable.Leve.Tooltip.Charity(leve);
        else if(leve.model=='Concord')
            return new Selectable.Leve.Tooltip.Concord(leve);
        else if(leve.model=='Confidence')
            return new Selectable.Leve.Tooltip.Confidence(leve);
        else if(leve.model=='Constancy')
            return new Selectable.Leve.Tooltip.Constancy(leve);
        else if(leve.model=='Diligence')
            return new Selectable.Leve.Tooltip.Diligence(leve);
        else if(leve.model=='Equity')
            return new Selectable.Leve.Tooltip.Equity(leve);
        else if(leve.model=='Ingenuity')
            return new Selectable.Leve.Tooltip.Ingenuity(leve);
        else if(leve.model=='Justice')
            return new Selectable.Leve.Tooltip.Justice(leve);
        else if(leve.model=='Munificence')
            return new Selectable.Leve.Tooltip.Munificence(leve);
        else if(leve.model=='Piety')
            return new Selectable.Leve.Tooltip.Piety(leve);
        else if(leve.model=='Promptitude')
            return new Selectable.Leve.Tooltip.Promptitude(leve);
        else if(leve.model=='Prudence')
            return new Selectable.Leve.Tooltip.Prudence(leve);
        else if(leve.model=='Resolve')
            return new Selectable.Leve.Tooltip.Resolve(leve);
        else if(leve.model=='Sincerity')
            return new Selectable.Leve.Tooltip.Sincerity(leve);
        else if(leve.model=='Sympathy')
            return new Selectable.Leve.Tooltip.Sympathy(leve);
        else if(leve.model=='Temperance')
            return new Selectable.Leve.Tooltip.Temperance(leve);
        else if(leve.model=='Tenacity')
            return new Selectable.Leve.Tooltip.Tenacity(leve);
        else if(leve.model=='Unity')
            return new Selectable.Leve.Tooltip.Unity(leve);
        else if(leve.model=='Valor')
            return new Selectable.Leve.Tooltip.Valor(leve);
        else if(leve.model=='Veracity')
            return new Selectable.Leve.Tooltip.Veracity(leve);
        else if(leve.model=='Wisdom')
            return new Selectable.Leve.Tooltip.Wisdom(leve);
        else {
            console.error("Can't find the type of leve tooltip to make for ");
            console.error(leve);
        }
    }
};

Selectable.Leve.Tooltip.Leve = function(leve, className) {
    this._className = className || 'Leve';
    this._helperId = leve.name || 'no idea';
	this.leve = leve;
}
Selectable.Leve.Tooltip.Leve.prototype = {
    _getName: function() {
        return $('<h1></h1>')
            .html(this.leve.name);
    },
    _getLevemete: function() {
        var html = $('<div></div>')
            .addClass('melsmaps-leve-tooltip-section');
        $('<h2></h2>')
            .html('<img src="http://melodysmaps.com/icons/leves/levemete.png" width=32 height=32 alt="" />Levemete')
            .appendTo(html);
        $('<p></p>')
            .html('<a class="melsmaps-levemete-link" data-melsmaps-levemete="' + this.leve.levemete_name + '">' + this.leve.levemete_name + '</a>')
            .appendTo(html);
        return html;
    },
    _getCurrencies: function() {
        var html = $('<div></div>')
            .addClass('melsmaps-leve-tooltip-section melsmaps-leve-tooltip-currencies');
        $('<h2></h2>')
            .html('<img src="http://melodysmaps.com/icons/leves/currency_reward.png" width=32 height=32 alt="" />Currency rewards')
            .appendTo(html);
        html.append(this.leve.xp && this.leve.xp>0 ? '<span>' + this.leve.xp + '<img src="http://melodysmaps.com/icons/xp.png" alt="" width=24 height=24 /></span>' : '?');
        html.append(this.leve.gil && this.leve.gil>0 ? '<span>' + this.leve.gil + '<img src="http://melodysmaps.com/icons/gil.png" alt="" width=24 height=24 /></span>' : '');
        html.append(this.leve.seals && this.leve.seals>0 ? '<span>' + this.leve.seals + '<img src="http://melodysmaps.com/icons/flameseal.png" alt="" width=24 height=24 /></span>' : '');
        return html;
    },
    _getNumberedEnemyList: function() {
        var list = $('<ul></ul>');
        for(var i = 0; i < this.leve.mobs.length; i++) {
            var mob = this.leve.mobs[i];
            $('<li></li>')
                .html((mob.n ? mob.n + '&nbsp;' : '') + mob.mob)
                .appendTo(list);
        }
        return list;
    },
    
    _getObjectives: function() {
        return $('<span></span>');
    },
    _getWanted: function() {
        var html = null;
        if(this.leve.wanted){
            html = $('<div></div>')
                .addClass('melsmaps-leve-tooltip-section');
            $('<h2></h2>')
                .html('<img src="http://melodysmaps.com/icons/leves/wanted_target.png" width=32 height=32 alt="" />Wanted target')
                .appendTo(html);
            $('<p></p>')
                .html(this.leve.wanted)
                .appendTo(html);
        }
        return html;
    },
    _getRewards: function() {
        var html = $('<div></div>');
        if(this.leve && this.leve.rewards)
            for(var i = 0; i < this.leve.rewards.length; i++) {
                var reward = this.leve.rewards[i];
                if(reward && reward.n && reward.item) {
                    var span = $('<span></span>')
                        .append(Selectable.getItemTooltippedImage(reward.item));
                    html.append(reward.n + ' x ')
                        .append(span);
                }
            }
        return html;
    },
    _getHostiles: function() {
        var html = $('<div></div>');
        if(this.leve.mobs && this.leve.mobs[0] && this.leve.mobs[0].mob) {
            $('<p></p>')
                .html('You may face the following hostiles:')
                .appendTo(html);
            html.append(this._getNumberedEnemyList());
        }
        return html;
    },
	getTooltip: function() {
		var html = $('<div></div>')
            .addClass('melsmaps-leve-tooltip-container');
        var wrapper_div = $('<div></div>')
            .addClass('melsmaps-leve-tooltip-wrapper')
            .appendTo(html);
        wrapper_div.append(this._getName());
        var main_div = $('<div></div>')
            .addClass('melsmaps-leve-tooltip-main')
            .appendTo(wrapper_div);
        main_div.append(this._getCard());
        var main_wrapper_div = $('<div></div>')
            .addClass('melsmaps-leve-tooltip-main-wrapper')
            .appendTo(main_div);
        main_wrapper_div.append(this._getLevemete());
        main_wrapper_div.append(this._getCurrencies());
        var section_div = $('<div></div>')
            .addClass('melsmaps-leve-tooltip-section')
            .appendTo(main_wrapper_div);
        var img = $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/leves/objectives.png',
                width: 32,
                height: 32,
                alt: ''
            });
        var h2 = $('<h2></h2>')
            .append(img)
            .html('Objectives');
        section_div.append(h2)
            .append(this._getObjectives());
        main_wrapper_div.append(this._getWanted());
        var reward_div = $('<div></div>')
            .addClass('melsmaps-leve-tooltip-section melsmaps-leve-tooltip-rewards')
            .appendTo(wrapper_div);
        $('<h2></h2>')
            .html('<img src="http://melodysmaps.com/icons/leves/item_rewards.png" width=32 height=32 alt="" />Item rewards')
            .appendTo(reward_div);
        reward_div.append(this._getRewards());
		return html;
	}
}

//"Benevolence"
Selectable.Leve.Tooltip.Benevolence = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Benevolence');
}
Selectable.Leve.Tooltip.Benevolence.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080040.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.first_item) {
            var html = $('<div></div>');
            $('<p></p>')
                .html('With a possible evaluation bonus, gather these items at 4 locations:')
                .appendTo(html);
            var list = $('<ul></ul>')
                .appendTo(html);
            $('<li></li>')
                .html(this.leve.first_item)
                .appendTo(list);
            if(this.leve.second_item) {
                $('<li></li>')
                    .html(this.leve.second_item)
                    .appendTo(list);
            }
            if(this.leve.third_item) {
                $('<li></li>')
                    .html(this.leve.third_item)
                    .appendTo(list);
            }
            if(this.leve.fourth_item) {
                $('<li></li>')
                    .html(this.leve.fourth_item)
                    .appendTo(list);
            }
            return html;
        } else
            return $('<p></p>')
                .html('Gather items at four locations, with a possible evaluation bonus (details unknown).');
    }
});
//"Candor"
Selectable.Leve.Tooltip.Candor = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Candor');
}
Selectable.Leve.Tooltip.Candor.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080030.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.item && this.leve.max_n_nodes) {
            return $('<p></p>')
                .html('Gather a minimum of ' + this.leve.n + '&nbsp;' + this.leve.item + ' in ' + this.leve.max_n_nodes + '&nbsp;locations.');
        } else
            return $('<p></p>')
                .html('Gather a minimum of x&nbsp;items in n&nbsp;locations (details unknown).');
    }
});
//"Charity"
Selectable.Leve.Tooltip.Charity = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Charity');
}
Selectable.Leve.Tooltip.Charity.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080041.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.real_item) {
            var p = $('<p></p>')
                .html('Craft ' + this.leve.n + '&nbsp;');
            var span = $('<span></span>')
                .append(Selectable.getItemTooltippedImage(this.leve.real_item))
                .appendTo(p);
            p.append(', with extra deliveries allowed.');
            return p;
        } else
            return $('<p></p>')
                .html('Craft n&nbsp;items, with extra deliveries allowed (details unknown).');
    }
});
//"Concord"
Selectable.Leve.Tooltip.Concord = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Concord');
}
Selectable.Leve.Tooltip.Concord.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080057.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.real_item) {
            var span = $('<span></span>')
                .append(Selectable.getItemTooltippedImage(this.leve.real_item));
            return $('<p></p>')
                .append('Deliver ' + this.leve.n + '&nbsp;')
                .append(span);
        } else
            return $('<p></p>')
                .html('Deliver n&nbsp;fish (details unknown).');
    }
});
//"Confidence"
Selectable.Leve.Tooltip.Confidence = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Confidence');
}
Selectable.Leve.Tooltip.Confidence.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080055.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.item) {
            var html = $('<p></p>')
                .html('Interact with ' + this.leve.n + '&nbsp;' + this.leve.item + '.');
            html.append(this._getHostiles());
            return html;
        } else
            return $('<p></p>')
                .html('Interact with n&nbsp;items (details unknown).');
    }
});
//"Constancy"
Selectable.Leve.Tooltip.Constancy = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Constancy');
}
Selectable.Leve.Tooltip.Constancy.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080033.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.real_item) {
            var span = $('<span></span>')
                .append(Selectable.getItemTooltippedImage(this.leve.real_item));
            return $('<p></p>')
                .append('Craft ' + this.leve.n + '&nbsp;')
                .append(span)
                .append(', with a nearby turn-in.');
        } else
            return $('<p></p>')
                .html('Craft n&nbsp;items, with a nearby turn-in (details unknown).');
    }
});
//"Diligence"
Selectable.Leve.Tooltip.Diligence = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Diligence');
}
Selectable.Leve.Tooltip.Diligence.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080025.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.item && this.leve.mob) {
            var html = $('<p></p>')
                .html('Gather ' + this.leve.n + '&nbsp;' + this.leve.item + ' from ' + this.leve.mob);
            html.append(this._getHostiles());
            return html;
        } else
            return $('<p></p>')
                .html('Gather n&nbsp;items from enemies (details unknown).');
    }
});
//"Equity"
Selectable.Leve.Tooltip.Equity = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Equity');
}
Selectable.Leve.Tooltip.Equity.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080049.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve 
                && this.leve.item_mob 
                && this.leve.item 
                && this.leve.mobs  
                && this.leve.mobs[0] 
                && this.leve.mobs[0].mob
                && this.leve.n 
                && this.leve.target_mob) {
            var html = $('<div></div>');
            $('<p></p>')
                .html('Poke ' + this.leve.item_mob)
                .appendTo(html);
            $('<p></p>')
                .html('Kill those who respond')
                .appendTo(html);
            $('<p></p>')
                .html('Use the resulting ' + this.leve.item + ' on ' + this.leve.mobs[0].mob)
                .appendTo(html);
            $('<p></p>')
                .html('Eventually kill ' + this.leve.n + '&nbsp;' + this.leve.target_mob)
                .appendTo(html);
            html.append(this._getHostiles());
            return html;
        } else
            return $('<p>Poke enemies; if they respond, kill them and gather their item; use item on other enemy; if glamour is dispelled, kill actual target (details unknown).</p>');
    }
    //Gather items off mob, /poke, use item on mobs that respond, kill target
});
//"Ingenuity"
Selectable.Leve.Tooltip.Ingenuity = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Ingenuity');
}
Selectable.Leve.Tooltip.Ingenuity.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080034.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.real_item && this.leve.client) {
            // console.log(this.leve);
            var client = Selectable.getFull(this.leve.client);
            var p = $('<p></p>')
                .append('Craft ' + this.leve.n + '&nbsp;');
            var span = $('<span></span>')
                .append(Selectable.getItemTooltippedImage(this.leve.real_item))
                .appendTo(p);
            p.append(' and deliver ' + (this.leve.n > 1 ? 'them' : 'it') +' to ');
            var clientSpan = $('<span></span>')
                .append(Selectable.getNPCLink(this.leve.client))
                .appendTo(p);
            p.append('.');
            return p;
        } else
            return $('<p>Craft n&nbsp;items, deliver some distance away (details unknown).</p>');
    }
});
//"Justice"
Selectable.Leve.Tooltip.Justice = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Justice');
}
Selectable.Leve.Tooltip.Justice.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080024.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.item_mob && this.leve.item && this.leve.n && this.leve.target_mob) {
            var html = $('<div></div>');
            $('<p>Kill ' + this.leve.item_mob + ' for ' + this.leve.item + '</p>')
                .appendTo(html);
            $('<p>Use this bait at locations to lure and kill ' + this.leve.n + '&nbsp;' + this.leve.target_mob + '</p>')
                .appendTo(html);
            html.append(this._getHostiles());
            return html;
        } else {
            return $('<p>Kill enemies for a bait, then use it at locations to lure and kill n targets (details unknown).</p>');
        }
    }
});
//"Munificence"
Selectable.Leve.Tooltip.Munificence = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Munificence');
}
Selectable.Leve.Tooltip.Munificence.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080044.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.item) {
            return $('<p>Gather ' + this.leve.n + '&nbsp;' + this.leve.item + '.</p>');
        } else {
            return $('<p>Gather n&nbsp;items (details unknown).</p>');
        }
    }
});
//"Piety"
Selectable.Leve.Tooltip.Piety = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Piety');
}
Selectable.Leve.Tooltip.Piety.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080029.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.first_item) {
            var html = $('<div></div>');
            $('<p>With a possible evaluation bonus, gather these items at 8 locations:</p>')
                .appendTo(html);
            var ul = $('<ul></ul>')
                .appendTo(html);
            ul.append($('<li>' + this.leve.first_item + '</li>'));
            if(this.leve.second_item)
                ul.append($('<li>' + this.leve.second_item + '</li>'));
            if(this.leve.third_item)
                ul.append($('<li>' + this.leve.third_item + '</li>'));
            if(this.leve.fourth_item)
                ul.append($('<li>' + this.leve.fourth_item + '</li>'));
            return html;
        } else {
            return $('<p>Gather various items at 8&nbsp;locations, with an evaluation bonus (details unknown).</p>');
        }
    }
});
//"Promptitude"
Selectable.Leve.Tooltip.Promptitude = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Promptitude');
}
Selectable.Leve.Tooltip.Promptitude.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080036.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.mobs && this.leve.mobs[0] && this.leve.n) {
            var html = $('<div></div>');
            $('<p></p>')
                .html('In ' + this.leve.n + '&nbsp;minutes, kill at least:')
                .appendTo(html);
            html.append(this._getNumberedEnemyList());
            return html;
        } else {
            return $('<p>Kill at least n&nbsp;enemies in x&nbsp;time (details unknown).</p>');
        }
    }
});
//"Prudence"
Selectable.Leve.Tooltip.Prudence = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Prudence');
}
Selectable.Leve.Tooltip.Prudence.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080037.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.mobs && this.leve.mobs[0] && this.leve.mobs[0].mob) {
            var html = $('<div></div>');
            $('<p>Kill ' + this.leve.mobs[0].mob + '; they will summon reinforcements.</p>')
                .appendTo(html);
            html.append(this._getHostiles());
            return html;
        } else {
            return $('<p>Kill an enemy; they will summon reinforcements (details unknown).</p>');
        }
    }
});
//"Resolve"
Selectable.Leve.Tooltip.Resolve = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Resolve');
}
Selectable.Leve.Tooltip.Resolve.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080038.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.target_mob) {
            var html = $('<div></div>');
            $('<p>Weaken and then soothe ' + this.leve.n + '&nbsp;' + this.leve.target_mob + '.</p>')
                .appendTo(html);
            html.append(this._getHostiles());
            return html;
        } else {
            return $('<p>Weaken and then soothe n&nbsp;enemies (details unknown).</p>');
        }
    }
});
//"Sincerity"
Selectable.Leve.Tooltip.Sincerity = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Sincerity');
}
Selectable.Leve.Tooltip.Sincerity.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080045.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.real_item) {
            var html = $('<p>Deliver ' + this.leve.n + '&nbsp;');
            var span = $('<span></span>')
                .append(Selectable.getItemTooltippedImage(this.leve.real_item))
                .appendTo(html);
            html.append(', with extra deliveries allowed.');
            return html;
        } else {
            return $('<p>Deliver n&nbsp;fishes, with extra deliveries allowed (details unknown).</p>');
        }
    }
});
//"Sympathy"
Selectable.Leve.Tooltip.Sympathy = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Sympathy');
}
Selectable.Leve.Tooltip.Sympathy.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080056.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.mob) {
            var html = $('<div></div>');
            $('<p>Beckon ' + this.leve.mob + ' from point A to point B.</p>')
                .appendTo(html);
            html.append(this._getHostiles());
            return html;
        } else {
            return '<p>Beckon a NPC from point A to point B (details unknown).</p>';
        }
    }
});
//"Temperance"
Selectable.Leve.Tooltip.Temperance = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Temperance');
}
Selectable.Leve.Tooltip.Temperance.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080026.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n) {
            var html = $('<div></div>');
            $('<p>Kill enemies at ' + this.leve.n + ' locations.</p>')
                .appendTo(html);
            html.append(this._getHostiles());
        } else {
            return $('<p>Kill enemies at n locations (details unknown).</p>');
        }
    }
});
//"Tenacity"
Selectable.Leve.Tooltip.Tenacity = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Tenacity');
}
Selectable.Leve.Tooltip.Tenacity.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080022.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.mobs && this.leve.mobs[0] && this.leve.mobs[0].mob) {
            var html = $('<div></div>');
            $('<p>With the last one attempting to flee and summon reinforcements, kill the following enemies:</p>')
                .appendTo(html)
            html.append(this._getNumberedEnemyList());
            return html;
        } else {
            return $('<p>Kill n enemies; the last one will attempt to flee and summon reinforcements (details unknown).</p>');
        }
    }
});
//"Unity"
Selectable.Leve.Tooltip.Unity = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Unity');
}
Selectable.Leve.Tooltip.Unity.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080051.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.mob && this.leve.mobs && this.leve.mobs[0] && this.leve.mobs[0].n) {
            var html = $('<div></div>');
            $('<p>Defend ' + this.leve.n + '&nbsp;' + this.leve.mob + ' against :</p>')
                .appendTo(html);
            html.append(this._getNumberedEnemyList());
        } else {
            return '<p>Defend n&nbsp;items against x&nbsp;enemies (details unknown).</p>';
        }
    }
});
//"Valor"
Selectable.Leve.Tooltip.Valor = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Valor');
}
Selectable.Leve.Tooltip.Valor.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080021.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.mobs && this.leve.mobs[0] && this.leve.mobs[0].n) {
            var html = $('<div></div>');
            $('<p>Kill the following enemies:</p>')
                .appendTo(html);
            html.append(this._getNumberedEnemyList());
            return html;
        } else {
            return $('<p>Kill n&nbsp;enemies (details unknown).</p>');
        }
    }
});
//"Veracity"
Selectable.Leve.Tooltip.Veracity = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Veracity');
}
Selectable.Leve.Tooltip.Veracity.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080046.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve 
                && this.leve.item_mob 
                && this.leve.item 
                && this.leve.mobs && this.leve.mobs[0] && this.leve.mobs[0].mob 
                && this.leve.n 
                && this.leve.target_mob) {
            var html = $('<div></div>');
            $('<p>Kill ' + this.leve.item_mob + ' to obtain ' + this.leve.item + '.</p>')
                .appendTo(html);
            $('<p>Use this item on ' + this.leve.mobs[0].mob + '.</p>')
                .appendTo(html);
            $('<p>Keep trying until you have found and killed ' + this.leve.n + '&nbsp;' + this.leve.target_mob + '.</p>')
                .appendTo(html);
            return html;
        } else {
            return $('<p>Kill enemies to obtain an item; use item on other enemies; kill real target if it is revealed (details unknown).</p>');
        }
    }
});
//"Wisdom"
Selectable.Leve.Tooltip.Wisdom = function(leve) {
    Selectable.Leve.Tooltip.Leve.call(this, leve, 'Wisdom');
}
Selectable.Leve.Tooltip.Wisdom.prototype = $.extend({}, Selectable.Leve.Tooltip.Leve.prototype, {
    _getCard: function() {
        return $('<img />')
            .attr({
                src: 'http://melodysmaps.com/icons/080000/080023.tex.png',
                alt: '',
                width: 160,
                height: 256
            });
    },
    _getObjectives: function() {
        if(this.leve && this.leve.n && this.leve.mob) {
            var html = $('<div></div>');
            $('<p>Find ' + this.leve.n + '&nbsp;pages of the <i>Necrologos</i> to summon and defeat ' + this.leve.mob + '.</p>')
                .appendTo(html)
            html.append(this._getHostiles());
            return html;
        } else {
            return $('<p>Find n&nbsp;pages of the <i>Necrologos</i> to summon and defeat a target (details unknown).</p>');
        }
    }
});