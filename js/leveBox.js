$.widget("melsmaps.leveBox", $.melsmaps.lightbox, {
    
    _initLayout: function() {
        this.container.addClass('melsmaps-leve-tooltip-container');
    },
    
    setLeve: function(leve) {
        this.leve = leve;
        this._reset();
        
        var that = this;
        this.leve._full.then(function(leve) {
            var html = Selectable.getLeveTooltip(leve);
            that.container.append(html);
            that.container.on('click', '.melsmaps-npc-link', function(evt) {
                var npc = $(evt.target).attr('data-melsmaps-npc-name');
                api("npcs", npc).then(function(full) {
                    var npc = Selectable.getFull(full);
                    that.hide();
                    npc.onSelect();
                });
            });
            that.container.on('click', '.melsmaps-levemete-link', function(evt) {
                var levemete = $(evt.target).attr('data-melsmaps-levemete');
                api("levemetes", levemete).then(function(full) {
                    var npc = Selectable.getFull(full);
                    that.hide();
                    npc.onSelect();
                });
            });
        });
        
        this.show();
    },
    _reset: function() {
        this.container.find('.melsmaps-leve-tooltip-container').remove();
    }
});