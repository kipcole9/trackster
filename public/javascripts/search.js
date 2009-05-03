LiveSearch = Class.create({
	Version: '0.1.0',
	REQUIRED_PROTOTYPE: '1.6.0',

	initialize: function(id, params) {
		// check whether we have the appropiate javascript libraries
		this.PROTOTYPE_CHECK();

		// Get the field we're watching.
		// It needs to be a valid field so throw an error if it's not valid or can't be found.
		this.fld = $(id);
		if (!this.fld) {
			throw("LiveSearch requires a field id to initialize");
		}

		// Set the use specified options
		this.options = params || {};
		var self = this;
		
		// These are the default settings
		var k, defaultOptions = {
			url: 		null,
			param:  	'search',
			replace:  	null,
			interval:  	0.5
		};

		// Overlay any values which weren't user specified.
		for (k in defaultOptions) {
			this.options[k] = this.options[k] || defaultOptions[k];
		}
		
		// Start the observer
		this.observer = new Form.Element.Observer(this.fld, this.options['interval'], function(element, value) {
			self.url = self.options['url'] + '?' + self.options['param'] + '=' + value
			self.updater = new Ajax.Updater({success: self.options['replace']}, self.url, {
				method: 'get',
				onComplete: function(request) { Event.addBehavior.reload() },
				onFailure: function(request) { alert('Sorry - the search could not be completed.')}
			});
		});
	},

	convertVersionString: function (versionString) {
		var r = versionString.split('.');
		return parseInt(r[0])*100000 + parseInt(r[1])*1000 + parseInt(r[2]);
	},

	PROTOTYPE_CHECK: function() {
		if ((typeof Prototype=='undefined') || 
			(typeof Element == 'undefined') || 
			(typeof Element.Methods=='undefined') ||
			(this.convertVersionString(Prototype.Version) < 
			this.convertVersionString(this.REQUIRED_PROTOTYPE)))
			throw("LiveSearch requires the Prototype JavaScript framework >= " + this.REQUIRED_PROTOTYPE);
	}
});