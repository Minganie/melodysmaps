Selectable.Item = function(searchable) {
    this._searchable = searchable;
    if(searchable) {
        this._info = api.item.info(searchable.lid);
        this._sources = api.item.sources(searchable.lid);
    }
}
Selectable.Item.prototype = $.extend({}, Selectable.prototype, {
    onSelect: function() {
        $('#item').itemBox("instance").setItem(this);
    }
});
Selectable.Item.Tooltip = {
    get: function(item) {
        if(item.lcat2 == 'Arms' || item.lcat2 == 'Tools')
            return new Selectable.Item.Tooltip.Weapon(item);
        if(item.lcat3 == 'Shield')
            return new Selectable.Item.Tooltip.Shield(item);
        if(item.lcat3 == 'Soul Crystal')
            return new Selectable.Item.Tooltip.SoulCrystal(item);
        if(item.lcat2 == 'Armor' || item.lcat2 == 'Accessories')
            return new Selectable.Item.Tooltip.Armor(item);
        if(item.lcat2 == 'Medicines & Meals' || item.lcat3 == 'Seasonal Miscellany')
            return new Selectable.Item.Tooltip.Consumable(item);
        if(item.lcat3 == 'Materia')
            return new Selectable.Item.Tooltip.Materia(item);
        if(item.lcat3 == 'Fishing Tackle')
            return new Selectable.Item.Tooltip.Bait(item);
        if(item.lcat3 == 'Seafood')
            return new Selectable.Item.Tooltip.Material(item);
        if(item.lcat2 == 'Materials' || item.lcat2 == 'Other')
            return new Selectable.Item.Tooltip.Material(item);
        else {
            throw "Can't find the type of tooltip to make for " + item.lcat2 + " + " + item.lcat3;
        }
    }
};

