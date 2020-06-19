Selectable.Triad.Card = function(searchable) {
    this._searchable = searchable;
    if(searchable && searchable.name) {
        this._full = api("triad/cards", searchable.name);
    }
}
Selectable.Triad.Card.prototype = $.extend({}, Selectable.prototype, {
});
Selectable.Triad.Card.Tooltip = {
    get: function(card) {
        return new Selectable.Triad.Card.Tooltip.Card(card);
    }
};

Selectable.Triad.Card.Tooltip.Card = function(card, className) {
    this._className = className || 'Card';
    this._helperId = card.name || 'no idea';
	this.card = card;
};
Selectable.Triad.Card.Tooltip.Card.prototype = {
    getCard: function() {
        var html = null;
        if(this.card) {
            html = $('<div class="melsmaps-item-tooltip-card" title="' + this.card.name + '"></div>');
            // console.log(this.card);
            html.append($('<div class="card-rarity stars' + this.card.stars + '"></div>'));
            html.append($('<img src="icons/triad/' + this.card.icon + '" width=104 height=128>'));
            html.append($('<div class="north">' + (this.card.north == 10 ? 'A' : this.card.north) + '</div>'));
            html.append($('<div class="east">' + (this.card.east == 10 ? 'A' : this.card.east) + '</div>'));
            html.append($('<div class="south">' + (this.card.south == 10 ? 'A' : this.card.south) + '</div>'));
            html.append($('<div class="west">' + (this.card.west == 10 ? 'A' : this.card.west) + '</div>'));
            if(this.card.card_type) {
                html.append($('<div class="card-type ' + this.card.card_type + '"></div>'));
            }
        }
        return html;
    }
};