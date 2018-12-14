L.Control.MelodysLegend = L.Control.GroupedLayers.extend({
	
	_addItem: function (obj) {
        // console.log(obj);
        // var name = (obj ? (obj.layer ? ( obj.layer.options ? obj.layer.options.name : '') : '') : '');
		// console.log("MelsLegend::_additem, map has layer " + name + "? " + this._map.hasLayer(obj.layer));
        
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
			if(obj && obj.layer) {
				// console.log(obj.layer._visible);
				input.disabled = (obj.layer ? (obj.layer._visible !== true) : false);
			}
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
					this._map.addLayer(obj.layer);
					// console.log(obj.layer.showOrHide);
					// console.log(this._map);
					if(obj.layer.showOrHide)
						obj.layer.showOrHide({target: this._map});
				} else if (!input.checked && this._map.hasLayer(obj.layer)) {
					this._map.removeLayer(obj.layer);
					if(obj.layer.hide)
						obj.layer.hide();
				}
			}
		}

		this._handlingClick = false;
	},

	_onNameClick: function (e) {
		var lay = this._getLayer(e.target.parentNode.layerId);
        // console.log(lay);
        // console.log(lay.layer);
        // console.log(lay.layer._tiles);
        // console.log(lay.layer.getBounds);
        if(lay && lay.layer && !lay.layer._tiles && lay.layer.getBounds) {
            var bounds = lay.layer.getBounds();
            this._map.once('zoomend', function(e) {
                if(lay.layer.getLayers) {
                    lay.layer.getLayers()[0].openPopup();
                } else {
                    lay.layer.openPopup();
                }
            });
            this._map.flyToBounds(bounds);
        }
	}
});

L.melodysLegend = function (baseLayers, groupedOverlays, options) {
    return new L.Control.MelodysLegend(baseLayers, groupedOverlays, options);
};