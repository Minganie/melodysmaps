$.widget("melsmaps.leveBox", $.melsmaps.lightbox, {
    
    _initLayout: function() {
        this.container.addClass('melsmaps-leve-tooltip-container');
        this.container.on('click', '.melsmaps-npc-link', $.proxy(function(evt) {
            var npc = $(evt.target).attr('data-melsmaps-npc-name');
            api("npcs", npc).then(function(full) {
                var npc = Selectable.getFull(full);
                this.hide();
                npc.onSelect();
            });
        }, this));
        this.container.on('click', '.melsmaps-levemete-link', $.proxy(function(evt) {
            var levemete = $(evt.target).attr('data-melsmaps-levemete');
            api("levemetes", levemete).then(function(full) {
                var npc = Selectable.getFull(full);
                this.hide();
                npc.onSelect();
            });
        }, this));
    },
    
    setLeve: function(leve) {
        this.leve = leve;
        this._reset();
        
        var that = this;
        this.leve._full.then(function(leve) {
            var html = Selectable.getLeveTooltip(leve);
            that.container.append(html);
        });
        
        this.show();
    },
    _reset: function() {
        this.container.find('.melsmaps-leve-tooltip-container').remove();
    }
});