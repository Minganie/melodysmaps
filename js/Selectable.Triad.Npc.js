Selectable.Triad.Npc = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.name) {
        this._full = api("triad/npcs", searchable.name);
    }
}
Selectable.Triad.Npc.prototype = $.extend({}, Selectable.DefaultPoint.prototype, {
    _getPopupSubtitle: function(popupable) {
        return $('<h2></h2>')
            .html("Triad Player " + popupable.name);
    },
    
    _getRequirement: function(requirements) {
		var html = null;
		if(requirements) {
            html = $('<div></div>')
				.addClass('req');
            for(var i in requirements) {
                html.append($('<p title="Requires this quest">' + requirements[i].name + '</p>'));
            }
        }
        return html;
    },
    
    _getMatchSection: function(popupable) {
        var html = $('<div class="melsmaps-triad-match"></div>');
        html.append($('<h2>Match</h2>'));
        var rules = $('<p class="melsmaps-triad-rules">Rules: </p>');
        for(var i in popupable.rules) {
            rules.append($('<span>' + popupable.rules[i] + '</span>'));
        }
        html.append(rules);
        // MPG
        var table = `
        <table>
        <tr>
        <td>Price: ${popupable.cost} MGP</td>
        <td>
            <p>Win: ${popupable.win} MGP</p>
            <p>Draw: ${popupable.draw} MGP</p>
            <p>Lose: ${popupable.loss} MGP</p>
        </td>
        </tr>
        </table>
        `;
        html.append($(table));
        // rules
        return html;
    },
    _getDeckSection: function(deck) {
        var html = $('<div class="melsmaps-triad-deck"></div>');
        if(deck.length > 0) {
            html.append("<h2>NPC's deck</h2>");
            for(var i in deck) {
                var cardBag = deck[i];
                var card = Selectable.Triad.Card.Tooltip.get(cardBag.card).getCard();
                if(cardBag.always) {
                    card.addClass("melsmaps-triad-deck-always-present");
                    card.attr("title", card.attr("title") + ", always present in deck");
                }
                html.append(card);
            }
        }
        return html;
    },
    _getRewardsSection: function(rewards) {
        var html = $('<div class="melsmaps-triad-rewards"></div>');
        if(rewards.length > 0) {
            html.append('<h2>Possible rewards</h2>');
            for(var i in rewards) {
                var card = rewards[i];
                var cardTt = Selectable.Triad.Card.Tooltip.get(card);
                html.append(cardTt.getCard());
            }
        }
        return html;
    },
    
    _getPopupContent: function(popupable) {
        // console.log(popupable);
		var html = $('<div></div>');
        html.append(this._getRequirement(popupable.requires));
        html.append(this._getMatchSection(popupable));
        html.append(this._getDeckSection(popupable.deck));
        html.append(this._getRewardsSection(popupable.rewards));
        return html;
    }
});
Selectable.Triad.Npc.Source = {
    getLine: function(npc) {
        npc.iconSize = 24;
        var img = npc.category.getGoldIcon();
        var a = $('<a></a>')
            .html(npc.name);
        var li = $('<li></li>')
            .addClass('melsmaps-item-source-link')
            .append(img)
            .append(a)
            .attr('title', 'Click to pan to the npc');
        li.data('selectable', Selectable.getFull(npc));
        return li;
    }
};