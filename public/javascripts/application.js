// Form field observer.
// Note we use keyup even because:
//		.change only occurs on blur
//		.keypress on Safari doesn't fire for delete and other non-character keys
$.fn.observe = function( time, callback ) {
	return this.each(function() {
		var element = this, change = false, old_value = $(element).attr('initial_value');
     	$(element).keyup(function() {
			if ($(element).attr('value') != old_value) {
				change = true;
				old_value = $(element).attr('value');
			}
		});

		setInterval(function() {
			if ( change ) callback.call( element );
			change = false;
		}, time);
	});
};


/* Resize namecards to fit within the available panel space */ 
$.extend({	
    resizeContactCards: function(elems){	
		var cardMinSize = 200;
		var cardRightMargin = 10;

		// Reset column size to a 100% once view port has been adjusted 
		$("#contactCards").css('width', "100%");

		//Get the width of row
		var colWrap = $("#contactCards").width(); 
		// console.log('contactsCards with is ' + colWrap);

		//Find how many columns of 200px can fit per row / then round it down to a whole number
		var colNum = Math.floor(colWrap / cardMinSize); 
		// console.log('colNum is ' + colNum);

		// Get the width of the row and divide it by the number of columns it can fit / 
		// then round it down to a whole number. This value will be the exact width of the re-adjusted column
		var colFixed = Math.floor(colWrap / colNum);
		// console.log('colFixed with is ' + colFixed);

		//Set exact width of row in pixels instead of using % - Prevents cross-browser bugs that appear in certain view port resolutions.
		$("#contactCards").css('width', colWrap + 'px'); 

		//Set exact width of the re-adjusted column
		// have to subtract 20 to fit properly - dunno why?
		cards = $(".contactCard");
		if (cards.size() <= colNum) colFixed = cardMinSize + 20;
		cards.each(function(n) {
			$(this).css('width', (colFixed - 20) + 'px');
			if ((n + 1) % colNum == 0) {
				$(this).css('margin-right', '0px')
			} else {
				$(this).css('margin-right', cardRightMargin + 'px')
			}
		});
	},
	
	updateContactCards: function() {
		// Resize cards to fit after ajax update
		$.resizeContactCards();
		$.setContactsDraggable();
	},
	
	setContactsDraggable: function() {
		// Drag and drop cards to merge
		$('.contactCard').draggable({revert: true, helper: 'clone', opacity: 0.7});
		$('.contactCard').droppable({accept: '.contactCard', hoverClass: 'canDrop'});
    },

	// When a form is "inline" we want the field message (used for validation)
	// to be moved to the end of the enclosing div. That allows us to
	// position the message better.
	reorderInlineFieldMessages: function() {
		var fieldList = $('div.inline span.field_message');
		fieldList.each(function(n) {
			$.reorderInlineFieldMessage(this);
		});
	},

	reorderInlineFieldMessage: function(f) {
		// console.log('Reording message for ' + $(f).attr('id'));
		parent = $(f).parent().parent();
		element = $(f).remove();
		parent.append(f);
	},

	reorderInlineField: function(f) {
		f.find('.field_message').each(function(n) {
			$.reorderInlineFieldMessage(this);
		})
	},

	setupValidations: function() {
		var items = $('input[data-validate]');
		items.each(function(n) {
			// We use initial_value to determine if we've
			// already got an Observer set up
			if (!$(this).attr('initial_value')) {
				if ($(this).attr('data-validate') == "unique") {
					$.setupUnique(this);
				} else {
					$.setupValidation(this);
				};
			};
		});
	},
	
	setupUnique: function(item) {
		var validation_type = 'unique';

		// Validate periodically while typing in an element
		$(item).observe(600, function() {
			current_element = this;
			sendValidationRequest('unique', this);
		});

		// Validate when focus moves to another field
		$(item).bind('blur', function(){
			currentElement = "";
			sendValidationRequest(validation_type, this)
		});
	},

	setupValidation: function(item) {
		var validation_type = 'validations';

		// Save the initial value of the field.  Check first
		// so a Behavior.reload won't overwrite it
		if (!$(item).attr('initial_value')) $(item).attr('initial_value', $(item).attr('value'));

		// Validate periodically while typing in an element
		$(item).observe(600, function() {
			// console.log('Validation callback for ' + $(this).attr('id'));
			if ($(this).attr('value') != $(this).attr('initial_value')) {
				$.sendValidationRequest(validation_type, this);
			} else {
				$('#' + $(this).attr('id') + '_message').hide().html('');
			}
		});

		// Validate when focus moves to another field
		$(item).bind('blur', function(e){
			currentElement = "";
			if ($(this).attr('value') != $(this).attr('initial_value')) {
				$.sendValidationRequest(validation_type, this);
			} else {
				$($(this).attr('id') + '_message').hide().html('');
			}
		});
	},
	
	sendValidationRequest: function(validation_type, element) {
		console.log('Ajax request for ' + $(element).attr('id'));
		var params = $(element).attr('name') + '=' + encodeURIComponent($(element).attr('value'));
		var url = '/check/' + validation_type + '.json';
		$.ajax({url: url, data: params, dataType: 'json',
			success: function(data) {
				$('#' + $(element).attr('id') + '_message').hide().html('');
			},
			
			error: function(request, status, error) {
				if (request.status == 406) {
					var result = eval("(" + request.responseText + ")");
					$('#' + result['id'] + '_message').html(result['message']).show();
				};
			}
		});
	}

 });

