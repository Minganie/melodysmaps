L.Map.MelodysMap = L.Map.extend({
    _layerControl: null,
	_dutyLayers: {},
    
    initialize: function(el, options) {
        
        L.Map.prototype.initialize.call(this, el, options);
        
        setInterval(function() {
            $(map).trigger('tick', gt.time.melodysGetTime());
        }, 5000);
        
        this.whenReady(function() {
            this._layerControl = L.melodysLegend({}, {}, {collapsed: false, groupCheckboxes: true});
            this.addControl(this._layerControl);
            var c = this._layerControl;
            this.on('zoomend', function(e) {
                setTimeout(function() { // HAK HAK HAK
                    c._update();
                }, 200);
            }, this);
            
            
            // DUTIES HANDLER
            $('.leaflet-popup-pane').on('click', '.melsmaps-duties-link', function(evt) {
                var el = evt.currentTarget;
                var name = $(el).find('span.duty-name').html();
                var mode = $(el).find('span.duty-mode').html();
                var cat = $(el).find('span.duty-cat').html();
                api("categories", cat).then(function(cat) {
                    var category = new Category(cat);
                    var request =  {
                        name: name,
                        real_name: name,
                        mode: mode,
                        category: category
                    };
                    Selectable.get(request).onSelect();
                });
            });
            
            // MERCHANTS HANDLER
            $('#map').on('click', '.melsmaps-merchant-popup ul li.available', function(e) {
				matches = e.target.className.match(/tab-name-(\d)(?:-(\d)(?:-(\d))?)?/);
				var i = matches[1];
				var j = matches[2];
				var k = matches[3];
				
                // Make all tab names inactive
				$('.melsmaps-merchant-popup ul li').removeClass('active');
				// Make all tabs inactive
				$('.melsmaps-merchant-popup .tab-content').removeClass('active');
				
				// Reactive the right things
				if(!k) k=0;
				if(!j) j=0;
				if(!i) i=0;
				$('.melsmaps-merchant-popup ul li.tab-name-' + i + '-' + j + '-' + k).addClass('active');
				$('.melsmaps-merchant-popup div.tab-content-' + i + '-' + j + '-' + k).addClass('active');
				$('.melsmaps-merchant-popup ul li.tab-name-' + i + '-' + j).addClass('active');
				$('.melsmaps-merchant-popup div.tab-content-' + i + '-' + j).addClass('active');
				$('.melsmaps-merchant-popup ul li.tab-name-' + i).addClass('active');
				$('.melsmaps-merchant-popup div.tab-content-' + i).addClass('active');
            });
            
            // TOOLTIP HANDLERS
            function setTooltipText(evt, id) {
                // console.log(evt);
                var tt = evt.currentTarget.attributes['data-melsmaps-tooltip'].nodeValue;
				// console.log(tt);
                $(id).html(tt);
            }
            
            function moveTooltip(evt, id) {
                var pos = getPos(evt, id);
                var trans = "translate(" + pos.x + "px, " + pos.y + "px)";
                $(id)
                    .css("transform", trans)
                    .css("display", "block");
            }
            
            function getPos(evt, id) {
                function isMouseInX(x, left, right) {
                    return left < x && x < right;
                }
                function isMouseInY(y, top, bottom) {
                    return top < y && y < bottom;
                }
                var x = evt.originalEvent.clientX;
                var y = evt.originalEvent.clientY;
                var maxx = $(document).width();
                var maxy = $(document).height();
                var twidth = $(id).width();
                var theight = $(id).height();
                
                // Is the tooltip going to overflow the window? push right and down
                var truex = Math.min(x, maxx - twidth);
                var truey = Math.min(y, maxy - theight);
                
                var left = false;
                var above = false;
                
                if(isMouseInX(x, truex, truex+twidth)) {
                    // console.log("Moving the tooltip to the left of the cursor");
                    truex = Math.max(0, x-twidth-10);
                    left = true;
                }
                if(isMouseInY(y, truey, truey+theight)) {
                    // console.log("Moving the tooltip to above the cursor");
                    truey = Math.max(0, y-theight-10);
                    above = true;
                }
                // console.log("Final position: (" + truex + ", " + truey + ")");
                return {
                    x: truex + (left ? -10 : 10),
                    y: truey + (above ? -10 : 10)
                }
            }
            
			// Item tooltip handler
            $('#map').on('mouseenter', '.melsmaps-is-a-tooltip', function(evt) {
                setTooltipText(evt, '#item-tooltip');
                moveTooltip(evt, '#item-tooltip');
            });
            $('#map').on('mouseleave', '.melsmaps-is-a-tooltip', function(evt) {
                $('#item-tooltip')
                    .css("display", "none");
            });
            $('#duty').on('mouseenter', '.melsmaps-is-a-tooltip', function(evt) {
                setTooltipText(evt, '#item-tooltip');
                moveTooltip(evt, '#item-tooltip');
            });
            $('#duty').on('mouseleave', '.melsmaps-is-a-tooltip', function(evt) {
                $('#item-tooltip')
                    .css("display", "none");
            });
            $('#leve').on('mouseenter', '.melsmaps-is-a-tooltip', function(evt) {
                setTooltipText(evt, '#item-tooltip');
                moveTooltip(evt, '#item-tooltip');
            });
            $('#leve').on('mouseleave', '.melsmaps-is-a-tooltip', function(evt) {
                $('#item-tooltip')
                    .css("display", "none");
            });
            $('#quest').on('mouseenter', '.melsmaps-is-a-tooltip', function(evt) {
                setTooltipText(evt, '#item-tooltip');
                moveTooltip(evt, '#item-tooltip');
            });
            $('#quest').on('mouseleave', '.melsmaps-is-a-tooltip', function(evt) {
                $('#item-tooltip')
                    .css("display", "none");
            });
            
            
			// Leve tooltip handler
            $('#map').on('mouseenter', '.melsmaps-is-a-leve-tooltip', function(evt) {
                setTooltipText(evt, '#leve-tooltip');
                moveTooltip(evt, '#leve-tooltip');
            });
            $('#map').on('mouseleave', '.melsmaps-is-a-leve-tooltip', function(evt) {
                $('#leve-tooltip')
                    .css("display", "none");
            });
            
            // Recipe tooltip handler
            $('#item').on('mouseenter', '.melsmaps-recipe-tooltip', function(evt) {
                setTooltipText(evt, '#recipe-tooltip');
                moveTooltip(evt, '#recipe-tooltip');
            });
            $('#item').on('mouseleave', '.melsmaps-recipe-tooltip', function(evt) {
                $('#recipe-tooltip')
                    .css("display", "none");
            });
			
			// FISHING POPUP handler
			this.on('popupopen', function(e) {
				var div = $(e.popup._content).find('.melsmaps-fishing-popup');
				var fishConditions = {};
				if(div && div.length > 0) {
					// Cache the fish conditions
					div.find('.melsmaps-fish').each(function(i, th) {
						var fishlid = $(th).attr('data-melsmaps-fish');
						fishConditions[fishlid] = api('fish', fishlid)
							.done(function(conds) { return conds; })
							.fail(function(x, t, e) {
								console.error("Something happened while trying to fetch fishing conditions for " + f);
							});
					});
					var clock = div.find('.melsmaps-fishing-clock');
					var weather = div.find('.melsmaps-fishing-weather-watcher');
					this.intervalId = setInterval(function() {
						var h = gt.time.melodysGetTime();
						clock.html(h);
						var zone = weather.attr('data-melsmaps-zone');
						if(zone.indexOf('Gridania') !== -1)
							zone = 'Gridania';
						var sky = gt.skywatcher.getViewModel()[zone];
						weather.css('background', 'url("icons/weather/' + sky[1] + '.png") no-repeat 5px center');
						weather.html(sky[1]);
						var node = div.parent().parent().find('h1').first().text();
						
						// fishes
						div.find('.melsmaps-fish').each(function(i, th) {
							(function(th) {
								var fishlid = $(th).attr('data-melsmaps-fish');
								fishConditions[fishlid].then(function(info) {
									if(Fish.isFishable(info, zone)) {
										// Restrictions met
										$(th).find('.melsmaps-fishing-light').addClass('green').removeClass('red');
									} else {
										$(th).find('.melsmaps-fishing-light').addClass('red').removeClass('green');
									}
								});
							})(th, zone);
						});
					}, 1000);
				}
			});
			// Fishing popup handler
			this.on('popupclose', function(e) {
				if(this.intervalId)
					clearInterval(this.intervalId);
			});
        }, this);
    },
    
    getLayerControl: function() {
        return _layerControl;
    },
    
    addLayer: function(layer) {
        // console.log("Map::addLayer " + (layer && layer.options && layer.options.name ? layer.options.name : 'Noname'));
        // console.log(layer);
		var _dutyLayers = this._dutyLayers;
        
        if(layer && layer.options && layer.options.inLegend) {
                
            var label = (layer.getLegendLabel ? layer.getLegendLabel() : (layer.options.name || ''));
            var group = (layer.getLegendGroup ? layer.getLegendGroup() : (layer.options.group || 'Misc'));
			
			
            // console.log("Add layer " + layer.options.name + 
                // " (" + (layer instanceof L.TileLayer ? 'Tile' : 'Overlay') + ") to legend in " + group);
            
            if(!layer.isInLegend) {
                layer.isInLegend = true;
                
                if(layer instanceof L.TileLayer) {
                    this._layerControl.addBaseLayer(layer, label, group);
                } else if(layer instanceof L.Layer.DutyLayer) {
                    for(var i in layer.getLayers()) {
						layer.getLayers()[i].eachLayer(function(lay) {
							var name = lay.getTooltip().getContent();
							_dutyLayers[name] = lay;
						});
                        var l = layer.getLayers()[i];
                        var label = (l.options ? (l.options.label || '') : (l.options.name || ''));
                        group = (group == 'Misc' ? 'Base Layers' : group);
                        this._layerControl.addOverlay(l, label, group);
                    }
                } else {
                    this._layerControl.addOverlay(layer, label, group);
                }
            }
        }
		// console.log(this);
		// console.log(layer);
		// console.log(L.Map.prototype.addLayer);
        L.Map.prototype.addLayer.call(this, layer);
    },
    
    removeLayer: function(layer) {
        // layer.isInLegend = false;
        L.Map.prototype.removeLayer.call(this, layer);
    },
    
    hasLayer: function(layer) {
        // console.log(layer.options);
        // var name = (layer ? (layer.options ? layer.options.name: ''): '');
        var vanilla = L.Map.prototype.hasLayer.call(this, layer);
        var visibility = true; //(layer._visible !== false);
        // if(name)
            // console.log("MelsMap has layer " + name + " of vanilla " + vanilla + " and visibility " + visibility);
        return vanilla && visibility;
    },
	
	getDutyLayer: function(name) {
        if(!this._dutyLayers[name].getBounds) {
            this._dutyLayers[name].getBounds = (function(layer) {
                return function() {return layer.getLatLng().toBounds(300);};
            })(this._dutyLayers[name]);
        }
		return this._dutyLayers[name];
	}
    
});

L.melodysMap = function (el, options) {
    return new L.Map.MelodysMap(el, options);
};