html do
  head do
    meta :"http-equiv" => "content-type", :content => "text/html;charset=utf-8"
    meta :name => "csrf-token", :content => form_authenticity_token
    meta :name => "csrf-param", :content => request_forgery_protection_token
  	header_link :rel => "icon", :type => "image/vnd.microsoft.icon", :href => theme_favicon_path
    title "#{Trackster::Config.banner}: #{page_title}"
    stylesheet_merged (internet_explorer? ? :ie : :base), :media => "screen, print"
    stylesheet_merged theme_css
    javascript_merged :base
  end  
  body do
    theme_has_custom_branding? ? include(theme_branding) : include("widgets/branding")
    store (yield(:page) || yield)
  end
end