Selectable.Item.Tooltip.Item = function(item) {
	this.item = item;
}
Selectable.Item.Tooltip.Item.prototype = {
	
	getTooltipHeader: function() {
		// Header: img + name
		var html = $('<div></div>')
            .addClass('melsmaps-weapon-header');
        var im_div = $('<div></div>')
            .appendTo(html);
        var im = $('<img />')
            .attr({
                src: this.item.licon,
                alt: this.item.name + ' icon',
                height: 64,
                width: 64
            }).appendTo(im_div);
        var sub_div = $('<div></div>')
            .appendTo(html);
        var u_p = $('<p></p>')
            .addClass('melsmaps-item-unique')
            .html((this.item.unique ? 'Unique ' : '') + (this.item.untradable ? 'Untradable' : ''))
            .appendTo(sub_div);
        var name_p = $('<p></p>')
            .addClass('melsmaps-item-name')
            .html(this.item.name)
            .appendTo(sub_div);
        var cat3_p = $('<p></p>')
            .addClass('melsmals-item-lcat3')
            .html(this.item.lcat3)
            .appendTo(sub_div);
		return html;
	},
	
	getTooltipIlvl: function() {
		// ilvl
		var html = null;
		if(this.item.level) {
			html = $('<div></div>')
                .addClass('melsmaps-item-ilvl')
                .html('Item Level ' + this.item.level);
        }
		return html;
	},
	
	getUsers: function() {
		// Used by
		var uses = '';
		for(var i in this.item.disciplines) {
			uses += this.item.disciplines[i].abbrev + ' ';
		}
		var html = $('<div></div>')
            .addClass('melsmaps-item-users');
        $('<p></p>')
            .html(uses)
            .appendTo(html);
        $('<p></p>')
            .html('Lv. ' + this.item.required_level)
            .appendTo(html);
		return html;
	},
	
	getEffects: function() {
		var html = null;
		if(this.item.effects && this.item.effects.length && this.item.effects.length >0) {
			html = $('<div></div>')
                .addClass('melsmaps-item-effects');
            $('<p></p>')
                .html('Effects')
                .appendTo(html);
			for(var i in this.item.effects) {
                $('<p></p>')
                    .html(this.item.effects[i])
                    .appendTo(html);
			}
		}
		return html;
	},
	
	getNote: function() {
		// Note
		return (this.item.note ? $('<div></div>').html(this.item.note) : null);
	},
	
	getBonuses: function() {
		// Bonuses
		var html = null;
		if(this.item.bonuses) {
			html = $('<div></div>')
                .addClass('melsmaps-item-bonuses');
            $('<p></p>')
                .html('Bonuses')
                .appendTo(html);
			var rows = 0;
            var t = $('<table></table>')
                .appendTo(html);
			for(var i in this.item.bonuses) {
				var bonus = this.item.bonuses[i];
				if(rows%2 == 0) {
					var tr = $('<tr></tr>')
                        .appendTo(t);
				}
                var td = $('<td></td>')
                    .appendTo(tr);
                $('<span></span>')
                    .addClass('melsmaps-item-label')
                    .html(bonus.stat)
                    .appendTo(td);
                $('<span></span>')
                    .html(' +')
                    .appendTo(td);
                $('<span></span>')
                    .html(bonus.size)
                    .appendTo(td);
				++rows;
			}
		}
		return html;
	},
	
	getMateria: function() {
		// Materia
		var melding = '';
		var html = null;
		if(this.item.materia_slots && this.item.materia_slots > 0) {
			html = $('<div></div>')
                .addClass('melsmaps-item-materia');
            $('<p></p>')
                .html('Materia')
                .appendTo(html);
			for(var i = 0; i < this.item.materia_slots; i++) {
				$('<div></div>')
                    .addClass('melsmaps-item-slot')
                    .appendTo(html);
			}
			//melding = (this.item.melding_class && this.item.melding_level ? this.item.melding_class + ' Lv. ' + this.item.melding_level : '');
            //FIXME was melding forgotten? check this
		}
		return html;
	},
	
	getCrafting: function() {
		// Crafting
		var html = null;
		if((this.item.repair_class && this.item.repair_level)
			|| this.item.repair_material
			|| this.item.convertible
			|| this.item.projectable
			|| this.item.desynthesizable
			|| this.item.dyeable) {
			
			html = $('<div></div>')
                .addClass('melsmaps-item-repair');
            $('<p></p>')
                .html('Crafting & Repairs')
                .appendTo(html);
			var t = $('<table></table>')
                .appendTo(html);
			if(this.item.repair_class && this.item.repair_level) {
                var tr = $('<tr></tr>')
                    .appendTo(t);
                var label_td = $('<td></td>')
                    .appendTo(tr);
                $('<span></span>')
                    .addClass('melsmaps-item-label')
                    .html('Repair Level')
                    .appendTo(label_td);
                var value_td = $('<td></td>')
                    .html(this.item.repair_class + ' Lv. ' + this.item.repair_level)
                    .appendTo(tr);
            }
			if(this.item.repair_material) {
                var tr = $('<tr></tr>')
                    .appendTo(t);
                var label_td = $('<td></td>')
                    .appendTo(tr);
                $('<span></span>')
                    .addClass('melsmaps-item-label')
                    .html('Materials')
                    .appendTo(label_td);
                var value_td = $('<td></td>')
                    .html(this.item.repair_material)
                    .appendTo(tr);
            }
			if(this.item.convertible || this.item.projectable) {
                var tr = $('<tr></tr>')
                    .appendTo(t);
				if(this.item.convertible) {
                    var td = $('<td></td>')
                        .appendTo(tr);
                    $('<span></span>')
                        .addClass('melsmaps-item-label')
                        .html('Convertible:')
                        .appendTo(td);
                    $('<span></span>')
                        .html(this.item.convertible ? ' Yes' : ' No')
                        .appendTo(td);
                }
				if(this.item.projectable) {
                    var td = $('<td></td>')
                        .appendTo(tr);
                    $('<span></span>')
                        .addClass('melsmaps-item-label')
                        .html('Projectable:')
                        .appendTo(td);
                    $('<span></span>')
                        .html(this.item.projectable ? ' Yes' : ' No')
                        .appendTo(td);
                }
			}
			if(this.item.desynthesizable || this.item.dyeable) {
                var tr = $('<tr></tr>')
                    .appendTo(t);
				if(this.item.desynthesizable) {
                    var td = $('<td></td>')
                        .appendTo(tr);
                    $('<span></span>')
                        .addClass('melsmaps-item-label')
                        .html('Desynthesizable:')
                        .appendTo(td);
                    $('<span></span>')
                        .html(this.item.desynthesizable ? ' ' + this.item.desynthesizable : ' No')
                        .appendTo(td);
                }
				if(this.item.dyeable) {
                    var td = $('<td></td>')
                        .appendTo(tr);
                    $('<span></span>')
                        .addClass('melsmaps-item-label')
                        .html('Dyeable:')
                        .appendTo(td);
                    $('<span></span>')
                        .html(this.item.dyeable ? ' Yes' : ' No')
                        .appendTo(td);
                }
			}
		}
		return html;
	},
	
	getMarket: function() {
		// Market
		var html = $('<div></div>')
            .addClass('melsmaps-item-market');
        if(this.item.advanced_melding) {
            $('<span></span>')
                .addClass('melsmaps-label-pink')
                .html('Advanced Melding Forbidden')
                .appendTo(html);
        }
        $('<span></span>')
            .html(this.item.unsellable ? 'Unsellable ' : 'Sells for ' + this.item.sell_price + ' gil ')
            .appendTo(html);
        if(this.item.market_prohibited) {
            $('<span></span>')
                .addClass('melsmaps-label-pink')
                .html('Market Prohibited')
                .appendTo(html);
        }
		return html;
	},
	
	_getItemImgTag: function() {
        return $('<img />')
            .attr({
                src: this.item.licon,
                width: 24,
                height: 24,
                alt: this.item.name + ' icon'
            });
    },
	
	_getGatheringGrade: function() {
        var html = null;
        if(this.item.g_rarity) {
            var title = (this.item.g_rarity == 'Rare' ? 'Only one of this can be gathered per node' : 'This item will not be in the same gathering slot in every node');
            html = $('<span></span>')
                .addClass('melsmaps-popup-gathering-grade')
                .attr('title', title)
                .html(this.item.g_rarity.toUpperCase());
        }
        return html;
    },
	
	_formatTime: function(seconds) {
		var hours = Math.floor(seconds/3600);
		var remainingSeconds = seconds - (3600*hours);
		var mins = Math.floor(remainingSeconds/60);
		remainingSeconds = seconds - (3600*hours) - (60*mins);
		return (hours > 0 ? hours + 'h' : '') 
			+ (mins > 0 ? mins + 'm' : '')
			+ (remainingSeconds > 0 ? remainingSeconds + 's' : '');
	},
	
	// getGatheringLine: function() {
		// var html = '<div class="melsmaps-popup-gathering-container melsmaps-is-a-tooltip" data-melsmaps-tooltip="' + Selectable.Item.Tooltip._encode(this.getTooltip()) + '">';
		// var img = '<span class="melsmaps-popup-gathering-fixed">' + this._getItemImgTag() + '</span>';
		// var name = '<span class="melsmaps-popup-gathering-fixed">' + this.item.name + '</span>';
		// var filler = '<span></span>';
		// var grade = this._getGatheringGrade();
		// html += img + name + filler + grade + '</div>';
		// return html;
	// },
	
	getTooltippedLi: function() {
		var html = $('<li></li>')
            .addClass('melsmaps-is-a-tooltip')
            .attr('data-melsmaps-tooltip', this.getTooltip().outerHTML)
            .append(this._getItemImgTag())
            .append(this.item.name);
		return html;
	},
    
    getTooltippedLiWithExtraText: function(extra) {
        var html = this.getTooltippedLi();
		return html
            .append(' ')
            .append(extra);
    },
    
    getTooltippedLiWithInterest: function() {
        var interests = '';
        for(var k in this.item.interests) {
            interests += this.item.interests[k] + ' ';
        }
        return this.getTooltippedLiWithExtraText(interests);
    },
    
    getTooltippedDiv: function() {
        var html = $('<div></div>')
            .addClass('melsmaps-popup-gathering-container melsmaps-is-a-tooltip')
            .attr('data-melsmaps-tooltip', this.getTooltip().outerHTML);
        $('<span></span>')
            .addClass('melsmaps-popup-gathering-fixed')
            .append(this._getItemImgTag())
            .appendTo(html);
        $('<span></span>')
            .addClass('melsmaps-popup-gathering-fixed')
            .html(this.item.name)
            .appendTo(html);
        $('<span></span>')
            .appendTo(html);    // filler
        html.append(this._getGatheringGrade());
        return html;
    },
    
    getTooltippedImage: function(size) {
        var html = $('<img />')
            .addClass('melsmaps-is-a-tooltip')
            .attr({
                src: this.item.licon,
                "data-melsmaps-tooltip": this.getTooltip().outerHTML,
                width: (size ? size : 32),
                height: (size ? size : 32),
                alt: '',
                title: this.item.name
            });
        return html;
    },
    
    
    // getObjImg: function() {
        // return $('<img />')
            // .addClass("melsmaps-is-a-tooltip")
            // .attr("data-melsmaps-tooltip", this.getTooltip())
            // .attr('src', this.item.licon)
            // .attr('width', 24)
            // .attr('height', 24)
            // .attr('alt', this.item.name + ' icon');
    // }
}
Selectable.Item.Tooltip.Weapon = function(item) {
	Selectable.Item.Tooltip.Item.call(this, item);
}
Selectable.Item.Tooltip.Weapon.prototype = $.extend({}, Selectable.Item.Tooltip.Item.prototype, {
	
	getCaracteristics: function() {
		// Phys car
		var html = $('<table></table>')
            .addClass('melsmaps-item-phys');
        var label_tr = $('<tr></tr>')
            .appendTo(html);
        $('<td></td>')
            .addClass('melsmaps-item-label')
            .html('Physical Damage')
            .appendTo(label_tr);
        $('<td></td>')
            .addClass('melsmaps-item-label')
            .html('Auto-attack')
            .appendTo(label_tr);
        $('<td></td>')
            .addClass('melsmaps-item-label')
            .html('Delay')
            .appendTo(label_tr);
        var value_tr = $('<tr></tr>')
            .appendTo(html);
        $('<td></td>')
            .html(this.item.damage)
            .appendTo(value_tr);
        $('<td></td>')
            .html(this.item.auto_attack)
            .appendTo(value_tr);
        $('<td></td>')
            .html(this.item.delay)
            .appendTo(value_tr);
		return html;
	},
	
	getTooltip: function() {
        var ilvl = this.getTooltipIlvl();
		var bonuses = this.getBonuses();
		var materias = this.getMateria();
		var crafting = this.getCrafting();
		var html = $('<div></div>')
            .addClass('melsmaps-item-tooltip-wrapper');
		html.append(this.getTooltipHeader());
        (ilvl ? html.append(ilvl) : null);
		html.append(this.getCaracteristics());
		html.append(this.getUsers());
		// html.append(this.getNote());//nullcheck	// No weapon has a note so far
        (bonuses ? html.append(bonuses) : null);
        (materias ? html.append(materias) : null);
        (crafting ? html.append(crafting) : null);
		html.append(this.getMarket());
		return html[0];
	}
});

