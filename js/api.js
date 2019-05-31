api = function(type, id) {
    var url = 'api/' + type + '/' + (id ? id : '');
    console.log("API request to '" + url + "'");
    // var start = new Date();
    return $.ajax({
        url: url,
        dataType: "json"
    }).then(function(data) {
        // console.log("API request just returned with data: ");
        // console.log(data);
        // console.log("API call answered after " + (new Date() - start) + " ms");
		if(Object.prototype.toString.call(data) === '[object Array]') {
			for(var i in data) {
				var d = data[i];
				if(d && d.category) {
					d.category = new Category(d.category);
				}
                if(d && d.requirement) {
                    d.requirement = new Requirement(d.requirement);
                }
			}
		} else
			if(data && data.category)
				data.category = new Category(data.category);
            if(data && data.requirement)
                data.requirement = new Requirement(data.requirement);
        // console.log("After touchup, data is: ");
        // console.log(data);
        // console.log("API call + data touchup took " + (new Date() - start) + " ms");
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