$.widget("melsmaps.dutyBox", $.melsmaps.lightbox, {
    
    _initLayout: function() {
        this.mapPane = $('<div></div>')
            .attr('id', 'duty-map')
            .addClass('melsmaps-duty-map')
            .appendTo(this.container);
        this.infoPane = $('<div></div>')
            .addClass('melsmaps-duty-info')
            .appendTo(this.container);
        $('<h1></h1>')
            .addClass('melsmaps-duty-info-header')
            .html('Chests of interest')
            .appendTo(this.infoPane);
        this.coiPane = $('<div></div>').appendTo(this.infoPane);
        this.coiPane.on('click', '.melsmaps-duty-coi', $.proxy(this._coiHandler, this));
        $('<h1></h1>')
            .addClass('melsmaps-duty-info-header')
            .html('Trash drops')
            .appendTo(this.infoPane);
        this.trashPane = $('<div></div>')
            .addClass("melsmaps-duty-trash")
            .appendTo(this.infoPane);
        
        this.map = L.map('duty-map', {
            maxBounds: [[51.5, 95.0], [57, 100.9]],
            minZoom: 6,
            maxZoom: 10,
            zoomControl: false
        }).setView([54,98], 7);
    },
    
    _coiHandler: function(evt) {
        var lyr = $(evt.currentTarget).data();
        var zoom = this.map.getZoom();
        this.map.flyTo(lyr.getLatLng(), (zoom+1 > 10 ? 10 : zoom+1) );
        lyr.openPopup();
    },
    
    setDuty: function(duty) {
        this.duty = duty;
        var name = duty._searchable.real_name;
        var mode = duty._searchable.mode;
        
        this._reset();
        
        this._setTiles(name, mode);
		var that = this;
		duty._full.then(function(full) {
            // console.log(full);
            that._addEncounters(full.modes[mode].encounters);
            that._addChests(full.modes[mode].chests);
            that._addChestsOfInterest(full.modes[mode].chests);
            that._addTrash(full.modes[mode].trash_drops);
		});
        this.show();
        this.map.invalidateSize();
        return this.map;
    },
    
    _reset: function() {
        this._chestCache = {};
        
        this.map.setView([54,98], 7);
        var m = this.map
        this.map.eachLayer(function(layer) {
            m.removeLayer(layer);
        });
        
        this.coiPane.empty();
        this.trashPane.empty();
    },
    
    _setTiles: function(name, mode) {
        // console.log("Requesting " + name + " (" + mode + ")");
        var modname = name.replace(/[\s-\(\)\.:']/g, '').toLowerCase();
        if(mode != 'Regular' && mode != 'Savage')
            modname += mode.toLowerCase();
    
        // console.log("Ready to request tiles for " + modname);
        var tiles = L.tileLayer('https://melodysmaps.com/duties/' + modname + '/{z}/{x}/{y}.png', {
            minZoom: 6,
            maxZoom: 10,
            tms: false
        });
        tiles.addTo(this.map);
    },
    
    _addEncounters: function(encounters) {
		var BossPopup = function(duty, encounter) {
			// console.log(duty);
			// console.log(encounter);
			this._duty = duty;
			this._encounter = encounter;
		};
		var that = this;
		BossPopup.prototype = $.extend({}, Selectable.HasPopup.prototype, {
			_getPopupHeader: function() {
				var hdiv = $('<div></div>');
				var img = $('<img src="icons/monster/agressive/elite.png" alt="" width=30 height=30 />');
				hdiv.append(img);
				var span = $('<span></span>');
				var h1 = $('<h1></h1>').html(this._encounter.encounter);
				var sep = $('<div></div>').addClass('leaflet-control-layers-separator');
				var subtitle = this._getPopupSubtitle();
				span.append(h1)
					.append(sep)
					.append(subtitle);
				hdiv.append(span);
				
				return hdiv;
			},
			_getPopupSubtitle: function() {
				// console.log(this._duty);
				var subtitle = $('<h2></h2>').html("Boss in " + this._duty.real_name + " (" + this._duty.mode + ")");
				return subtitle;
			},
			_getPopupContent: function() {
				var div = $('<div></div>');
				var ul = $('<ul class="melsmaps-dungeon-boss-popup"></ul>').appendTo(div);
				for(var i in this._encounter.tokens) {
					var token = this._encounter.tokens[i];
					var li = $('<li></li>');
					$('<span></span>')
						.html(token.qty + ' ')
						.appendTo(li);
					$('<img />')
						.attr({
							src: token.token.icon,
							width: 24,
							height: 24,
							alt: token.token.name + ' icon'
						})
						.appendTo(li);
					$('<span></span>')
						.html(token.token.name)
						.appendTo(li);
					
					ul.append(li);
				}
				div.append(that._makeItemList(this._encounter.items));
				return div;
			}
		});
		
        var points = [];
        for(var i in encounters) {
            var encounter = encounters[i];
            // console.log(encounter);
            if(encounter && encounter.items && encounter.geom && encounter.encounter) {
				// console.log(this);
				var boss = new BossPopup(this.duty._searchable, encounter);
				// console.log(boss);
                var popup = boss.getPopup({});
                var p = L.marker(encounter.geom[0][0], { icon: mapIcons.boss });
                p.bindTooltip(this._makeEncounterTooltip(encounter.encounter)[0], {
                    permanent: true,
                    className: 'melsmaps-duty-boss-tooltip'
                });
                p.bindPopup(popup);
                points.push(p);
            }
        }
        L.layerGroup(points).addTo(this.map);
    },
    
    _makeEncounterTooltip: function(name) {
        var icon = $('<img />')
            .attr({
                src: 'icons/monster/agressive/elite.png',
                width: 24,
                height: 24,
                alt: 'Boss nameplate icon'
            });
        return $('<span></span>')
            .append(icon)
            .append(name);
    },
    
    _makeItemList: function(items) {
        var html = $('<ul class="melsmaps-dungeon-boss-popup"></ul>');
        for(var i in items) {
            var item = items[i];
            // console.log(item);
			if(item && item.licon && item.name) {
                html.append(Selectable.getItemTooltippedLiWithInterest(item));
			}
        }
        return html;
    },
    
    _addChests: function(chests) {
		var ChestPopup = function(duty, chest) {
			// console.log(duty);
			// console.log(chest);
			this._duty = duty;
			this._chest = chest;
		};
		var that = this;
		ChestPopup.prototype = $.extend({}, Selectable.HasPopup.prototype, {
			_getPopupHeader: function() {
				var hdiv = $('<div></div>');
				var img = $('<img src="icons/map/chest.png" alt="" width=30 height=30 />');
				hdiv.append(img);
				var span = $('<span></span>');
				var h1 = $('<h1>Treasure Chest</h1>');
				var sep = $('<div></div>').addClass('leaflet-control-layers-separator');
				var subtitle = this._getPopupSubtitle();
				span.append(h1)
					.append(sep)
					.append(subtitle);
				hdiv.append(span);
				
				return hdiv;
			},
			_getPopupSubtitle: function() {
				// console.log(this._chest);
				var subtitle = $('<h2></h2>').html("Map Coordinates X: " + this._chest.x.toFixed(1) + " Y: " + this._chest.y.toFixed(1));
				return subtitle;
			},
			_getPopupContent: function() {
				var div = $('<div></div>');
				div.append(that._makeItemList(this._chest.items));
				return div;
			}
		});
		
        var points = [];
        for(var i in chests) {
            var chest = chests[i];
            if(chest && chest.items && chest.geom && chest.x && chest.y) {
				var zechestpopup = new ChestPopup(this.duty._searchable, chest);
                var popup = zechestpopup.getPopup();
                var p = L.marker(chest.geom[0][0], { icon: mapIcons.chest });
                p.bindPopup(popup);
                points.push(p);
                var xy = chest.x.toString() + chest.y.toString();
                this._chestCache[xy] = p;
            }
        }
        L.layerGroup(points).addTo(this.map);
    },
    
    _addChestsOfInterest: function(chests) {
        var ul = $('<ul></ul>');
        for(var i in chests) {
            var chest = chests[i];
            if(chest.coi) {
                var coi = chest;
                var xy = coi.x.toString() + coi.y.toString();
                var lyr = this._chestCache[xy];
                
                var li = $('<li></li>')
                    .addClass('melsmaps-duty-coi')
                    .html('Chest of interest [' + coi.x + ', ' + coi.y + ']');
                
                if(coi.items && coi.items.length > 0) {
                    var itemList = $('<ul></ul>').appendTo(li);
                    for(var j in coi.items) {
                        var item = coi.items[j];
                        itemList.append(Selectable.getItemTooltippedLiWithInterest(item));
                    }
                }
                li.appendTo(ul);
                li.data(lyr);
            }
        }
        ul.appendTo(this.coiPane);
    },
    
    _addTrash: function(trash) {
        var trashitems = [];
        for(var i in trash)
            trashitems.push(trash[i].item);
        var list = this._makeItemList(trashitems);
        this.trashPane.html(list);
    }
});