Selectable.Item.Tooltip.Armor = function(item) {
	Selectable.Item.Tooltip.Item.call(this, item);
}
Selectable.Item.Tooltip.Armor.prototype = $.extend({}, Selectable.Item.Tooltip.Item.prototype, {
	
	getCaracteristics: function() {
		// Phys car
		var html = $('<table></table>')
            .addClass('melsmaps-item-phys');
        var label_tr = $('<tr></tr>')
            .appendTo(html);
        $('<td></td>')
            .addClass('melsmaps-item-label')
            .appendTo(label_tr);
        $('<td></td>')
            .addClass('melsmaps-item-label')
            .html('Defense')
            .appendTo(label_tr);
        $('<td></td>')
            .addClass('melsmaps-item-label')
            .html('Magic Defense')
            .appendTo(label_tr);
        var value_tr = $('<tr></tr>')
            .appendTo(html);
        $('<td></td>')
            .appendTo(value_tr);
        $('<td></td>')
            .html(this.item.defense)
            .appendTo(value_tr);
        $('<td></td>')
            .html(this.item.magic_defense)
            .appendTo(value_tr);
		return html;
	},
	
	getTooltip: function() {
        var ilvl = this.getTooltipIlvl();
		var bonuses = this.getBonuses();
		var materias = this.getMateria();
		var crafting = this.getCrafting();
        
		var html = $('<div></div>')
            .addClass('melsmaps-item-tooltip-wrapper');
		html.append(this.getTooltipHeader());
		(ilvl ? html.append(ilvl) : null);
		html.append(this.getCaracteristics());
		html.append(this.getUsers());
		// html += this.getNote();//nullcheck
        (bonuses ? html.append(bonuses) : null);
        (materias ? html.append(materias) : null);
        (crafting ? html.append(crafting) : null);
		html.append(this.getMarket());
		return html[0];
	}
});

