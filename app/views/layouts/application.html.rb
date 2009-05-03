html do
  head do
    title "VIE Corp Analytics"
    stylesheets 'reset.css', 'text.css', 'grid.css', 'layout.css', 'nav.css', 'tabricator.css', 
                'calendar.css', 'autocomplete.css', 'application.css', :media => "screen, print"
    javascripts :defaults, 'inflector.js', 'lowpro.js', 'concertina.js', 'tabricator.js', 'browser_timezone.js', 
                'cookie.js', 'swfobject.js', 'autocomplete.js', 'list.js', 'search.js'
    javascript yield(:jstemplates)
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
    javascript yield(:javascript)
  end
end