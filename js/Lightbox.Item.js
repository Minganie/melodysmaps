$.widget('melsmaps.ItemBox', $.melsmaps.Lightbox, {
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
		var sourcesContainer = $('<div></div>')
			.addClass('melsmaps-item-sources')
			.appendTo(this.container);
		this._setSubtitles(sourcesContainer);
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
		this._setSubtitle(hunting_grounds, 'http://melodysmaps.com/icons/sections/hunted.png', 'drop off');
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
        this.item._sources.then(function(srcs) {
            // console.log(srcs);
            
            // GATHERING
            for(var i in srcs.nodes) {
                // var node = MelsMaps.Selectable.getFull(srcs.nodes[i]);
                // that.nodes.append(node.getListLink());
            }
            // merchants
            for(var i in srcs.merchants) {
                // var merchant = MelsMaps.Selectable.getFull(srcs.merchants[i]);
                // that.merchants.append(merchant.getListLink());
            }
            // crafters
            for(var i in srcs.crafters) {
                // var crafter = MelsMaps.Selectable.getFull(srcs.crafters[i]);
                // that.crafters.append(crafter.getListLink());
            }
            // hg
            for(var i in srcs.hunting) {
                // var hg = MelsMaps.Selectable.getFull(srcs.hunting[i].hg);
                // that.hunting_grounds.append(hg.getListLink(srcs.hunting[i].hq, srcs.hunting[i].nq));
            }
            // duties
            for(var i in srcs.duties) {
                // var duty = MelsMaps.Selectable.getFull(srcs.duties[i]);
                // that.duties.append(duty.getListLink());
            }
            // treasure maps
            for(var i in srcs.maps) {
                // var map = srcs.maps[i];
                
                // var img = $('<img />')
                    // .attr('src', 'http://melodysmaps.com/icons/gold/treasure.png')
                    // .attr('width', 24)
                    // .attr('height', 24);
                // var li = $('<li></li>')
                    // .append(img)
                    // .append(map.map);
                // var ul = $('<ul></ul>')
                    // .appendTo(li);
                // for(var i in map.nodes) {
                    // var node = MelsMaps.Selectable.getFull(map.nodes[i]);
                    // ul.append(node.getListLink());
                // }
                // that.maps.append(li);
            }
            // recipe
            for(var i in srcs.uses) {
                // var recipe = MelsMaps.Selectable.getFull(srcs.uses[i]);
                // that.uses.append(recipe.getListLink());
            }
            // leves
            for(var i in srcs.leves) {
                // var leve = MelsMaps.Selectable.getFull(srcs.leves[i]);
                // that.leves.append(leve.getListLink());
            }
            
        });
	},
    
    _showAll: function() {
        var selectables = [];
        var name = this.item._resolvedInfo.name;
        this.nodes.find('li').each(function(i, li) {
            $(li).data('selectable')._addToMap(name);
        });
		this.merchants.find('li').each(function(i, li) {
            $(li).data('selectable')._addToMap(name);
        });
		this.hunting_grounds.find('li').each(function(i, li) {
            $(li).data('selectable')._addToMap(name);
        });
		this.duties.find('li').each(function(i, li) {
            $(li).data('selectable')._addToMap(name);
        });
        this.maps.find('li.melsmaps-item-source-link').each(function(i, li) {
            $(li).data('selectable')._addToMap(name);
        });
        this.hide();
	}
});