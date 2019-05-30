$.widget("melsmaps.questBox", $.melsmaps.lightbox, {
    _initLayout: function() {
        this.container.addClass('melsmaps-quest-tooltip-container');
        this.container.on('click', '.melsmaps-npc-link', $.proxy(function(evt) {
            var selectable = $(evt.currentTarget).data('selectable');
            selectable.onSelect();
            this.hide();
        }, this));
        this.container.on('click', '.melsmaps-duty-link', $.proxy(function(evt) {
            var dutylid = $(evt.currentTarget).attr('data-melsmaps-duty-lid');
            var that = this;
            api("duties/each", dutylid).then(function(full) {
                var duty = Selectable.getFull(full);
                that.hide();
                duty.onSelect();
            });
        }, this));
    },
    setQuest: function(quest) {
        this.quest = quest;
        this._reset();

        var that = this;
        this.quest._full.then(function(quest) {
            var html = Selectable.getQuestTooltip(quest);
            that.container.append(html);
        });

        this.show();
    },
    _reset: function() {
        this.container.find('.melsmaps-quest-tooltip-container').remove();
    }
});