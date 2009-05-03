function _tks(account)  {
	this.version		= "0.84";
	var self = this;
	this.account 		= "undefined";
	this.trackerHost	= "noexpectations.com.au";
	this.trackerImage	= "/tracker.gif";
	this.parameters 	= new Object;  // Parsed URL parameters
	// Default campaign parameter names; same as the Google Analytics
	// to easy compatibility for campaign tracking, especially if GA is
	// already installed and working
	this.campaignName 	= "utm_campaign";
	this.campaignSource = "utm_source";
	this.campaignMedium = "utm_medium";
	this.campaignContent = "utm_content";
	// The URL we're tracking
	this.url = ''
	// This is the method that actually sends the tracking
	// request
	this.trackPageview = function(pageUrl) {
		this.url = pageUrl || '';
		// console.log('Track pageview has been requested for ' + self.getUrl());
		params = []; i = 0; image = new Image(1, 1);
		var url = location.protocol + '//www.' + this.trackerHost + this.trackerImage + "?";
		for (p in this.urlParams) {
			// Have to separate the next two functions
			// to work in IE7.  Sigh.
			f = this.urlParams[p]; value = f();
			if (value != 'undefined' && value && value.length > 0) {
				params[i++] = p + '=' + value;
			};
		};
		url += params.join('&');
		url += "&uver=" + this.version;
		// console.log('About to get image: ' + url);
        image.src = url; // Triggers image loading
		return;	
	};
	this.getScreenSize = function() {
		return screen.width + 'x' + screen.height;
	};
	this.getColorDepth = function() {
		return screen.colorDepth + '';
	};
	this.getLanguage = function() {
		return navigator.language || navigator.userLanguage; 
	};
	this.getCharset = function() {
		function getMetaHttpEquiv(){
			var m = document.getElementsByTagName('meta'); 
		  	for(var i in m){ 
		   		if(m[i].httpEquiv && m[i].httpEquiv.match(/content-type/i)) { 
		     		return m[i].content; 
		   		}; 
		  	};
			return;
		};
		httpEquiv = getMetaHttpEquiv()
		if (httpEquiv) {
			return httpEquiv.match(/charset=(.*)($|;)/)[1];
		} else {
			return;
		}
	};
	this.getAccount = function() {
		return self.account;
	};
	this.setAccount = function(account) {
		self.account = account;
	};
	this.getUserAgent = function() {
		return navigator.userAgent;
	};
	this.getUrl = function() {
		var url = '';
		if (self.url != '') {
			url = self.url;
		} else {
			url = document.URL;
		}
		return escape(url.replace(/\/$/,''));
	};
	this.getPageTitle = function() {
		return escape(document.title.replace(/^\s*/,'').replace(/\s*$/,''));
	};
	this.getReferrer = function() {
		return escape(document.referrer);
	};
	this.getCampName = function() {
		return escape(parameters[self.campaignName]);
	};
	this.getCampSource = function() {
		return escape(parameters[self.campaignSource]);
	};
	this.getCampMedium = function() {
		return escape(parameters[self.campaignMedium]);
	};
	this.getCampContent = function() {
		return escape(parameters[self.campaignContent]);
	};
	this.getVisitor = function() {
		function createTdsv() {
			// Set for about 720 days, or about 2 years
			// Indicate first visit
			// console.log('New visitor being created.');
			self.setCookie('_tdsv', newVisitorId() + ".0", 720);
			return self.getCookie('_tdsv');
		};
		function newVisitorId() {
			return self.getUuid(15);
		};
		function getTdsv() {
			var tdsv = self.getCookie('_tdsv');
			// console.log('Existing visitor: ' + tdsv);
			if ( tdsv && tdsv.indexOf('.') == -1 ) {
				// Convert the old style cookie version 1
				tdsv = tdsv + ".1";
				// console.log('Upgraded tdsv with visit count: ' + tdsv);
				self.setCookie("_tdsv", tdsv, 720)				
			} 
			if ( tdsv && tdsv.split('.').length == 2) {
				// Convert the old style cookie version 2
				tdsv = tdsv + "." + self.sessionId();
				// console.log('Upgraded tdsv with session: ' + tdsv);
				self.setCookie("_tdsv", tdsv, 720)
			}
			return tdsv;
		};
		return (getTdsv() || createTdsv());
	};
	this.incrementVisitCount = function() {
		// tdsv has several parts:  <visitor>.<visits>.<current_visit_timestamp>.<previous_visit_timestamp>
		var tdsv = self.getVisitor();
		var currentSessionTimestamp = self.getCookie('_tdsb').split('.')[0]
		var parts = tdsv.split('.');
		if (parts[1]) parts[1]++; else parts[1] = 1;
		if (parts[2]) parts[3] = parts[2]; 		// Move current session to previous session
		parts[2] = currentSessionTimestamp;		// Save current session
		var new_tdsv = parts.join('.')
		// console.log('Incremented visit count to: ' + new_tdsv);
		self.setCookie('_tdsv', new_tdsv, 720);
		return new_tdsv;
	};
	this.sessionId = function() {
		var tdsb = self.getCookie('_tdsb');
		return tdsb.split('.')[0];
	};
	this.getSession = function() {
		function setTdsb(value) {
			// Session cookie set for 30 minutes
			self.setCookie('_tdsb', value, 0.5/24);
		};
		function currentSession() {
			var tdsb, tdsc;

			// If both cookies then we have an existing session.  Set the _tdsb cookie
			// again to extend the session further
			if ((tdsb = self.getCookie('_tdsb')) && (tdsc = self.getCookie('_tdsc'))) {
				parts = tdsb.split('.');
				if (parts[1]) {parts[1]++;} else {parts[1] = 1};
				session_id = parts.join('.')
				setTdsb(session_id);
				// console.log('Returning existing session (tdsb): ' + session_id);				
				return session_id;
			};
			return false;
		};
		function createNewSession() {
			// console.log('Creating new session.');
			var tdsb = self.getCookie('_tdsb');
			var tdsc = self.getCookie('_tdsc');

			if (!tdsb) {
				tdsb = getNewSessionId() + ".1";
				// console.log('Creating new session (tdsb): ' + tdsb);
				setTdsb(tdsb); // .1 means new session
			};
			// Session cookie deleted at end of browser session
			// Hence if missing then a new session must be started
			if (!tdsc) {
				tdsb = self.getCookie('_tdsb');
				var parts = tdsb.split('.');
				parts[1] = 1;
				tdsb = parts.join('.');
				setTdsb(tdsb);
				// console.log('Creating new session (tdsc): ' + tdsb);
				self.setCookie('_tdsc', tdsb);
			};
			self.incrementVisitCount();
			// console.log('Create new session is returning: ' + tdsb);
			return tdsb;
		};
		function getNewSessionId() {
			var time = new Date();
			var gmtSecs = Math.round(time.getTime() / 1000) + (time.getTimezoneOffset() * 60);
			return gmtSecs;
		};
		var session = currentSession();
		if (!session) { session = createNewSession() };
		return session;
	};
	/*
		Copyright (c) Copyright (c) 2007, Carl S. Yestrau All rights reserved.
		Code licensed under the BSD License: http://www.featureblend.com/license.txt
		Version: 1.0.4
		http://www.featureblend.com/javascript-flash-detection-library.html
	*/
	this.getFlashVersion = function(){
	    var self = this;
	    self.installed = false;
	    self.raw = "";
	    self.major = -1;
	    self.minor = -1;
	    self.revision = -1;
	    self.revisionStr = "";
	    var activeXDetectRules = [
	        {
	            "name":"ShockwaveFlash.ShockwaveFlash.7",
	            "version":function(obj){
	                return getActiveXVersion(obj);
	            }
	        },
	        {
	            "name":"ShockwaveFlash.ShockwaveFlash.6",
	            "version":function(obj){
	                var version = "6,0,21";
	                try{
	                    obj.AllowScriptAccess = "always";
	                    version = getActiveXVersion(obj);
	                }catch(err){}
	                return version;
	            }
	        },
	        {
	            "name":"ShockwaveFlash.ShockwaveFlash",
	            "version":function(obj){
	                return getActiveXVersion(obj);
	            }
	        }
	    ];
	    /**
	     * Extract the ActiveX version of the plugin.
	     * 
	     * @param {Object} The flash ActiveX object.
	     * @type String
	     */
	    var getActiveXVersion = function(activeXObj){
	        var version = -1;
	        try{
	            version = activeXObj.GetVariable("$version");
	        }catch(err){}
	        return version;
	    };
	    /**
	     * Try and retrieve an ActiveX object having a specified name.
	     * 
	     * @param {String} name The ActiveX object name lookup.
	     * @return One of ActiveX object or a simple object having an attribute of activeXError with a value of true.
	     * @type Object
	     */
	    var getActiveXObject = function(name){
	        var obj = -1;
	        try{
	            obj = new ActiveXObject(name);
	        }catch(err){
	            obj = {activeXError:true};
	        }
	        return obj;
	    };
	    /**
	     * Parse an ActiveX $version string into an object.
	     * 
	     * @param {String} str The ActiveX Object GetVariable($version) return value. 
	     * @return An object having raw, major, minor, revision and revisionStr attributes.
	     * @type Object
	     */
	    var parseActiveXVersion = function(str){
	        var versionArray = str.split(",");//replace with regex
	        return {
	            "raw":str,
	            "major":parseInt(versionArray[0].split(" ")[1], 10),
	            "minor":parseInt(versionArray[1], 10),
	            "revision":parseInt(versionArray[2], 10),
	            "revisionStr":versionArray[2]
	        };
	    };
	    /**
	     * Parse a standard enabledPlugin.description into an object.
	     * 
	     * @param {String} str The enabledPlugin.description value.
	     * @return An object having raw, major, minor, revision and revisionStr attributes.
	     * @type Object
	     */
	    var parseStandardVersion = function(str){
	        var descParts = str.split(/ +/);
	        var majorMinor = descParts[2].split(/\./);
	        var revisionStr = descParts[3];
	        return {
	            "raw":str,
	            "major":parseInt(majorMinor[0], 10),
	            "minor":parseInt(majorMinor[1], 10), 
	            "revisionStr":revisionStr,
	            "revision":parseRevisionStrToInt(revisionStr)
	        };
	    };
	    /**
	     * Parse the plugin revision string into an integer.
	     * 
	     * @param {String} The revision in string format.
	     * @type Number
	     */
	    var parseRevisionStrToInt = function(str){
	        return parseInt(str.replace(/[a-zA-Z]/g, ""), 10) || self.revision;
	    };
	    /**
	     * Constructor, sets raw, major, minor, revisionStr, revision and installed public properties.
	     */
        if(navigator.plugins && navigator.plugins.length>0){
            var type = 'application/x-shockwave-flash';
            var mimeTypes = navigator.mimeTypes;
            if(mimeTypes && mimeTypes[type] && mimeTypes[type].enabledPlugin && mimeTypes[type].enabledPlugin.description){
                var version = mimeTypes[type].enabledPlugin.description;
                var versionObj = parseStandardVersion(version);
                self.raw = versionObj.raw;
                self.major = versionObj.major;
                self.minor = versionObj.minor; 
                self.revisionStr = versionObj.revisionStr;
                self.revision = versionObj.revision;
                self.installed = true;
            }
        }else if(navigator.appVersion.indexOf("Mac")==-1 && window.execScript){
            var version = -1;
            for(var i=0; i<activeXDetectRules.length && version==-1; i++){
                var obj = getActiveXObject(activeXDetectRules[i].name);
                if(!obj.activeXError){
                    self.installed = true;
                    version = activeXDetectRules[i].version(obj);
                    if(version!=-1){
                        var versionObj = parseActiveXVersion(version);
                        self.raw = versionObj.raw;
                        self.major = versionObj.major;
                        self.minor = versionObj.minor; 
                        self.revision = versionObj.revision;
                        self.revisionStr = versionObj.revisionStr;
                    }
                }
            }
        };
		if (self.installed) {
			return self.major + '.' + self.minor;
		} else {
			return '-';
		};
	};
	this.setCookie = function(name, value, daysToExpire, absolutePath) {  
		var expire = '';
		var path = '; path=/';
		 
	    if (daysToExpire) {  
	      var d = new Date();  
	      d.setTime(d.getTime() + (86400000 * parseFloat(daysToExpire)));  
	      expire = '; expires=' + d.toGMTString();  
	    }
		if (absolutePath) path = "; path=" + absolutePath;
		var cookieValue = escape(name) + '=' + escape(value || '') + expire + path;
		// console.log("Setting cookie: " + cookieValue);
	    document.cookie = cookieValue;
		return self.getCookie(name);
	};  
	this.getCookie = function(name) {
	    var cookie = document.cookie.match(new RegExp(escape(name) + "\s*=\s*(.*?)(;|$)"));
		var cookieValue = cookie ? unescape(cookie[1]) : null;
		// console.log("Getting cookie " + name + ": " + cookieValue)
	    return (cookieValue); 
	};  
	this.eraseCookie = function(name) {  
	    var cookie = self.getCookie(name) || true;  
	    this.setCookie(name, '', -1);  
	    return cookie;  
	};  
	this.acceptCookie = function() {  
	    if (typeof navigator.cookieEnabled == 'boolean') {  
	      return navigator.cookieEnabled;  
	    }  
	    this.setCookie('_test', '1');  
	    return (this.eraseCookie('_test') === '1');  
	}; 	
	this.setCampName = function(name) {
		campaignName = name;
	};
	this.setCampSource = function(name) {
		campaignSource = name;
	};
	this.setCampMedium = function(name) {
		campaignMedium = name;
	};
	this.setCampContent = function(name) {
		campaignContent = name;
	};
	/*
	File: Math.uuid.js
	Version: 1.3
	Change History:
	  v1.0 - first release
	  v1.1 - less code and 2x performance boost (by minimizing calls to Math.random())
	  v1.2 - Add support for generating non-standard uuids of arbitrary length
	  v1.3 - Fixed IE7 bug (can't use []'s to access string chars.  Thanks, Brian R.)
	  v1.4 - Changed method to be "Math.uuid". Added support for radix argument.  Use module pattern for better encapsulation.

	Latest version:   http://www.broofa.com/Tools/Math.uuid.js
	Information:      http://www.broofa.com/blog/?p=151
	Contact:          robert@broofa.com
	----
	Copyright (c) 2008, Robert Kieffer
	All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

	    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer \
		in the documentation and/or other materials provided with the distribution.
	    * Neither the name of Robert Kieffer nor the names of its contributors may be used to endorse or promote products derived from 
		this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
	BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
	SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	*/

	/*
	 * Generate a random uuid.
	 *
	 * USAGE: Math.uuid(length, radix)
	 *   length - the desired number of characters
	 *   radix  - the number of allowable values for each character.
	 *
	 * EXAMPLES:
	 *   // No arguments  - returns RFC4122, version 4 ID
	 *   >>> Math.uuid()
	 *   "92329D39-6F5C-4520-ABFC-AAB64544E172"
	 * 
	 *   // One argument - returns ID of the specified length
	 *   >>> Math.uuid(15)     // 15 character ID (default base=62)
	 *   "VcydxgltxrVZSTV"
	 *
	 *   // Two arguments - returns ID of the specified length, and radix. (Radix must be <= 62)
	 *   >>> Math.uuid(8, 2)  // 8 character ID (base=2)
	 *   "01001010"
	 *   >>> Math.uuid(8, 10) // 8 character ID (base=10)
	 *   "47473046"
	 *   >>> Math.uuid(8, 16) // 8 character ID (base=16)
	 *   "098F4D35"
	 */
	this.getUuid = function(len, radix) {
		var CHARS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split(''); 
	  	var chars = CHARS, uuid = [], rnd = Math.random;
	    radix = radix || chars.length;
	    if (len) {
	      // Compact form
	      for (var i = 0; i < len; i++) uuid[i] = chars[0 | rnd()*radix];
	    } else {
	      // rfc4122, version 4 form
	      var r;
	      // rfc4122 requires these characters
	      uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-';
	      uuid[14] = '4';
	      // Fill in random data.  At i==19 set the high bits of clock sequence as
	      // per rfc4122, sec. 4.1.5
	      for (var i = 0; i < 36; i++) {
	        if (!uuid[i]) {
	          r = 0 | rnd()*16;
	          uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r & 0xf];
	        };
	      };
	    };
	    return uuid.join('');
	};
	this.getUniqueRequest = function() {
		return self.getUuid(10, 10);
	};
	this.parseParameters = function(){
		var objURL = new Object();
		window.location.search.replace(
			new RegExp( "([^?=&]+)(=([^&]*))?", "g" ),

			// For each matched query string pair, add that
			// pair to the URL struct using the pre-equals
			// value as the key.
			function( $0, $1, $2, $3 ) {
				objURL[ $1 ] = $3;
			}
		);
		return objURL;
	};
	// Track link
	this.trackLink = function(linkId) {
		if (!linkId) return;
		tracker = self;
		element = document.getElementById(linkId);
		if (element) {
			href = element.href.replace(/\/#$/, '');
			// console.log("Linking to: " + href);
			f = function(e) {
				tracker.trackPageview(href);
				if (e.preventDefault) e.preventDefault();
				e.stopPropagation();
				window.location = this.href;
			};
			element.onclick = f;
		} else {
			// console.log('Element not found in the DOM: ' + linkId);
		};
	};
	// Form handling - send form fields to tracker
	this.trackForm = function(form, fieldIds) {
		
	};
	// Track Events
	this.trackEvent = function(category, action, label, value) {
		
	};
	// Track Transactions
	this.trackTrans = function() {
		
	};
	// Constructor
	this.account = account;
	parameters = this.parseParameters();
	this.urlParams = {
		// &utses must be before &utvis
		"utac": this.getAccount, "utses": this.getSession, "utvis": this.getVisitor,
		"utmdt": this.getPageTitle,	"utmsr": this.getScreenSize, "utmsc": this.getColorDepth, 
		"utmul": this.getLanguage, "utmcs": this.getCharset, "utmfl": this.getFlashVersion, 
		"utmn": this.getUniqueRequest,
		"utm_campaign": this.getCampName, "utm_source": this.getCampSource,
		"utm_medium": this.getCampMedium, "utm_content": this.getCampContent,
		"utmp": this.getUrl
	};
};

