L.Control.MelodysLegend = L.Control.GroupedLayers.extend({
	_melsLayerList: [],
	_initLayout: function (baseLayers, groupedOverlays, options) {
		L.Control.GroupedLayers.prototype._initLayout.call(this);
		
		var ze_map = this._map;
		
		// per https://gis.stackexchange.com/questions/104507/disable-panning-dragging-on-leaflet-map-for-div-within-map/106777
		// Disable dragging when user's cursor enters the element
		this.getContainer().addEventListener('mouseover', function () {
			ze_map.dragging.disable();
		});

		// Re-enable dragging when user's cursor leaves the element
		this.getContainer().addEventListener('mouseout', function () {
			ze_map.dragging.enable();
		});
	},
	
	_addItem: function (obj) {
		
		var label = document.createElement('div'),
		  input,
		  checked = this._map.hasLayer(obj.layer),
		  container,
		  groupRadioName;

		if (obj.overlay) {
		  if (obj.group.exclusive) {
			groupRadioName = 'leaflet-exclusive-group-layer-' + obj.group.id;
			input = this._createRadioElement(groupRadioName, checked);
		  } else {
			input = document.createElement('input');
			input.type = 'checkbox';
			
			input.className = 'leaflet-control-layers-selector';
			input.defaultChecked = checked;
		  }
		} else {
		  input = this._createRadioElement('leaflet-base-layers', checked);
		}

		input.layerId = L.Util.stamp(obj.layer);
		input.groupID = obj.group.id;
		L.DomEvent.on(input, 'click', this._onInputClick, this);

		var name = document.createElement('span');
		name.layerId = L.Util.stamp(obj.layer);
		name.innerHTML = ' ' + obj.name;
		L.DomEvent.on(name, 'click', this._onNameClick, this);

		label.appendChild(input);
		label.appendChild(name);

		if (obj.overlay) {
		  container = this._overlaysList;

		  var groupContainer = this._domGroups[obj.group.id];

		  // Create the group container if it doesn't exist
		  if (!groupContainer) {
			groupContainer = document.createElement('div');
			groupContainer.className = 'leaflet-control-layers-group';
			groupContainer.id = 'leaflet-control-layers-group-' + obj.group.id;

			var groupLabel = document.createElement('label');
			groupLabel.className = 'leaflet-control-layers-group-label';

			if (obj.group.name !== '' && !obj.group.exclusive) {
			  // ------ add a group checkbox with an _onInputClickGroup function
			  if (this.options.groupCheckboxes) {
				var groupInput = document.createElement('input');
				groupInput.type = 'checkbox';
				groupInput.className = 'leaflet-control-layers-group-selector';
				groupInput.groupID = obj.group.id;
				groupInput.legend = this;
				groupInput.checked = true;
				L.DomEvent.on(groupInput, 'click', this._onGroupInputClick, groupInput);
				groupLabel.appendChild(groupInput);
			  }
			}

			var groupName = document.createElement('span');
			groupName.className = 'leaflet-control-layers-group-name';
			groupName.innerHTML = obj.group.name;
			groupLabel.appendChild(groupName);

			groupContainer.appendChild(groupLabel);
			container.appendChild(groupContainer);

			this._domGroups[obj.group.id] = groupContainer;
		  }

		  container = groupContainer;
		} else {
		  container = this._baseLayersList;
		}
		
		container.appendChild(label);

		return label;
	},
	
	_onInputClick: function (e) {
        // console.log(e.target);
		var i, input, obj,
		inputs = this._form.getElementsByTagName('input'),
		inputsLen = inputs.length;

		this._handlingClick = true;

		for (i = 0; i < inputsLen; i++) {
			input = inputs[i];

			if (input.className === 'leaflet-control-layers-selector') {
				obj = this._getLayer(input.layerId);
				if (input.checked && !this._map.hasLayer(obj.layer)) {
					obj.layer.checked=true;
					this._map.addLayer(obj.layer);
					// console.log(obj.layer.showOrHide);
					// console.log(this._map);
					if(obj.layer.showOrHide)
						obj.layer.showOrHide({target: this._map});
				} else if (!input.checked && this._map.hasLayer(obj.layer)) {
					obj.layer.checked=false;
					this._map.removeLayer(obj.layer);
					if(obj.layer.hide)
						obj.layer.hide();
				} else if(!input.checked) {
					obj.layer.checked = false;
				}
			}
		}

		this._handlingClick = false;
	},
	
	_onGroupInputClick: function () {
		// console.log("group input click");
		var i, input, obj;

		var this_legend = this.legend;
		this_legend._handlingClick = true;

		var inputs = this_legend._form.getElementsByTagName('input');
		var inputsLen = inputs.length;

		for (i = 0; i < inputsLen; i++) {
			input = inputs[i];
			// console.log(input);
			if (input.groupID === this.groupID && input.className === 'leaflet-control-layers-selector') {
				// console.log("input is part of this group?");
				input.checked = this.checked;
				obj = this_legend._getLayer(input.layerId);
				if (input.checked && !this_legend._map.hasLayer(obj.layer)) {
					// console.log("adding a layer");
					obj.layer.checked = true;
					this_legend._map.addLayer(obj.layer);
				} else if (!input.checked && this_legend._map.hasLayer(obj.layer)) {
					// console.log("removing a layer");
					obj.layer.checked = false;
					this_legend._map.removeLayer(obj.layer);
				} else if(!input.checked) {
					obj.layer.checked=false;
				}
			}
		}

		this_legend._handlingClick = false;
	},

	_onNameClick: function (e) {
		var lay = this._getLayer(e.target.parentNode.layerId);
        // console.log(lay);
        // console.log(lay.layer);
        // console.log(lay.layer._tiles);
        // console.log(lay.layer.getBounds);
        if(lay && lay.layer && !lay.layer._tiles && lay.layer.getBounds) {
            var bounds = lay.layer.getBounds();
			var zeMap = this._map;
            this._map.once('zoomend', function(e) {
				if(zeMap.hasLayer(lay.layer) && lay.layer.getCenter) {
					if(lay.layer.getLayers) {
						lay.layer.getLayers()[0].openPopup();
					} else {
						lay.layer.openPopup();
					}
				}
            });
            this._map.flyToBounds(bounds);
        }
	},
	
	addOverlay: function(layer, name, group) {
		var melsId = group + name;
		if(this._melsLayerList.includes(melsId)) {
			this._map.flyToBounds(layer.getBounds());
		} else {
			this._melsLayerList.push(melsId);
			this._addLayer(layer, name, group, true);
			this._update();
		}
		return this;
	}
});

L.melodysLegend = function (baseLayers, groupedOverlays, options) {
    return new L.Control.MelodysLegend(baseLayers, groupedOverlays, options);
};