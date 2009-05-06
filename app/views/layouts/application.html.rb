html do
  head do
    title "VideoInEmail Analytics"
    stylesheet_merged :base
    javascript_merged :base
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
    store "<script src=http://vietools.com:8080/_tks.js type=text/javascript />"
    javascript yield(:javascript)
    javascript "tracker = new _tks('tk-00001-1'); tracker.trackPageview();"
  end
end