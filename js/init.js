function init(map) {
    // Global cause MappedDuty needs them too
    mapIcons = {
        merchant: L.icon({
            iconUrl: 'http://www.melodysmaps.com/icons/map/merchant.png',
            iconSize: [32, 32]
        }),
        
        aetheryte: L.icon({
            iconUrl: 'http://www.melodysmaps.com/icons/map/aetheryte.png',
            iconSize: [32, 32],
            tooltipAnchor: [16, -32]
        }),
        
        chocobo: L.icon({
            iconUrl: 'http://www.melodysmaps.com/icons/map/chocobo.png',
            iconSize: [32, 32]
        }),
        
        moogle: L.icon({
            iconUrl: 'http://www.melodysmaps.com/icons/map/moogle.png',
            iconSize: [32, 32]
        }),
        
        current: L.icon({
            iconUrl: 'http://www.melodysmaps.com/icons/map/current.png',
            iconSize: [32, 32]
        }),
        
        trial: L.icon({
            iconUrl: 'http://www.melodysmaps.com/icons/map/trial.png',
            iconSize: [28, 28],
            tooltipAnchor: [12, 0]
        }),
        
        dungeon: L.icon({
            iconUrl: 'http://www.melodysmaps.com/icons/map/dungeon.png',
            iconSize: [28, 28],
            tooltipAnchor: [12, 0]
        }),
        
        raid: L.icon({
            iconUrl: 'http://www.melodysmaps.com/icons/map/raid.png',
            iconSize: [28, 28],
            tooltipAnchor: [12, 0]
        }),
        
        boss: L.icon({
            iconUrl: 'http://www.melodysmaps.com/icons/map/boss.png',
            iconSize: [28, 28],
            tooltipAnchor: [12, 0]
        }),
        
        chest: L.icon({
            iconUrl: 'http://www.melodysmaps.com/icons/map/chest.png',
            iconSize: [28, 28],
            tooltipAnchor: [12, 0]
        })
    };
    
    api("regions").then(function(regions) {
        L.namedPolygonLayer(regions, {
            name: 'Regions',
            minZoom: 4,
            maxZoom: 6,
            inLegend: true,
            legendGroup: 'Base Layers',
            polygonStyle: {
                fillColor: '#ffffff',
                fillOpacity: 0.6,
                color: '#ffffff',
                opacity: 1,
                weight: 2
            },
            nameClass: 'region-names'
        }).addTo(map);
    });
    api("zones").then(function(zones) {
        L.namedPolygonLayer(zones, {
            name: 'Zones',
            minZoom: 6,
            maxZoom: 7,
            inLegend: true,
            legendGroup: 'Base Layers',
            polygonStyle: {
                fillOpacity: 0,
                color: '#eeeeee',
                opacity: 1,
                weight: 2
            },
            nameClass: 'zone-names'
        }).addTo(map);
    });
    api("areas").then(function(areas) {
        L.namedPolygonLayer(areas, {
            name: 'Areas',
            minZoom: 8,
            maxZoom: 10,
            inLegend: true,
            legendGroup: 'Base Layers',
            polygonStyle: {
                fillOpacity: 0,
                color: '#aaffff',
                opacity: 0.8,
                weight: 1
            },
            nameClass: 'area-names'
        }).addTo(map);
    });

    api("duties").then(function(duties) {
        L.dutyLayer(duties, {
            name: 'Duties', 
            icons: {
                trial: mapIcons.trial,
                dungeon: mapIcons.dungeon,
                raid: mapIcons.raid
            },
            minZoom: 7,
            maxZoom: 10,
            inLegend: true,
            legendGroup: 'Base Layers',
            pointStyle: {
                className: 'duty-names'
            }
        }).addTo(map);
    });
    
    api("aetherytes").then(function(aetherytes) {
        L.namedPointLayer(aetherytes, {
            name: 'Aetherytes', 
            minZoom: 7,
            maxZoom: 10,
            inLegend: true,
            legendGroup: 'Base Layers',
            pointStyle: {
                icon: mapIcons.aetheryte,
                className: 'aetheryte-names'
            }
        }).addTo(map);
    });
    
    api("chocobos").then(function(chocobos) {
        L.namedPointLayer(chocobos, {
            name: 'Chocobos', 
            minZoom: 7,
            maxZoom: 10,
            inLegend: true,
            legendGroup: 'Base Layers',
            searchable: {},
            pointStyle: {
                icon: mapIcons.chocobo,
                className: 'aetheryte-names'
            }
        }).addTo(map);
    });
    
    api("moogles").then(function(moogles) {
        L.namedPointLayer(moogles, {
            name: 'Moogles', 
            minZoom: 7,
            maxZoom: 10,
            inLegend: true,
            legendGroup: 'Base Layers',
            searchable: {},
            pointStyle: {
                icon: mapIcons.moogle,
                className: 'aetheryte-names'
            }
        }).addTo(map);
    });
}