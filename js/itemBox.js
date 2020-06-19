$.widget('melsmaps.itemBox', $.melsmaps.lightbox, {
	_intervalId: 0,
	
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
        this.cardContainer = $('<div></div>')
            .addClass('melsmaps-item-card-info')
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
	
	show: function() {
		this._super();
		var that = this;
		this._intervalId = setInterval(function() {
			that.nodes.find('li.melsmaps-fishing-source').each(function(i, li) {
				var conditions = $(li).data('fishing-conditions');
				var zoneName = $(li).data('zone-name');
				var light = $($(li).find('.melsmaps-fishing-light').get(0));
				if(Fish.isFishable(conditions, zoneName)) {
					light.addClass('green').removeClass('red');
				} else {
					light.addClass('red').removeClass('green');
				}
			});
		}, 1000);
	},
	hide: function() {
		this._super();
		clearInterval(this._intervalId);
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
		this._setSubtitle(nodes, 'icons/sections/gathered.png', 'gathered at');
		this.nodes = $('<ul></ul>').appendTo(nodes);
		
		// BUYING AT MERCHANT
		var merchants = $('<div></div>')
			.appendTo(left);
		this._setSubtitle(merchants, 'icons/sections/bought.png', 'bought at');
		this.merchants = $('<ul></ul>').appendTo(merchants);
			
		// CRAFTING
		var crafters = $('<div></div>')
			.appendTo(left);
		this._setSubtitle(crafters, 'icons/sections/crafted.png', 'crafted by');
		this.crafters = $('<ul></ul>').appendTo(crafters);
        
        // HG
		var hunting_grounds = $('<div></div>')
			.appendTo(middle);
		this._setSubtitle(hunting_grounds, 'icons/sections/hunted.png', 'dropped off');
		this.hunting_grounds = $('<ul></ul>').appendTo(hunting_grounds);
        
        // DUTIES
		var duties = $('<div></div>')
			.appendTo(middle);
		this._setSubtitle(duties, 'icons/sections/dungeonned.png', 'looted in');
		this.duties = $('<ul></ul>').appendTo(duties);
        
        // LEVES
        var leves = $('<div></div>')
            .appendTo(middle);
        this._setSubtitle(leves, 'icons/sections/leved.png', 'rewarded for');
        this.leves = $('<ul></ul>').appendTo(leves);
        
        // TREASURE MAPS
		var maps = $('<div></div>')
			.appendTo(middle);
		this._setSubtitle(maps, 'icons/sections/treasured.png', 'found with');
		this.maps = $('<ul></ul>').appendTo(maps);
        
        // TRIAD MATCHES
		var triads = $('<div></div>')
			.appendTo(right);
        this._setSubtitle(triads, 'icons/sections/leved.png', 'won from');
        this.triads = $('<ul></ul>').appendTo(triads);
        
        // USED IN
		var uses = $('<div></div>')
			.appendTo(right);
		this._setSubtitle(uses, 'icons/sections/reagent.png', 'used in');
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
        this.cardContainer.empty();
        this.nodes.empty();
        this.merchants.empty();
        this.crafters.empty();
        this.hunting_grounds.empty();
        this.duties.empty();
        this.maps.empty();
        this.uses.empty();
        this.leves.empty();
        this.triads.empty();
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
            // console.log(sources);
            
            that._reset();
            
            // SPECIAL SUPPLEMENTARY INFO FOR FISHES
			// console.log(info);
            that._printFishingConditions(info.fish_conditions);
            that._printTriadCard(info.card);
            
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
                    .attr('src', 'icons/gold/treasure.png')
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
            // Triple Triad sources
            // console.log(sources.triad);
            if(sources.triad.first_deck) {
                that.triads.append($('<p>Part of the initial Triple Triad deck</p>'));
            }
            if(sources.triad.tournament) {
                that.triads.append($('<p>1st to 3rd prizes in Triple Triad Tournament: ' + sources.triad.tournament + '</p>'));
            }
            if(sources.triad.npcs && sources.triad.npcs.length > 0 && sources.triad.npcs[0]) {
                for(var i in sources.triad.npcs) {
                    var li = Selectable.getSourceLine(sources.triad.npcs[i]);
                    that.triads.append(li);
                }
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
            that.triads.find('li').each(function(i, li) {
                $(li).data('selectable')._addToMap(name);
            });
        });
        this.hide();
	},
	
	_printFishingConditions(fishConditions) {
		if(fishConditions) {
			if(fishConditions.start_time !== null && fishConditions.end_time !== null) {
				var ts = Date.now();
				var canvas = $('<div class="melsmaps-fishing-clock-container"><canvas id="c' + ts + '"></canvas></div>')
					.appendTo(this.fishContainer);
				var ctx = document.getElementById('c' + ts).getContext('2d');
				var clockData;
				if(fishConditions.start_time < fishConditions.end_time) {
					clockData = {
						datasets: [{
							data: [fishConditions.start_time, fishConditions.end_time-fishConditions.start_time, 24-fishConditions.end_time],
							backgroundColor: ['black', 'green', 'black'],
							borderWidth: 0,
							label: 'Fishing clock'
						}],
						labels: [
							"Not fishable 00:00 to " + fishConditions.start_time + ":00",
							"Fishable " + fishConditions.start_time + ":00 to " + fishConditions.end_time + ":00",
							"Not fishable " + fishConditions.end_time + ":00 to 24:00"
						]
					};
				} else {
					clockData = {
						datasets: [{
							data: [fishConditions.end_time, fishConditions.start_time-fishConditions.end_time, 24-fishConditions.start_time],
							backgroundColor: ['green', 'black', 'green'],
							borderWidth: 0,
							label: 'Fishing clock'
						}],
						labels: [
							"Fishable 00:00 to " + fishConditions.end_time + ":00",
							"Not fishable " + fishConditions.end_time + ":00 to " + fishConditions.start_time + ":00",
							"Fishable " + fishConditions.start_time + ":00 to 24:00",
						]
					};
				}
				var clock = new Chart(ctx, {
					type: 'pie',
					data: clockData,
					options: {
						responsive: true,
						maintainAspectRatio: false,
						animation: {
							duration: 0
						},
						legend: {
							display: false
						}
					}
				});
			}
			if(fishConditions.snagging || fishConditions.folklore || fishConditions.fish_eyes || fishConditions.curr_weathers || fishConditions.predator) {
				var div = $('<div></div>').appendTo(this.fishContainer);
				if(fishConditions.snagging) {
					div.append($('<div><p><img src="icons/fishing/snagging.png" width=24 height=24 alt="" style="vertical-align: middle; margin-right: 0.5rem;">Requires snagging</p></div>'));
				}
				if(fishConditions.folklore) {
					div.append($('<div><p><img src="icons/fishing/folklore.png" width=24 height=24 alt="" style="vertical-align: middle; margin-right: 0.5rem;">Requires a tome of regional folklore</p></div>'));
				}
				if(fishConditions.fish_eyes) {
					div.append($('<div><p><img src="icons/fishing/fisheyes.png" width=24 height=24 alt="" style="vertical-align: middle; margin-right: 0.5rem;">Requires Fish Eyes</p></div>'));
				}
				if(fishConditions.curr_weathers && fishConditions.prev_weathers) {
					var s = '<div><p>';
					var pws = '';
					for(var i in fishConditions.prev_weathers) {
						var w = fishConditions.prev_weathers[i];
						s += '<img src="icons/weather/' + w + '.png" width=24 height=24 alt="" style="vertical-align: middle;">';
						if(i == fishConditions.prev_weathers.length - 2) {
							pws += w + ' or ';
						} else if(i < fishConditions.prev_weathers.length - 2) {
							pws += w + ', ';
						} else {
							pws += w;
						}
					}
					s += '->';
					var cws = '';
					for(var i in fishConditions.curr_weathers) {
						var w = fishConditions.curr_weathers[i];
						s += '<img src="icons/weather/' + w + '.png" width=24 height=24 alt="" style="vertical-align: middle;">';
						if(i == fishConditions.curr_weathers.length - 2) {
							cws += w + ' or ';
						} else if(i < fishConditions.curr_weathers.length - 2) {
							cws += w + ', ';
						} else {
							cws += w;
						}
					}
					s += '<span style="margin-left:0.5rem;">Only fishable during ' + cws + ' following ' + pws + '</span></p></div>';
					div.append($(s));
				} else if(fishConditions.curr_weathers) {
					var s = '<div><p>';
					var cws = '';
					for(var i in fishConditions.curr_weathers) {
						var w = fishConditions.curr_weathers[i];
						s += '<img src="icons/weather/' + w + '.png" width=24 height=24 alt="" style="vertical-align: middle;">';
						if(i == fishConditions.curr_weathers.length - 2) {
							cws += w + ' or ';
						} else if(i < fishConditions.curr_weathers.length - 2) {
							cws += w + ', ';
						} else {
							cws += w;
						}
					}
					s += '<span style="margin-left:0.5rem;">Only fishable during ' + cws + '</span></p></div>';
					div.append($(s));
				}
				if(fishConditions.predator) {
					var s = '<div>Must first fish:';
					for(var i in fishConditions.predator) {
						var prey = fishConditions.predator[i];
						s += '<p style="margin-left: 1rem;">' + prey.n + 'x <img src="' + prey.prey.licon + '" width=24 height=24 alt="" style="vertical-align: middle; margin-right:0.5px"> ' + prey.prey.name + '</p>';
					}
					s += '</div>';
					div.append($(s));
				}
			}
		}
	},
    
    _printTriadCard(card) {
        if(card) {
            var tt = Selectable.Triad.Card.Tooltip.get(card);
            this.cardContainer.append(tt.getCard());
        }
    }
});