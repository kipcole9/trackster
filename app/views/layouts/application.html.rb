html do
  head do
    title "Application Title"
    stylesheets 'reset.css', 'text.css', 'grid.css', 'layout.css', 'nav.css', 'tabricator.css', 
                'calendar.css', 'autocomplete.css', 'application.css', :media => "screen, print"
    javascripts :defaults, 'lowpro.js', 'concertina.js', 'tabricator.js', 'browser_timezone.js', 
                'cookie.js', 'swfobject.js', 'autocomplete.js', 'teams.js', 'groups.js', 'search.js'
    javascript yield :jstemplates
  end
  body do
    include "prototypes/branding"
    include "widgets/main_menu"
    include "prototypes/page_heading"
    
    store (yield(:page) || yield)
   
    clear do
      column :width => 12, :id => 'site_info' do
        include 'widgets/footer'
      end
    end
    javascript yield :javascript
    #javascripts 'tracker_debug.js'
    #javascript "tracker = new _tks(); tracker.setAccount('tks-12345-1'); tracker.trackPageview();"
  end
end