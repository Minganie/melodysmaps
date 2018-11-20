Selectable = {
    get: function(searchable) {
        switch(searchable.category.getName()) {
            case 'Item':
            default:
                return new Selectable.Item(searchable);
        }
    }
}
Selectable.prototype = {
    onSelect: function() {
        console.log("Selected this");
        console.log(this);
    }
}