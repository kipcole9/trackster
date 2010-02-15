html do
  head do
    meta :"http-equiv" => "content-type", :content => "text/html;charset=utf-8"
    meta :name => "csrf-token", :content => form_authenticity_token
    meta :name => "csrf-param", :content => request_forgery_protection_token
  	header_link :rel => "icon", :type => "image/vnd.microsoft.icon", :href => "/favicon.ico"
    title "#{Trackster::Config.banner}: #{page_title}"
    stylesheet_merged (internet_explorer? ? :ie : :base), :media => "screen, print"
    stylesheet_merged theme_css
    javascript_merged :base
    javascripts 'swfobject.js'
    javascript yield(:jstemplates)
  end
  body do
    theme_has_custom_branding? ? include(theme_branding) : include("widgets/branding")
    include "widgets/main_menu" 
    include "widgets/page_heading"
    
    store (yield(:page) || yield)
   
    clear do
      column :width => 12, :id => 'site_info' do
        include 'widgets/footer'
      end
    end
    case Rails.env 
      when "development"
        store "<script src='http://trackster.local/javascripts/tracker_debug.js' type='text/javascript' ></script>"
      when "staging"
        store "<script src='http://traphos.com:8080/_tks.js' type='text/javascript' ></script>"
      else
        store "<script src='http://traphos.com/_tks.js' type='text/javascript' ></script>"
    end
    javascript yield(:javascript)
  end
end