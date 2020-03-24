function api(type, id) {
    var zeapi = this;
    var url = 'api/' + type + '/' + (id ? id : '');
    // console.log("API request to '" + url + "'");
    // var start = new Date();
    return $.ajax({
        url: url,
        dataType: "json"
    }).then(function(data) {
        if(data) {
            // console.log("API request just returned with data: ");
            // console.log(data);
            // console.log("API call answered after " + (new Date() - start) + " ms");
            if(Object.prototype.toString.call(data) === '[object Array]') {
                for(var i in data) {
                    var d = data[i];
                    api.util.objectify(d);
                }
            } else {
                api.util.objectify(data);
            }
            // console.log("After touchup, data is: ");
            // console.log(data);
            // console.log("API call + data touchup took " + (new Date() - start) + " ms");
        } else {
            console.error("data was null");
        }
        return data;
    });
}
api.util = {
    objectify: function(data) {
        if(data && data.category)
            data.category = new Category(data.category);
        if(data && data.requirement)
            data.requirement = new Requirement(data.requirement);
        if(data && data.spawns) {
            for(var i in data.spawns) {
                var spawn = data.spawns[i];
                if(spawn && spawn.requirement)
                    spawn.requirement = new Requirement(spawn.requirement);
            }
        }
        return data;
    }
};
// ITEM
api.item = {
    info: function(lid) {
        return api("items", lid);
    },
    sources: function(lid) {
        var zeapi = api;
        return $.ajax({
            url: "api/items/" + lid + "/sources",
            dataType: "json"
        }).then(function(typessources) {
            
            for(var i in typessources) {
                var typessource = typessources[i];
                for(var j in typessource) {
                    var source = typessource[j];
                    zeapi.util.objectify(source);
                    if(source && source.hg && source.hg.category)
                        source.hg.category = new Category(source.hg.category);
                    if(source && source.map) {
                        for(var k in source.nodes) {
                            source.nodes[k].category = new Category(source.nodes[k].category);
                        }
                    }
                }
                // console.log(typessources);
            }
            return typessources;
        });
    }
};