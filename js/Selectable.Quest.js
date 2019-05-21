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
    getIcon: function(lev) {
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
    }
});
Selectable.Quest.Source = {
    getLine: function(quest) {
        // leve.category.iconSize = 24;
        // var img = leve.category.getGoldIcon();
        // var a = $('<a></a>')
            // .html(leve.name + ' (lvl ' + leve.lvl + ')');
        // var li = $('<li></li>')
            // .append(img)
            // .append(a)
            // .addClass('melsmaps-item-source-link')
            // .attr('title', 'Click to view the leve');
        // li.data('selectable', Selectable.getFull(leve));
        // return li;
    }
};

Selectable.Quest.Tooltip = {
    get: function(quest) {
        
        // else if(leve.model=='Wisdom')
            // return new Selectable.Leve.Tooltip.Wisdom(leve);
        // else {
            // console.error("Can't find the type of leve tooltip to make for ");
            // console.error(leve);
        // }
    }
};

Selectable.Quest.Tooltip.Quest = function(quest, className) {
  this._className = className || 'Quest';
  this._helperId = quest.name || 'no idea';
	this.quest = quest;
}
Selectable.Quest.Tooltip.Quest.prototype = {
    _getName: function() {
        // return $('<h1></h1>')
            // .html(this.leve.name);
    },

    _getCurrencies: function() {
        // var html = $('<div></div>')
            // .addClass('melsmaps-leve-tooltip-section melsmaps-leve-tooltip-currencies');
        // $('<h2></h2>')
            // .html('<img src="http://melodysmaps.com/icons/leves/currency_reward.png" width=32 height=32 alt="" />Currency rewards')
            // .appendTo(html);
        // html.append(this.leve.xp && this.leve.xp>0 ? '<span>' + this.leve.xp + '<img src="http://melodysmaps.com/icons/xp.png" alt="" width=24 height=24 /></span>' : '?');
        // html.append(this.leve.gil && this.leve.gil>0 ? '<span>' + this.leve.gil + '<img src="http://melodysmaps.com/icons/gil.png" alt="" width=24 height=24 /></span>' : '');
        // html.append(this.leve.seals && this.leve.seals>0 ? '<span>' + this.leve.seals + '<img src="http://melodysmaps.com/icons/flameseal.png" alt="" width=24 height=24 /></span>' : '');
        // return html;
    },
    _getRewards: function() {
        // var html = $('<div></div>');
        // if(this.leve && this.leve.rewards)
            // for(var i = 0; i < this.leve.rewards.length; i++) {
                // var reward = this.leve.rewards[i];
                // if(reward && reward.n && reward.item) {
                    // var span = $('<span></span>')
                        // .append(Selectable.getItemTooltippedImage(reward.item));
                    // html.append(reward.n + ' x ')
                        // .append(span);
                // }
            // }
        // return html;
    },
    _getHostiles: function() {
        // var html = $('<div></div>');
        // if(this.leve.mobs && this.leve.mobs[0] && this.leve.mobs[0].mob) {
            // $('<p></p>')
                // .html('You may face the following hostiles:')
                // .appendTo(html);
            // html.append(this._getNumberedEnemyList());
        // }
        // return html;
    },
	getTooltip: function() {
		var html = $('<div></div>')
      .addClass('melsmaps-quest-tooltip-container');
    var inner = 
`<div>
  <div class="questTop">
    <img class="banner" src="" alt="" width= height= />
    <div class="questInfo">
      <img src="" alt="" width=32 height=32 />
      <div>
        <h1></h1>
        <p>Lv. <span></span>  <span></span></p>
      </div>
    </div>
  </div>
  <div class="questBlock giver">
    <h2>Quest Giver</h2>
    <h3></h3>
    <p></p>
  </div>
  <div class="questBlock data">
    <h2>Requirements</h2>
    <h3>Starting Class</h3>
    <p></p>
    <h3>Class/Job</h3>
    <p></p>
    <h3>Grand Company</h3>
    <p></p>
    <h3>Quest/Duty</h3>
    <p></p>
  </div>
  <div class="questBlock reward">
    <h2>Reward</h2>
  </div>
</div>`;
        // var wrapper_div = $('<div></div>')
            // .addClass('melsmaps-leve-tooltip-wrapper')
            // .appendTo(html);
        // wrapper_div.append(this._getName());
        // var main_div = $('<div></div>')
            // .addClass('melsmaps-leve-tooltip-main')
            // .appendTo(wrapper_div);
        // main_div.append(this._getCard());
        // var main_wrapper_div = $('<div></div>')
            // .addClass('melsmaps-leve-tooltip-main-wrapper')
            // .appendTo(main_div);
        // main_wrapper_div.append(this._getLevemete());
        // main_wrapper_div.append(this._getCurrencies());
        // var section_div = $('<div></div>')
            // .addClass('melsmaps-leve-tooltip-section')
            // .appendTo(main_wrapper_div);
        // var img = $('<img />')
            // .attr({
                // src: 'http://melodysmaps.com/icons/leves/objectives.png',
                // width: 32,
                // height: 32,
                // alt: ''
            // });
        // var h2 = $('<h2></h2>')
            // .append(img)
            // .html('Objectives');
        // section_div.append(h2)
            // .append(this._getObjectives());
        // main_wrapper_div.append(this._getWanted());
        // var reward_div = $('<div></div>')
            // .addClass('melsmaps-leve-tooltip-section melsmaps-leve-tooltip-rewards')
            // .appendTo(wrapper_div);
        // $('<h2></h2>')
            // .html('<img src="http://melodysmaps.com/icons/leves/item_rewards.png" width=32 height=32 alt="" />Item rewards')
            // .appendTo(reward_div);
        // reward_div.append(this._getRewards());
		return html;
	}
}
