html do
  head do
    title "VIE Corp Analytics"
    stylesheets 'reset.css', 'text.css', 'grid.css', 'layout.css', 'nav.css', 'tabricator.css', 
                'calendar.css', 'autocomplete.css', 'application.css', :media => "screen, print"
  end
  body do
    include "prototypes/branding"
    include "prototypes/page_heading"
    
    store (yield(:page) || yield)
   
    clear do
      column :width => 12, :id => 'site_info' do
        include 'widgets/footer'
      end
    end
    javascript yield :javascript
  end
end