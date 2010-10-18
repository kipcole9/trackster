html do
  head do
    meta :"http-equiv" => "content-type", :content => "text/html;charset=utf-8"
    meta :name => "csrf-token", :content => form_authenticity_token
    meta :name => "csrf-param", :content => request_forgery_protection_token
  	header_link :rel => "icon", :type => "image/vnd.microsoft.icon", :href => Trackster::Theme.favicon_path
    title "#{Trackster::Config.banner}: #{page_title}"
    stylesheet_merged (internet_explorer? ? :ie : :base), :media => "screen, print"
    stylesheet_merged Trackster::Theme.css
    javascript_merged :base
  end  
  body do
    Trackster::Theme.has_custom_branding? ? include(Trackster::Theme.branding) : include("widgets/branding")
    store (yield(:page) || yield)
  end
end