Selectable.Item.Tooltip.Bait = function(item) {
	Selectable.Item.Tooltip.Item.call(this, item);
}
Selectable.Item.Tooltip.Bait.prototype = $.extend({}, Selectable.Item.Tooltip.Item.prototype, {
	getTooltip: function() {
        var ilvl = this.getTooltipIlvl();
		var note = this.getNote();
        
		var html = $('<div></div>')
            .addClass('melsmaps-item-tooltip-wrapper');
            
		html.append(this.getTooltipHeader());
		(ilvl ? html.append(ilvl) : null);
		html.append(this.getUsers());
		(note ? html.append(note) : null);
		html.append(this.getMarket());
		return html[0];
	}
});

Selectable.Item.Tooltip.Consumable = function(item) {
	Selectable.Item.Tooltip.Item.call(this, item);
}
Selectable.Item.Tooltip.Consumable.prototype = $.extend({}, Selectable.Item.Tooltip.Item.prototype, {
	getRecast: function() {
		var html = null;
		if(this.item.recast && this.item.recast != 0) {
			html = $('<table></table>')
                .addClass('melsmaps-item-phys');
            var label_tr = $('<tr></tr>')
                .appendTo(html);
            $('<td></td>')
                .addClass('melsmaps-item-label')
                .html('Recast')
                .appendTo(label_tr);
            $('<td></td>')
                .addClass('melsmaps-item-label')
                .html('')
                .appendTo(label_tr);
            $('<td></td>')
                .addClass('melsmaps-item-label')
                .html('')
                .appendTo(label_tr);
            var value_tr = $('<tr></tr>')
                .appendTo(html);
            $('<td></td>')
                .html(this._formatTime(this.item.recast))
                .appendTo(value_tr);
            $('<td></td>')
                .html('')
                .appendTo(value_tr);
            $('<td></td>')
                .html('')
                .appendTo(value_tr);
		}
		return html;
	},
	
	getTooltip: function() {
        var ilvl = this.getTooltipIlvl();
        var recast = this.getRecast();
        var effects = this.getEffects();
		var note = this.getNote();
        
		var html = $('<div></div>')
            .addClass('melsmaps-item-tooltip-wrapper');
		html.append(this.getTooltipHeader());
		(ilvl ? html.append(ilvl) : null);
		(recast ? html.append(recast) : null);
		(effects ? html.append(effects) : null);
		(note ? html.append(note) : null);
		html.append(this.getMarket());
		return html[0];
	}
});

