Selectable.Recipe = {
    Source: {
        getLine: function(recipe) {
            var img = $('<img />')
                .attr('src', 'http://melodysmaps.com/icons/disciplines/' + recipe.discipline.toLowerCase() + '.png')
                .attr('width', 24)
                .attr('height', 24);
            var a = $('<a></a>')
                .attr('href', 'http://na.finalfantasyxiv.com/lodestone/playguide/db/recipe/' + recipe.lid)
                .html(recipe.name + ' (level ' + recipe.level + ')');
            var li = $('<li></li>')
                .append(img)
                .append(a)
                .attr('title', 'Click to view the recipe in the Lodestone');
            return li;
        }
    }
};