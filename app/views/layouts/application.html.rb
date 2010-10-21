html do
  head do
    meta :"http-equiv" => "content-type", :content => "text/html;charset=utf-8"
    meta :name => "csrf-token", :content => form_authenticity_token
    meta :name => "csrf-param", :content => request_forgery_protection_token
  	header_link :rel => "icon", :type => "image/vnd.microsoft.icon", :href => Trackster::Theme.favicon_path
    title "#{Trackster::Config.banner}: #{page_title}"
    stylesheet_merged (internet_explorer? ? :ie : :base), :media => "screen, print"
    stylesheet_merged Trackster::Theme.css
    stylesheet_merged :print, :media => 'print'
    stylesheet_merged Trackster::Theme.print_css, :media => 'print'    
    javascript_merged :base
    javascript yield(:jstemplates) if yield(:jstemplates)
  end
  body do
    Trackster::Theme.has_custom_branding? ? include(Trackster::Theme.branding) : include("widgets/branding")
    cache "main-menu/#{current_account['id']}/#{current_user['id']}/#{I18n.locale}" do
      include "widgets/main_menu"
    end
    
    column(:width => 12) { display_flash } if flash.any?
    store(yield(:page) || yield)
    column(:width => 12, :id => 'site_info') { include 'widgets/footer' }
    
    case Rails.env 
    when "development"
      # store "<script src='http://trackster.local/javascripts/tracker_debug.js' type='text/javascript' ></script>"
      # store "<script>tracker = new _tks; tracker.trackPageview();</script>"
    when "staging"
      store "<script src='http://traphos.com:8080/_tks.js' type='text/javascript' ></script>"
    else
      store "<script src='http://traphos.com/_tks.js' type='text/javascript' ></script>"
    end
    javascript yield(:javascript)
  end
end