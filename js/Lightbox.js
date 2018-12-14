$.widget('melsmaps.lightbox', {
    options: {},
    
    _create: function() {
        this.element
            .addClass('melsmaps-lightbox-overlay')
            .addClass('hiding');
        this.container = $('<div></div>')
            .addClass('melsmaps-lightbox-container')
            .appendTo(this.element);
        this.closeButton = $('<button></button>')
            .addClass('melsmaps-lightbox-close')
            .appendTo(this.container)
            .on('click', $.proxy(this.hide, this));
        this._initLayout();
        return this;
    },
    
    _initLayout: function() {
    },
        
    show: function() {
        this.element.removeClass('hiding');
        return this;
    },
    
    hide: function() {
        this.element.addClass('hiding');
        return this;
    },
    
    _reset: function() {
    }
});