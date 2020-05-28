$.widget('melsmaps.multiGeoms', {
	_create: function() {
		this.options.categories = ['Hunting Logs', 'Sightseeing Logs'];
		this.huntingLogs = {};
        this.sightseeingLogs = {};
        this.element.addClass('melsmaps-slide-out');
		for(var i in this.options.categories) {
			var cat = this.options.categories[i];
			var div = $('<div class="melsmaps-multigeom-category"></div>');
			div.append('<h1>'+cat+'</h1>');
			var ul = $('<ul class="melsmaps-accordeon"></ul>').appendTo(div);
			switch(cat) {
				case 'Hunting Logs':
					var that = this;
                    (function(ul) {
					api('hunting_logs')
					.fail(function(jqXHR, textStatus, errorThrown) {
						console.error("api call failed " + textStatus);
						console.error(errorThrown);
						console.error(jqXHR);
					})
					.then(function(hls) {
						// console.log("api returned hunting logs");
						for(var log in hls) {
							that.huntingLogs[log] = {};
							var li = $('<li>' + log + '</li>')
								.appendTo(ul);
							var sublist = $('<ul></ul>').appendTo(li);
							// console.log("Log is "+log);
							for(var rank in hls[log]) {
								that.huntingLogs[log][rank] = hls[log][rank];
								$('<li class="melsmaps-hunting-log-link">Rank <span>' + rank + '</span></li>').appendTo(sublist);
								// console.log("Rank is " + rank);
								// console.log("geojson is ");
								// console.log(hls[log][rank]);
							}
						}
					});
                    })(ul);
				break;
                case 'Sightseeing Logs':
                    var that = this;
                    (function(ul) {
                    api('sightseeing_logs')
                    .fail(function(jqXHR, textStatus, errorThrown) {
						console.error("api call failed " + textStatus);
						console.error(errorThrown);
						console.error(jqXHR);
					})
                    .then(function(ssls) {
                        for(var log in ssls) {
                            that.sightseeingLogs[log] = ssls[log];
                            var li = $('<li class="melsmaps-sightseeing-log-link">' + log + '</li>')
                                .appendTo(ul);
                        }
                    });
                    })(ul);
                break;
				default:
					console.error('Unsupported multi geom category: ' + cat);
			}
			this.element.append(div);
		}
		var hl = this.huntingLogs;
        var ssl = this.sightseeingLogs;
		this.element.on('click', '.melsmaps-hunting-log-link', function() {
			// console.log("hunting log was clicked");
			var rank = $(this).find('span').html();
			var log = $(this).parent().parent().contents().get(0).nodeValue;
			var features = hl[log][rank];
			// console.log(features);
			
			for(var i in features) {
				var feature = features[i];
				var poly = L.namedPolygonLayer([feature], {
					name: feature.name,
					minZoom: 7,
					maxZoom: 10,
					inLegend: true,
					polygonStyle: {},
					legendGroup: log + ' (rank ' + rank + ')',
					nameClass: 'melsmaps-tooltip',
					searchable: false
				}).addTo(melsmap);
			}
		});
        
		this.element.on('click', '.melsmaps-sightseeing-log-link', function() {
            var segmentName = $(this).text();
            var segment = ssl[segmentName];
            for(var i in segment) {
                var feature = segment[i];
                var point = L.namedPointLayer([feature], {
					name: feature.label,
					minZoom: 7,
					maxZoom: 10,
					inLegend: true,
                    pointStyle: {
                        icon: mapIcons.sightseeing,
                        className: 'aetheryte-names'
                    },
					legendGroup: segmentName,
					nameClass: 'melsmaps-tooltip',
					searchable: false
				}).addTo(melsmap);
                (function(feat, layer) {
                    var ss = Selectable.getFull(feat);
                    ss._full.then(function(full) {
                        layer.bindPopup(ss.getPopup(full));
                    });
                })(feature, point);
            }
        });
	}
});