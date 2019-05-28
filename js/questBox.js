$.widget("melsmaps.questBox", $.melsmaps.lightbox, {

  _initLayout: function() {
    this.container.addClass('melsmaps-quest-tooltip-container');
  },

  setQuest: function(quest) {
    this.quest = quest;
    this._reset();

    var that = this;
    this.quest._full.then(function(quest) {
      var html = Selectable.getQuestTooltip(quest);
      that.container.append(html);
      // that.container.on('click', '.melsmaps-npc-link', function(evt) {
      // var npc = $(evt.target).attr('data-melsmaps-npc-name');
      // api("npcs", npc).then(function(full) {
      // var npc = Selectable.getFull(full);
      // that.hide();
      // npc.onSelect();
      // });
      // });
      // that.container.on('click', '.melsmaps-levemete-link', function(evt) {
      // var levemete = $(evt.target).attr('data-melsmaps-levemete');
      // api("levemetes", levemete).then(function(full) {
      // var npc = Selectable.getFull(full);
      // that.hide();
      // npc.onSelect();
      // });
      // });
    });

    this.show();
  },
  _reset: function() {
    this.container.find('div').remove();
  }
});