Selectable.Item.Tooltip.Materia = function(item) {
	Selectable.Item.Tooltip.Item.call(this, item);
}
Selectable.Item.Tooltip.Materia.prototype = $.extend({}, Selectable.Item.Tooltip.Item.prototype, {
	getRequirements: function() {
		var html = $('<div></div>')
            .addClass('melsmaps-item-req');
        $('<p></p>')
            .html('Requirements')
            .appendTo(html);
        var p = $('<p></p>')
            .appendTo(html);
        $('<span></span>')
            .addClass('melsmaps-item-label')
            .html('Base Item: ')
            .appendTo(p);
        $('<span></span>')
            .html('Item Level ' + this.item.meld_ilvl)
            .appendTo(p);
		return html;
	},
	
	getTooltip: function() {
        var bonuses = this.getBonuses();
        
		var html = $('<div></div>')
            .addClass('melsmaps-item-tooltip-wrapper');
		html.append(this.getTooltipHeader());
		(bonuses ? html.append(bonuses) : null);
		html.append(this.getRequirements());
		// html += this.getNote();//nullcheck
		html.append(this.getMarket());
		return html[0];
	}
});

Selectable.Item.Tooltip.Material = function(item) {
	Selectable.Item.Tooltip.Item.call(this, item);
}
Selectable.Item.Tooltip.Material.prototype = $.extend({}, Selectable.Item.Tooltip.Item.prototype, {
	getTooltip: function() {
        var ilvl = this.getTooltipIlvl();
		var note = this.getNote();
		var crafting = this.getCrafting();
        
		var html = $('<div></div>')
            .addClass('melsmaps-item-tooltip-wrapper');
		html.append(this.getTooltipHeader());
		(ilvl ? html.append(ilvl) : null);
		(note ? html.append(note) : null);
		(crafting ? html.append(crafting) : null);
		html.append(this.getMarket());
		return html[0];
	}
});

