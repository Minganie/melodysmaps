$.widget("melsmaps.vistaBox", $.melsmaps.lightbox, {
    
    _initLayout: function() {
        this.title = $('<h1></h1>')
            .appendTo(this.container);
        this.impression = $('<p></p>')
            .appendTo(this.container);
            
        var smallHintP = $('<p></p>')
            .appendTo(this.container);
        this.smallHintBtn = $('<button></button>')
            .html('Hint')
            .appendTo(smallHintP)
            .on('click', $.proxy(function() {
                this.smallHint.removeClass('hiding');
            }, this));
        this.smallHint = $('<span></span>')
            .addClass('hiding')
            .appendTo(smallHintP);
        
        var bigHintP = $('<p></p>')
            .appendTo(this.container);
        this.bigHintBtn = $('<button></button>')
            .html('Big Hint')
            .appendTo(bigHintP)
            .on('click', $.proxy(function() {
                this.bigHint.removeClass('hiding');
            }, this));
        this.bigHint = $('<span></span>')
            .addClass('hiding')
            .appendTo(bigHintP);
        
        var spoilerP = $('<p></p>')
            .appendTo(this.container);
        this.spoilerBtn = $('<button></button>')
            .html('Spoilers')
            .appendTo(spoilerP)
            .on('click', $.proxy(function() {
                this.spoilerDiv.removeClass('hiding');
            }, this));
        
        this.spoilerDiv = $('<div></div>')
            .addClass('hiding')
            .appendTo(this.container);
        this.subtitle = $('<h2></h2>')
            .appendTo(this.spoilerDiv);
        this.record = $('<p></p>')
            .appendTo(this.spoilerDiv);
        this.time = $('<p></p>')
            .appendTo(this.spoilerDiv);
        this.weather = $('<div></div>')
            .appendTo(this.spoilerDiv);
        this.emote = $('<p></p>')
            .appendTo(this.spoilerDiv);
        $('<button></button>')
            .html('Show on map')
            .appendTo(this.spoilerDiv)
            .on('click', $.proxy(function() {                
                this.vista.showOnMap();
                this.hide();
            }, this));
        var scP = $('<p></p>')
            .appendTo(this.spoilerDiv);
        var a = $('<a></a>')
            .appendTo(scP);
        this.img = $('<img />')
            .attr('alt', "Screenshot showing the sightseeing entry location")
            .attr('height', 563)
            .attr('width', 1000)
            .appendTo(scP);
    },
    
    setVista: function(vista) {
        this.vista = vista;
        this._reset();
        
        var that = this;
        this.vista._full.then(function(vista) {
            that.title.html(that._formatTitle(vista));
            that.impression.html(that._formatImpression(vista));
            that.smallHint.html(that._formatSmallHint(vista));
            that.bigHint.html(that._formatBigHint(vista));
            that.subtitle.html(that._formatSubtitle(vista));
            that.record.html(that._formatRecord(vista));
            that.time.html(that._formatTime(vista));
            that.weather.html(that._formatWeather(vista));
            that.emote.html(that._formatEmote(vista));
            that.img.attr('src', 'icons/sightseeing/' + vista.name + '.png');
        });
        
        this.show();
    },
    
    
    _formatTitle: function(vista) {
        return 'Sightseeing Entry #' + vista.name;
    },
    
    _formatImpression: function(vista) {
        return vista.impression;
    },
    
    _formatSmallHint: function(vista) {
        return vista.hint;
    },
    
    _formatBigHint: function(vista) {
        return vista.big_hint;
    },
    
    _formatSubtitle: function(vista) {
        return vista.uname;
    },
    
    _formatRecord: function(vista) {
        return vista.record;
    },
    
    _formatTime: function(vista) {
        var html = '';
        if(vista.debut && vista.fin) {
            html += '<img src="icons/clock.png" class="melsmaps-vista-icon" alt="Clock icon" width=18 height=18" />';
            html += '<span>' + vista.debut + ' - ' + vista.fin + '</span>';
        }
        return html;
    },
    
    _formatWeather: function(vista) {
        var html = '';
        if(vista.weather) {
            for(var i in vista.weather) {
                var weather = vista.weather[i];
                html += '<p>';
                html += '<img src="icons/weather/' + weather + '.png" class="melsmaps-vista-icon" alt="Weather icon" width=18 height=18/>';
                html += '<span>' + weather + '</span>';
                html += '</p>';
            }
        }
        return html;
    },
    
    _formatEmote: function(vista) {
        var html = '';
        if(vista.emote.substring(1, vista.emote.length)) {
            html += '<img src="icons/emotes/' + vista.emote.substring(1, vista.emote.length) + '.png" class="melsmaps-vista-icon" alt="Emote icon" width=18 height=18 />';
            html += '<span>' + vista.emote + '</span>';
        }
        return html;
    },
    
    _reset: function() {
        this.smallHint
            .addClass('hiding');
        this.bigHint
            .addClass('hiding');
        this.spoilerDiv
            .addClass('hiding');
    }
});