$(document).ready(function(){
	
  	$('.kwicks').kwicks({  
    	max : 485  
  	});  

	// Get browser timezone
	Cookie.set("tzoffset", $.calculate_time_zone());

	// Set form focus
	var focus_list = $('input[focus], textarea[focus]');
	if (focus_list.size() > 0) {
		focus_list.first().focus();
	} else if ($('form').size() > 0) {
		$('form').find(':input:visible').first().focus();
	};

	// Form setup
	$.setupValidations();
	$.reorderInlineFieldMessages();

	/* Shows/hides panels */
 	$("h2.heading a").click(function(event){
		$(this).parent().next().slideToggle();
		return false;
  	});

  	/* Setup for accordions */
  	$(".accordion").accordion({navigation: true});

	/* And for tablesorter */
  	$.tablesorter.defaults.widgets = ['zebra'];
  	$('table').tablesorter();

	/* For contact cards and resizing */
	if ($('#contactCards')) {
		$.resizeContactCards();
		$.setContactsDraggable();
		$(window).bind('resize', function() {
			$.resizeContactCards();
		});
	};

  	/* Search forms */
	$('form.search').each(function(i) {
		$(this).find('input').searchbox({url : $(this).attr('url'), dom_id : '#' + $(this).attr('data-replace'), param : 'search'});
	});
	
	$(document).bind('after.searchbox', function() {
		var callback = $('form.search').first().attr('callback');
	  	if (callback) eval(callback);
	})

  	/* Optional fields handling - toggle visibility on click */
	$('span.showOptional input[type="checkbox"]').click(function(event) {
		fieldset = $(this).parent().next();
		optionalFields = fieldset.find('.optional');
		optionalFields.toggle("slow");
	});

	/* Dynamic fieldsets operations - delete */
	$('img.delete').live('click', (function(event) {
		element = $(this).parent();
		if (element.hasClass('_new')) {
			element.remove();
		} else {
			delete_field = element.find('._destroy').first();
			delete_field.value = "1";
			element.hide();
		};
	}));
	
	/* Dynamic fieldsets - add */
	$('img.add').live('click', (function(event) {
		var new_id = new Date().getTime();
		fieldset = $(this).closest('fieldset');   /* fieldset */
		template = eval(fieldset.attr('id')).replace(/NEW_RECORD/g, new_id);
		fieldset.append(template);
		element = fieldset.children().last();
		new_row = element;
		if (element.hasClass("inline")) $.reorderInlineField(element);
		element.addClass('_new');
		$.setupValidations();
		fields = new_row.find(':input:visible');
		if (fields.length > 0) fields.first().focus();
	}));
	
	/* Dynamic fieldsets - show and hide the buttons */
	$('.listItem').live('mouseover', (function(event) {
		$(this).find('.buttons').first().show();
	}));
	
	$('.listItem').live('mouseout', (function(event) {
		$(this).find('.buttons').first().hide();
	}));
	
	/* Remove flash notices after 5 seconds */
	$('.flash_notice').fadeOut(5000, function() {
	    // Animation complete.
	});

});   