Selectable.Item.Tooltip.Shield = function(item) {
	Selectable.Item.Tooltip.Item.call(this, item);
}
Selectable.Item.Tooltip.Shield.prototype = $.extend({}, Selectable.Item.Tooltip.Item.prototype, {
	getCaracteristics: function() {
        var html = $('<table></table>')
            .addClass('melsmaps-item-phys');        
        var label_tr = $('<tr></tr>')
            .appendTo(html);
        $('<td></td>')
            .addClass('melsmaps-item-label')
            .html('')
            .appendTo(label_tr);
        $('<td></td>')
            .addClass('melsmaps-item-label')
            .html('Block Strength')
            .appendTo(label_tr);
        $('<td></td>')
            .addClass('melsmaps-item-label')
            .html('Block Rate')
            .appendTo(label_tr);
        var value_tr = $('<tr></tr>')
            .appendTo(html);
        $('<td></td>')
            .html('')
            .appendTo(value_tr);
        $('<td></td>')
            .html(this.item.block_strength)
            .appendTo(value_tr);
        $('<td></td>')
            .html(this.item.block_rate)
            .appendTo(value_tr);
		return html;
	},
	getTooltip: function() {
        var ilvl = this.getTooltipIlvl();
		var note = this.getNote();
        var bonuses = this.getBonuses();
		var materias = this.getMateria();
		var crafting = this.getCrafting();
        
		var html = $('<div></div>')
            .addClass('melsmaps-item-tooltip-wrapper');
		html.append(this.getTooltipHeader());
		(ilvl ? html.append(ilvl) : null);
		html.append(this.getCaracteristics());
		html.append(this.getUsers());
		(note ? html.append(note) : null);
		(bonuses ? html.append(bonuses) : null);
		(materias ? html.append(materias) : null);
		(crafting ? html.append(crafting) : null);
		html.append(this.getMarket());
		return html[0];
	}
});

Selectable.Item.Tooltip.SoulCrystal = function(item) {
	Selectable.Item.Tooltip.Item.call(this, item);
}
Selectable.Item.Tooltip.SoulCrystal.prototype = $.extend({}, Selectable.Item.Tooltip.Item.prototype, {
	getTooltip: function() {
        var ilvl = this.getTooltipIlvl();
		var note = this.getNote();
        var bonuses = this.getBonuses();
        
		var html = $('<div></div>')
            .addClass('melsmaps-item-tooltip-wrapper');
		html.append(this.getTooltipHeader());
		(ilvl ? html.append(ilvl) : null);
		html.append(this.getUsers());
		(note ? html.append(note) : null);
		(bonuses ? html.append(bonuses) : null);
		html.append(this.getMarket());
		return html[0];
	}
});