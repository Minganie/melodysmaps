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
			// var duty = full.modes[mode];
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
        var modname = name.replace(/[\s-\(\)\.']/g, '').toLowerCase();
        if(mode != 'Regular' && mode != 'Savage')
            modname += mode.toLowerCase();
    
        // console.log("Ready to request tiles for " + modname);
        var tiles = L.tileLayer('http://melodysmaps.com/duties/' + modname + '/{z}/{x}/{y}.png', {
            minZoom: 6,
            maxZoom: 10,
            tms: false
        });
        tiles.addTo(this.map);
    },
    
    _addEncounters: function(encounters) {
        // console.log(encounters);
        var points = [];
        for(var i in encounters) {
            var encounter = encounters[i];
            // console.log(encounter);
            if(encounter && encounter.items && encounter.geom && encounter.encounter) {
                var popup = this._makeItemList(encounter.items)[0];
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
                src: 'http://www.melodysmaps.com/icons/monster/agressive/elite.png',
                width: 24,
                height: 24,
                alt: 'Boss nameplate icon'
            });
        return $('<span></span>')
            .append(icon)
            .append(name);
    },
    
    _makeItemList: function(items) {
        var html = $('<ul></ul>');
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
        var points = [];
        for(var i in chests) {
            var chest = chests[i];
            if(chest && chest.items && chest.geom && chest.x && chest.y) {
                var popup = this._makeItemList(chest.items);
                var p = L.marker(chest.geom[0][0], { icon: mapIcons.chest });
                p.bindPopup(popup[0]);
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