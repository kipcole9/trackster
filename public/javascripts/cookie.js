var Cookie = {  
  set: function(name, value, daysToExpire, absolutePath) {  
    var expire = '';
	var path = '; path=/';
	
    if (daysToExpire != undefined) {  
      var d = new Date();  
      d.setTime(d.getTime() + (86400000 * parseFloat(daysToExpire)));  
      expire = '; expires=' + d.toGMTString(); 

    }
	if (absolutePath) path = "; path=" + absolutePath;
    return (document.cookie = escape(name) + '=' + escape(value || '') + expire + path);  
  },  
  get: function(name) {  
    var cookie = document.cookie.match(new RegExp(escape(name) + "\s*=\s*(.*?)(;|$)"));
    return (cookie ? unescape(cookie[1]) : null);  
  },  
  erase: function(name) {  
    var cookie = Cookie.get(name) || true;  
    Cookie.set(name, '', -1);  
    return cookie;  
  },  
  accept: function() {  
    if (typeof navigator.cookieEnabled == 'boolean') {  
      return navigator.cookieEnabled;  
    }  
    Cookie.set('_test', '1');  
    return (Cookie.erase('_test') === '1');  
  }  
};