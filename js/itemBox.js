$.widget('melsmaps.itemBox', $.melsmaps.lightbox, {
    _initLayout: function() {
        this.container.addClass('melsmaps-item-container');
        this.title = $('<h1></h1>')
			.addClass('melsmaps-item-title')
			.appendTo(this.container);
		this.titleIcon = $('<img />')
			.attr('width', 36)
			.attr('height', 36)
			.appendTo(this.title);
		this.titleName = $('<span></span>')
			.appendTo(this.title);
		$('<span></span>')
			.addClass('melsmaps-item-title-stretch')
			.appendTo(this.title);
		$('<button></button>')
			.html('Show all on map')
			.appendTo(this.title)
			.on('click', $.proxy(this._showAll, this));
		this.fishContainer = $('<div></div>')
			.addClass('melsmaps-item-fish-info')
			.appendTo(this.container);
		var sourcesContainer = $('<div></div>')
			.addClass('melsmaps-item-sources')
			.appendTo(this.container);
		this._setSubtitles(sourcesContainer);
        this.container.on('click', 'li.melsmaps-item-source-link', $.proxy(function(evt) {
            var selectable = $(evt.currentTarget).data('selectable');
            selectable.onSelect();
            this.hide();
        }, this));
    },
    
    _setSubtitles: function(sourcesContainer) {
		var left = $('<div></div>')
			.appendTo(sourcesContainer);
		var middle = $('<div></div>')
			.appendTo(sourcesContainer);
		var right = $('<div></div>')
			.appendTo(sourcesContainer);
		
		// GATHERING OR FISHING
		var nodes = $('<div></div>')
			.appendTo(left);
		this._setSubtitle(nodes, 'http://melodysmaps.com/icons/sections/gathered.png', 'gathered at');
		this.nodes = $('<ul></ul>').appendTo(nodes);
		
		// BUYING AT MERCHANT
		var merchants = $('<div></div>')
			.appendTo(left);
		this._setSubtitle(merchants, 'http://melodysmaps.com/icons/sections/bought.png', 'bought at');
		this.merchants = $('<ul></ul>').appendTo(merchants);
			
		// CRAFTING
		var crafters = $('<div></div>')
			.appendTo(left);
		this._setSubtitle(crafters, 'http://melodysmaps.com/icons/sections/crafted.png', 'crafted by');
		this.crafters = $('<ul></ul>').appendTo(crafters);
        
        // HG
		var hunting_grounds = $('<div></div>')
			.appendTo(middle);
		this._setSubtitle(hunting_grounds, 'http://melodysmaps.com/icons/sections/hunted.png', 'dropped off');
		this.hunting_grounds = $('<ul></ul>').appendTo(hunting_grounds);
        
        // DUTIES
		var duties = $('<div></div>')
			.appendTo(middle);
		this._setSubtitle(duties, 'http://melodysmaps.com/icons/sections/dungeonned.png', 'looted in');
		this.duties = $('<ul></ul>').appendTo(duties);
        
        // LEVES
        var leves = $('<div></div>')
            .appendTo(middle);
        this._setSubtitle(leves, 'http://melodysmaps.com/icons/sections/leved.png', 'rewarded for');
        this.leves = $('<ul></ul>').appendTo(leves);
        
        // TREASURE MAPS
		var maps = $('<div></div>')
			.appendTo(middle);
		this._setSubtitle(maps, 'http://melodysmaps.com/icons/sections/treasured.png', 'found with');
		this.maps = $('<ul></ul>').appendTo(maps);
        
        // USED IN
		var uses = $('<div></div>')
			.appendTo(right);
		this._setSubtitle(uses, 'http://melodysmaps.com/icons/sections/reagent.png', 'used in');
		this.uses = $('<ul></ul>').appendTo(uses);
	},
	
	_setSubtitle: function(parent, icon, verb) {
		var h2 = $('<h2></h2>').appendTo(parent);
		var img = $('<img />')
			.attr('src', icon)
			.attr('width', 32)
			.attr('height', 32)
			.appendTo(h2);
		var span = $('<span></span>')
			.html('Can be ' + verb)
			.appendTo(h2);
		var div = $('<div></div>')
			.addClass('melsmaps-separator')
			.appendTo(parent);
	},
    
    setItem: function(item) {
        this.item = item;
		
        this._reset();
        
		this._setTitle();
		this._setSources();
        
        this.show();
        return this;
    },
    
    _reset: function() {
        this.fishContainer.empty();
        this.nodes.empty();
        this.merchants.empty();
        this.crafters.empty();
        this.hunting_grounds.empty();
        this.duties.empty();
        this.maps.empty();
        this.uses.empty();
        this.leves.empty();
    },
    
    _setTitle: function() {
        var that = this;
        this.item._info.then(function(ioi) {
            that.titleIcon
                .attr('src', ioi.licon)
                .attr('alt', ioi.name + ' icon');
            that.titleName
                .html(ioi.name);
        });
	},
    
    _setSources: function() {
        var that = this;
        var hoursDiv = $('<div></div>').appendTo(that.fishContainer).html('Loading...');
        $.when.apply($, [this.item._info, this.item._sources])
        .fail(function(x, t, e) {
            var hoursDiv = $('<div></div>').appendTo(that.fishContainer).html('There was a problem loading data... Sorry!');
        })
        .done(function(info, sources) {
            that._reset();
            
            // SPECIAL SUPPLEMENTARY INFO FOR FISHES
            var fishConditions = info.fish_conditions;
            if(fishConditions && fishConditions.hours && fishConditions.weathers) {
                // HOURS
                var hoursDiv = $('<div></div>').appendTo(that.fishContainer);
                var table = $('<table class="melsmaps-fish-hours"></table>').appendTo(hoursDiv);
                $('<caption>Catches per hour</caption>').appendTo(table);
                var blockTr = $('<tr></tr>').appendTo(table);
                var txTr = $('<tr></tr>').appendTo(table);
                var maxHeight = Math.max(...fishConditions.hours);
                var pixels = 100;
                for(var i = 0; i < fishConditions.hours.length; i++) {
                    var height = Math.round(fishConditions.hours[i] / maxHeight * pixels);
                    $('<td><div class="melsmaps-fishing-hour" style="height: ' + height + 'px;"></div></td>').appendTo(blockTr);
                    $('<td>' + i + '</td>').appendTo(txTr);
                }
                
                // WEATHERS
                var weatherDiv = $('<div></div>').appendTo(that.fishContainer);
                var wTable = $('<table class="melsmaps-fish-weather"></table>').appendTo(weatherDiv);
                $('<caption>Weather conditions</caption>').appendTo(wTable);
                var maxWidth = Math.max.apply(Math, fishConditions.weathers.map(function(w) { return w.catches; }));
                for(var i = 0; i < fishConditions.weathers.length; i++) {
                    var weather = fishConditions.weathers[i];
                    var width = Math.round(weather.catches / maxWidth * pixels);
                    var tr = $('<tr></tr>').appendTo(wTable);
                    $('<td>' + weather.weather + '</td>').appendTo(tr);
                    $('<td><img src="http://melodysmaps.com/icons/weather/' + weather.weather + '.png" alt="" width=24 height=24 /></td>').appendTo(tr);
                    $('<td><div class="melsmaps-fishing-weather" style="width: ' + width + 'px;"></div></td>').appendTo(tr);
                }
            }
            
            // GATHERING
            for(var i in sources.nodes) {
                var li = Selectable.getSourceLine(sources.nodes[i], info);
                that.nodes.append(li);
            }
            // merchants
            for(var i in sources.merchants) {
                var li = Selectable.getSourceLine(sources.merchants[i], info);
                that.merchants.append(li);
            }
            // crafters
            for(var i in sources.crafters) {
                sources.crafters[i].category = {
                    getName: function() {
                        return 'Recipe';
                    }
                };
                var li = Selectable.getSourceLine(sources.crafters[i]);
                that.crafters.append(li);
            }
            // hg
            for(var i in sources.hunting) {
                var li = Selectable.getSourceLine(sources.hunting[i].ms, info, sources.hunting[i].hq, sources.hunting[i].nq);
                that.hunting_grounds.append(li);
            }
            // duties
            for(var i in sources.duties) {
                var li = Selectable.getSourceLine(sources.duties[i]);
                that.duties.append(li);
            }
            // treasure maps
            for(var i in sources.maps) {
                var map = sources.maps[i];
                
                var img = $('<img />')
                    .attr('src', 'http://melodysmaps.com/icons/gold/treasure.png')
                    .attr('width', 24)
                    .attr('height', 24);
                var li = $('<li></li>')
                    .append(img)
                    .append(map.map);
                var ul = $('<ul></ul>')
                    .appendTo(li);
                for(var i in map.nodes) {
                    var nli = Selectable.getSourceLine(map.nodes[i]);
                    ul.append(nli);
                }
                that.maps.append(li);
            }
            // recipe
            for(var i in sources.uses) {
                sources.uses[i].category = {
                    getName: function() {
                        return 'Recipe';
                    }
                };
                var li = Selectable.getSourceLine(sources.uses[i]);
                that.uses.append(li);
            }
            // leves
            for(var i in sources.leves) {
                var li = Selectable.getSourceLine(sources.leves[i]);
                that.leves.append(li);
            }
            
        });
	},
    
    _showAll: function() {
        var that = this;
        this.item._info.then(function(item) {
            var name = item.name;
            that.nodes.find('li').each(function(i, li) {
                $(li).data('selectable')._addToMap(name);
            });
            that.merchants.find('li').each(function(i, li) {
                $(li).data('selectable')._addToMap(name);
            });
            that.hunting_grounds.find('li').each(function(i, li) {
                $(li).data('selectable')._addToMap(name);
            });
            that.duties.find('li').each(function(i, li) {
                $(li).data('selectable')._addToMap(name);
            });
            that.maps.find('li.melsmaps-item-source-link').each(function(i, li) {
                $(li).data('selectable')._addToMap(name);
            });
        });
        this.hide();
	}
});