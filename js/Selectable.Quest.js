Selectable.Quest = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.lid) {
        this._full = api("quests", searchable.lid);
    }
}
Selectable.Quest.prototype = $.extend({}, Selectable.prototype, {
    onSelect: function() {
        $('#quest').questBox('instance').setQuest(this);
    },
    // getIcon: function(lev) {
        // return $()
        // var extra = null;
        // var part;
        // if(lev.gc && lev.gc != '') {
            // switch(this._resolved.gc) {
                // case 'Maelstrom':
                    // part = 'maelstrom';
                    // break;
                // case 'Order of the Twin Adder':
                    // part = 'adder';
                    // break;
                // case 'Immortal Flames':
                    // part = 'flames';
                    // break;
            // }
            // extra = $('<img src="http://melodysmaps.com/icons/leves/' + part + '.png" alt="Grand company icon" width=28 height=36 />');
        // }
        // if(lev.type == 'Battlecraft' || lev.job == 'Disciple of War or Magic')
            // part = 'battlecraft';
        // else if(lev.type == 'Tradecraft' || lev.type == 'Fieldcraft')
            // part = lev.job.toLowerCase();
        
        // var def_img = $('<img src="http://melodysmaps.com/icons/leves/' + part + '.png" alt="' + lev.job + ' leve icon" title="' + lev.job + ' leve" width=24 height=30 />');
        // var span = $('<span></span>')
            // .append(extra)
            // .append(def_img);
        // return span;
    // }
});
Selectable.Quest.Source = {
    getLine: function(quest) {
        quest.category.iconSize = 24;
        var img = quest.category.getGoldIcon();
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

Selectable.Quest.Tooltip = {
    get: function(quest) {
      return new Selectable.Quest.Tooltip.Quest(quest);
    }
};

Selectable.Quest.Tooltip.Quest = function(quest, className) {
    this._className = className || 'Quest';
    this._helperId = quest.name || 'no idea';
    this.quest = quest;
}
Selectable.Quest.Tooltip.Quest.prototype = {
    _getQuestTypeIcon: function(questType) {
        switch(questType) {
            case 'Main Story Quest':
                return "icons/quests/msq.png";
            case 'Feature Quest, Repeatable':
                return "icons/quests/weekly.png";
            case 'Feature Quest':
                return "icons/quests/unlock.png";
            case 'Side Quest':
                return "icons/quests/side.png";
            case 'Side Quest, Repeatable':
                return "icons/quests/daily.png";
            default:
                console.error("Can't figure out which icon type to get for '" + questType + "'");
        }
    },
    _addTop: function(html) {
        if(this.quest && this.quest.banner) {
            var banner = $('<img class="banner" alt="" width=376 height=120 />')
                .attr("src", this.quest.banner);
            html.append(banner);
        }
        var qi = $('<div class="questInfo"></div>');
        html.append(qi);
        $('<img alt="" width=32 height=32 />')
            .attr("src", this._getQuestTypeIcon(this.quest.quest_type))
            .appendTo(qi);
        var div = $('<div></div>').appendTo(qi);
        console.log(this.quest);
        $('<h1></h1>')
            .html(this.quest.name)
            .appendTo(div);
        var p = $('<p></p>').appendTo(div);
        var span1 = $('<span>Lv. </span>');
        span1.html(span1.html() + this.quest.level)
            .appendTo(p);
        $('<span></span>')
            .html(this.quest.quest_category)
            .appendTo(p);
    },
    _getDataBlock: function() {
        var div = $('<div class="questBlock data"></div>');
        if(!this.quest.seasonal) {
          $('<h2>Quest Giver</h2>').appendTo(div);
          $('<h3 class="llink"></h3>')
              .html(this.quest.quest_giver.label)
              .appendTo(div);
          $('<p></p>')
              .html(this.quest.quest_giver.zone.name + ' X: ' + this.quest.quest_giver.x + ' Y: ' + this.quest.quest_giver.y)
              .appendTo(div);
        } else {
            $('<p class="melsmaps-quest-seasonal"></p>')
            .html("This quest cannot be accepted. The associated seasonal event has ended.")
            .appendTo(div);
        }
        return div;
    },
    _getGcText: function() {
        if(!this.quest.gc)
            return "Not specified";
        var t = this.quest.gc;
        if(this.quest.gc_rank)
            t += " / Over " + this.quest.gc_rank;
        return t;
    },
    _makeHalfBlock: function(src, word, number) {
        return (this._makeImgAndTwoPs(src, word, false, number, null) ?
            this._makeImgAndTwoPs(src, word, false, number, null).addClass("halfBlock")
            : null);
    },
    _makeImgAndTwoPs: function(src, name, isItem, number, restriction) {
        var block = $('<div class="imgAndTwoPs"></div>');
        $('<img alt="" width=32 height=32 />')
            .attr("src", src)
            .appendTo(block);
        var wrapper = $('<div></div>')
            .appendTo(block);
        $('<p' + (isItem ? ' class="llink"' : '') + '></p>')
            .html(name)
            .appendTo(wrapper);
        if(number)
            $('<p></p>')
                .html(number)
                .appendTo(wrapper);
        if(restriction)
            $('<p></p>')
                .html(restriction)
                .appendTo(wrapper);
        return block;
    },
    _getRequirementBlock: function() {
        var div = $('<div class="questBlock requirements"></div>')
            .append($('<h2>Requirements</h2>'))
            .append($('<h3>Starting Class</h3>'));
        $('<p></p>')
            .html(this.quest.starting_class ? this.quest.starting_class : "Not specified")
            .appendTo(div);
        $('<h3>Class/Job</h3>').appendTo(div);
        $('<p></p>')
            .html(this.quest.class_requirement ? this.quest.class_requirement : "Not specified")
            .appendTo(div);
        $('<h3>Grand Company</h3>').appendTo(div);
        $('<p></p>')
            .html(this._getGcText())
            .appendTo(div);
        $('<h3>Quest/Duty</h3>').appendTo(div);
        if(this.quest.requirements) {
            for(var i in this.quest.requirements) {
                var d = this.quest.requirements[i];
                $('<p></p>')
                    .html(d.name + ' (' + d.mode + ')')
                    .appendTo(div);
            }
            $('<p>All above </p>').appendTo(div);
        } else {
            $('<p>Not specified</p>').appendTo(div);
        }
        $('<h4>Reward</h4>').appendTo(div);
        var nrewards = [
            {
                src: "icons/xp.png",
                name: "Experience",
                n: this.quest.xp,
            },
            {
                src: "icons/gil.png",
                name: "Gil",
                n: this.quest.gil,
            },
            {
                src: "icons/venture.png",
                name: "Venture",
                n: this.quest.ventures,
            },
            {
                src: this.quest.tomestones ? "icons/" + this.quest.tomestones.split(' ').join('').toLowerCase() + ".png" : null,
                name: this.quest.tomestones,
                n: this.quest.tomestones_n,
            },
            {
                src: this.quest.bt ? "icons/" + this.quest.bt.split(' ').join('').split(",").join('').toLowerCase() + "_currency.png" : null,
                name: this.quest.bt_currency,
                n: this.quest.bt_currency_n
            },
            {
                src: this.quest.bt ? "icons/" + this.quest.bt.split(' ').join('').split(",").join('').toLowerCase() + ".png" : null,
                name: this.quest.bt + " Relations",
                n: this.quest.bt_reputation
            },
            {
                src: "icons/seal.png",
                name: "Seals",
                n: this.quest.gc_seals
            }
        ];
        for(var i in nrewards) {
            var rew = nrewards[i];
            if(rew.n)
                div.append(this._makeHalfBlock(rew.src, rew.name, rew.n));
        }
        return div;
    },
    _getCompletionRewards: function() {
        var div = $('<div></div>');
        if((this.quest.rewards && this.quest.rewards.length > 0) || (this.quest.other && this.quest.other.length > 0)) {
            var cr = this.quest.rewards.filter(function(rew) {
                return !rew.optional;
            });
            if((cr && cr.length > 0)|| (this.quest.other && this.quest.other.length > 0)) {
                div.addClass("questBlock").addClass("rewards");
                div.append($('<h2>Completion Rewards</h2>'));
                for(var i in cr) {
                    rew = cr[i];
                    var restr = rew.classJob ? rew.classJob : '';
                    restr += rew.gender ? rew.gender : ''
                    div.append(this._makeImgAndTwoPs(rew.item.licon, rew.item.name, true, rew.n, restr));
                }
                for(var i in this.quest.other) {
                    rew = this.quest.other[i];
                    div.append(this._makeImgAndTwoPs(rew.icon, rew.other, false, null, null));
                }
            }
        }
        return div;
    },
    _getOptionalRewards: function() {
        var div = $('<div></div>');
        if(this.quest.rewards && this.quest.rewards.length > 0) {
            var or = this.quest.rewards.filter(function(rew) {
                return rew.optional;
            });
            if(or && or.length > 0) {
                div.addClass("questBlock").addClass("rewards");
                div.append($('<h2>Optional Rewards</h2>'));
                for(var i in or) {
                    rew = or[i];
                    this._makeImgAndTwoPs(rew.item.licon, rew.item.name, true, rew.n, null).appendTo(div);
                }
            }
        }
        return div;
    },
	getTooltip: function() {
		var html = $('<div></div>');
        this._addTop(html);
        html.append(this._getDataBlock());
        html.append(this._getRequirementBlock());
        html.append(this._getCompletionRewards());
        html.append(this._getOptionalRewards());
		return html;
	}
}
