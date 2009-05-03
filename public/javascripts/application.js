// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Attach common behaviours

Event.addBehavior({
  '.box h2 a:click' : function(e) {
		e.stop();
    	var target = this.up('.box').down('.block')
		Effect.toggle($(target), 'blind', {duration: 0.5});
  	}
});

// Hide on load
Event.addBehavior({
	'.hidden' : function(e) {
		this.hide();
	}
});

Event.addBehavior({
	'.loading' : function(e) {
		this.hide();
	}
});

// Initialize tabs
Event.addBehavior({
	'.tab' : function(e) {
		new Tabricator(this.id, 'DT');
	}
});

// Initialize accordians
Event.addBehavior({
	'.accordian' : function(e) {
		new Concertina(this, // The root element ID or object
            false,          // Create Nested Concertinas?
            true,           // Set a Uniform Height?
            true,          // Use Animation?
            true           // Use Simple Animation Easing?
		);
	}
});

// Load ajax pages
Event.addBehavior({
	'.ajax' : function(e) {
		source = this.readAttribute('rel');
		if (source) {
			var destination = this.id + "-toggle";
			var load_image = this.id + "-loading";
			new Ajax.Updater(
				{success: destination}, 
				source,
				{
					onFailure: 	function(request)	{ $(load_image).hide(); alert(request.status); },
					onComplete:	function(request)	{ $(load_image).hide();	},
					onLoading: 	function(request)	{ $(load_image).show();	}
				}
			);
		}
	}
});

// We're deleting rows.  But then some of the rows have just been
// created so we don't need to serialize them.  Just delete the
// DOM element.  We know which ones we added because they have the
// class '_new' on their enclosing div.  If not new, then we set
// the '_delete' field to "1" and hide the element.
Event.addBehavior({
	'img.delete:click': function(e) {
		element = this.up();
		if (element.hasClassName('_new')) {
			element.remove();
		} else {
			delete_field = element.select('._delete').first();
			delete_field.value = "1";
			element.hide();
		}
	}
})

//  An "add" button on a fieldset collection - used to dynamically
//  add new child attributes
Event.addBehavior({
	'img.add:click' : function(e) {
		var new_id = new Date().getTime();
		fieldset = this.up('fieldset');
		template = eval(fieldset.id).replace(/NEW_RECORD/g, new_id);
		fieldset.insert({
			bottom: template
		});
		element = fieldset.childElements().last();
		new_row = element;
		if (element.hasClassName("inline")) reorderInlineField(element);
		element.addClassName('_new');
		Event.addBehavior.reload();
		setupValidations();
		fields = new_row.select('input[focus], textarea[focus]');
		if (fields.length > 0) fields.first().focus();
	}	
});

//  When we set an entry to be "preferred" we unset all
//  the others
Event.addBehavior({
	'input[type="checkbox"].preferred:click' : function(e) {
		if (this.checked) {
			fieldset = this.up('fieldset');
			myId = this.id;
			fieldset.select('input[type="checkbox"].preferred').each(function(e, n) {
				if (e.id != myId) {
					e.checked = false;
				}
			});
		}
	}	
});

// Show/hide optional fields
Event.addBehavior({
	'span.showOptional input[type="checkbox"]:click' : function(e) {
		fieldset = this.up().next();
		optionalFields = fieldset.select('.optional');
		if (this.checked) {
			optionalFields.each(function(e, n) {
				e.show();
			});
		} else {
			optionalFields.each(function(e, n) {
				e.hide();
			});			
		}
	}
});

// Show optional fields if requested at load time
Event.addBehavior({
	'span.showOptional input[type="checkbox"]' : function(e) {
		fieldset = this.up().next();
		optionalFields = fieldset.select('.optional');
		if (this.checked) {
			optionalFields.each(function(e, n) {
				e.show();
			});
		}
	}
});

// For the use pick list
Event.addBehavior({
	'.user' : function(e) {
		new Draggable(this, {ghosting: true, revert: true});
	}
})

