html do
  head do
    title "VideoInEmail Analytics"
    meta :"http-equiv" => "content-type", :content => "text/html;charset=UTF-8"  
    internet_explorer? ? stylesheet_merged(:ie) : stylesheet_merged(:base)
    javascript_merged :base
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