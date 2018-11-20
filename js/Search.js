$.widget('melsmaps.Search', $.ui.autocomplete, {
    
    options: {
        minLength: 2,
        
        source: function(request, response) {
            $.ajax({
                url: "api/search/" + request.term,
                dataType: "json"
            }).then(function(searchables) {
				for(var i in searchables) {
					var searchable = searchables[i];
					// console.log(searchable);
					searchable.category = new Category(searchable.category);
				}
				response(searchables);
            });
        },
        
        select: function(event, ui) {
            // console.log(ui.item);
            Selectable.get(ui.item).onSelect();
        },
        
        _renderItem: function (ul, item) {
            var li = $( "<li></li>" )
                .attr( "data-value", item.value )
                .append(item.category.getRedIcon())
                .append($('<span></span>').html(item.name).attr('title', item.category.getTooltip()))
                .appendTo(ul);
            return li;
        }
    },
    
    _init: function() {
        this.source = (this.options ? (this.options.source || null) : null);
        this._renderItem = (this.options ? (this.options._renderItem || null) : null);
        return this._super();
    }

});