Event.addBehavior({
	'body' : function(e) { 
		// Get browser timezone
		Cookie.set("tzoffset", calculate_time_zone());
		
		// Set form focus
		var focus_list = $$('input[focus]');
		if (focus_list.size() > 0) {
			focus_list.first().focus();
		} else if ($$('form').size() > 0) {
			$$('form').first().focusFirstElement();
		};
		
		setupValidations();
		reorderInlineFieldMessages();
	}
});

// When a form is "inline" we want the field message (used for validation)
// to be moved to the end of the enclosing div. That allows us to
// position the message better.
function reorderInlineFieldMessages() {
	var fieldList = $$('div.inline span.field_message');
	fieldList.each(function(i,n) {
			reorderInlineFieldMessage(i);
		}
	);
};

function reorderInlineFieldMessage(f) {
	parent = f.up().up();
	element = f.remove();
	parent.insert(f);
};

function reorderInlineField(f) {
	f.select('.field_message').each(function(i,n) {
		reorderInlineFieldMessage(i);
	})
};

function setupValidations() {
	var items = $$('input[validate]');
	items.each(
		function(i, n) {
			// We use initial_value to determine if we've
			// already got an Observer set up
			if (!i.readAttribute('initial_value')) {
				if (i.readAttribute('validate') == "unique") {
					setupUnique(i);
				} else {
					setupValidation(i);
				};
			};
		}
	);
};


function showCross(request) {
	$(request.responseJSON.id + '_message').update(request.responseJSON.message);
	$(request.responseJSON.id + '_cross').title = request.responseJSON.message;
	$(request.responseJSON.id + '_cross').show();
	$(request.responseJSON.id + '_tick').hide();
	alert($(request.responseJSON.id + '_message'));
	if (attributeCallback) {
		attributeCallback(false);
	};
};

function showTick(request) {
	$(request.responseJSON.id + '_message').update(request.responseJSON.message);
	$(request.responseJSON.id + '_tick').title = request.responseJSON.message;
	$(request.responseJSON.id + '_tick').show();	
	$(request.responseJSON.id+ '_cross').hide();
	if (attributeCallback) {
		attributeCallback(true);
	}	
};

function showSpinner(request) {
	$(current_element.id + '_spinner').show();
};

function hideSpinner(request) {
	$(request.responseJSON.id + '_spinner').hide();
};

function setupUnique(item) {
	var validation_type = 'unique';
	
	// Validate periodically while typing in an element
	new Form.Element.Observer(item.id, 0.6,
		function(element,value) {
			current_element = element;
			sendAjaxRequest('unique', element);
		}
	);
	
	// Validate when focus moves to another field
	item.observe('blur', 
		function(event){
			currentElement = "";
			sendAjaxRequest(validation_type, event.element())
		}
	);
};

function setupValidation(item) {
	var validation_type = 'validations';
	
	// Save the initial value of the field.  Check first
	// so a Behavior.reload won't overwrite it
	if (!item.readAttribute('initial_value')) {
		item.writeAttribute('initial_value', item.value);
	}

	// Validate periodically while typing in an element
	new Form.Element.Observer(item.id, 0.6,
		function(element, value) {
			current_element = element;
			if (value != element.readAttribute('initial_value')) {
				sendAjaxRequest(validation_type, element);
			} else {
				$(element.id + '_message').update('');
			}
		}
	);
	
	// Validate when focus moves to another field
	item.observe('blur', 
		function(event){
			currentElement = "";
			element = event.element();
			if (element.value != element.readAttribute('initial_value')) {
				sendAjaxRequest(validation_type, event.element());
			} else {
				$(element.id + '_message').update('');
			}
		}
	);
};

function sendAjaxRequest(validation_type, element) {
	new Ajax.Request('/check/' + validation_type + '.json', {
		parameters: element.name + '=' + encodeURIComponent(element.value),	
		method: 	'get', 
		onFailure: 	showCross, 
		onSuccess: 	showTick 
		// onLoading: 	showSpinner, 
		// onLoaded:   hideSpinner
	});	
}