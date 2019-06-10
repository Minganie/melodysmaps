$.widget("melsmaps.recipeBox", $.melsmaps.lightbox, {
    _initLayout: function() {
        this.container.addClass('melsmaps-recipe-tooltip-container');
    },
    setRecipe: function(recipe) {
        this.recipe = recipe;
        this._reset();

        var that = this;
        this.recipe._full.then(function(recipe) {
            var html = Selectable.getRecipeTooltip(recipe);
            that.container.append(html);
        });

        this.show();
    },
    _reset: function() {
        this.container.find('.melsmaps-recipe-tooltip-container').remove();
    }
});