<h4><%= property.name %></h4>
<p>This page provides information on how to set up your web property to capture tracking data that is
can be interpreted on this site for analytical purposes.</p>
<p>The first thing to note is that each account has a unique tracking code that
is used to uniquely identify tracking data for your account.  For your account <em><%= current_account.name %></em>
the tracking code is <em><%= current_account.tracker %></em>.  It will be used in the examples below.</p>
<p>The second thing to note is that only data tracking requests from defined properties such as <em><%= property.host %></em> will be considered. That is, you cannot request tracking data be stored for this account from sites you have not defined.  This is both a security measure and a means of protecting the integrity of the tracking data for your site.</p>
<br />
<h4>How to start tracking data collection</h4>
<p>To enable tracking for your site the strongly recommended approach is to embed two lines of javascript
into the pages of your web site.  An example of the code to be inserted in each page you want to track is as follows:</p>
<pre><code>
&lt;script src="http://<%= Trackster::Config.host -%>/_tks.js" type="text/javascript"&gt;&lt;/script&gt;
&lt;script&gt;
  tracker = new _tks('<%= current_account.tracker -%>');
  tracker.trackPageview();
&lt;/script&gt;
</code></pre>
<p>It is recommended this code be inserted just before the end of the body section of your web page. This placement
helps provide the best possible user experience and response time.</p>
<br />
<h4>Tracking email openings</h4>
<p>Since most email client software does not support the execution of javascript in emails an alternative approach is used
for these situations.  Within the html body of the email add the following line (the location of the placement within the email is not important).</p>
<pre><code>
&lt;img src="<%= root_url -%>tracker.gif?utmac=<%= property.tracker %>&utcat=email&utac=open" /&gt;
</code></pre>
<p>As discussed later, additional information can be added to this line such as a campaign name or a CRM identifier with helps further segment
the data for analysis.</p>
