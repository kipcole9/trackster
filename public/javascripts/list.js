Event.addBehavior({
	'.listMember:click' : function(e) {
		e.stopPropagation();
		var element = e.element();							// What we clicked on		
		var listMember = this;								
		var listId = listMember.id.split('_')[1];			// The Id of what we're updating or inserting into	
	},
	
	'.listMember:mouseover' : function(e) {
		e.stopPropagation();
		this.select('.buttons').first().show();
	},
	
	'.listMember:mouseout' : function(e) {
		e.stopPropagation();
		this.select('.buttons').first().hide();
	},
		
	// Set each of them to be drop zones
	'.listItem' : function(e) {
		this.acceptsClasses = [];
		var pattern = /^accept_(.*)/;
		var self = this;
		
		// A listItem can accept drops from classes that
		// are defined as 'accept_*' on the listItem element 
		this.classNames().each(function(name) {
			if (match = name.match(pattern)) {
				self.acceptsClasses.push(match[1]);
			}
		});
		Droppables.add(this, {hoverclass: 'hover', accepts: this.acceptsClasses, 
			onDrop: function(draggable, droppable, event) {
				var dragParts = draggable.id.split('_');
				var dropParts = droppable.id.split('_');
				var url = '/relates?drop=' + dropParts.first() + '_' + dropParts.last() + '&drag=' + dragParts.first() + '_' + dragParts.last();
				// console.log('Url is ' + url);
				submitter = new Ajax.Request(url, {
					method: 'post',
					asynchronous: true, 
					evalScripts: true
				});
			}
		});
	}
});


