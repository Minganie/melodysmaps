api = function(type, id) {
    var url = 'api/' + type + '/' + (id ? id : '');
    // console.log("API request to '" + url + "'");
    return $.ajax({
        url: url,
        dataType: "json"
    }).then(function(data) {
        // console.log("API request just returned with data: ");
        // console.log(data);
		if(Object.prototype.toString.call(data) === '[object Array]') {
			for(var i in data) {
				var d = data[i];
				if(d && d.category) {
					d.category = new Category(d.category);
				}
			}
		} else
			if(data && data.category)
				data.category = new Category(data.category);
        // console.log("After touchup, data is: ");
        // console.log(data);
		return data;
	});
};

// ITEM
api.item = {};
api.item.info = function(lid) {
    return api("items", lid);
}
api.item.sources = function(lid) {
    return $.ajax({
        url: "api/items/" + lid + "/sources",
        dataType: "json"
    }).then(function(typessources) {
		
		for(var i in typessources) {
			var typessource = typessources[i];
			for(var j in typessource) {
				var source = typessource[j];
				if(source && source.category)
					source.category = new Category(source.category);
                if(source && source.hg && source.hg.category)
                    source.hg.category = new Category(source.hg.category);
                if(source && source.map) {
                    for(var k in source.nodes) {
                        source.nodes[k].category = new Category(source.nodes[k].category);
                    }
                }
			}
		}
		return typessources;
	});
}