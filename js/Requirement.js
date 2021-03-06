Requirement = function(requirement) {
    var iconSize = 32;
    
    return {
        classy: 'Requirement',
        name: requirement.pretty_name,
        getDiv: function() {
            if(requirement && requirement.name) {
                var type = (requirement.icon.includes('traits') ? 'trait' : 'FATE');
                var html = $('<div></div>')
                    .addClass('req')
                    .attr('title', 'Requires ' + requirement.name + ', a level ' + requirement.level + ' ' + type);
                var specific_img = $('<img />')
                    .attr({
                        src: requirement.icon,
                        height: (requirement && requirement.iconSize ? requirement.iconSize : 32),
                        width: (requirement && requirement.iconSize ? requirement.iconSize : 32)
                    });
                var span = $('<span></span>')
                    .html(requirement.name);
                return html
                    .append(specific_img)
                    .append(span);
            } else
                return null;
        }
    };
};