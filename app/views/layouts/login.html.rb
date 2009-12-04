html do
  head do
    meta :"http-equiv" => "content-type", :content => "text/html;charset=utf-8"
  	header_link :rel => "icon", :type => "image/vnd.microsoft.icon", :href => "/favicon.ico"
    title "#{Trackster::Config.banner}: #{page_title}"
    stylesheet_merged (internet_explorer? ? :ie : :base), :media => "screen, print"
    stylesheet_merged theme_css
    javascript_merged :base
  end  
  body do
    theme_has_custom_branding? ? include(theme_branding) : include("widgets/branding")
    
    store (yield(:page) || yield)
   
    clear do
      column :width => 12, :id => 'site_info' do
        include 'widgets/footer'
      end
    end
    javascript yield :javascript
  end
end