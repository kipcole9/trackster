html do
  head do
    meta :"http-equiv" => "content-type", :content => "text/html;charset=utf-8"
    meta :name => "csrf-token", :content => form_authenticity_token
    meta :name => "csrf-param", :content => request_forgery_protection_token
  	header_link :rel => "icon", :type => "image/vnd.microsoft.icon", :href => Trackster::Theme.favicon_path
    title page_title
    stylesheet_merged (internet_explorer? ? :ie : :base), :media => "screen, print"
    stylesheet_merged Trackster::Theme.css, :media => 'screen' unless params[:print]
    stylesheet_merged :print, :media => select_media
    stylesheet_merged Trackster::Theme.print_css, :media => select_media
    javascript_merged :base
    javascript yield(:jstemplates) if yield(:jstemplates)
  end
  body do
    Trackster::Theme.has_custom_branding? ? include(Trackster::Theme.branding(params[:print])) : include("widgets/branding")
    cache "main-menu/#{current_account['id']}/#{current_user['id']}/#{I18n.locale}" do
      include "widgets/main_menu"
    end
    
    column(:width => 12) { display_flash } if flash.any?
    store(yield(:page) || yield)
    column(:width => 12, :id => 'site_info') { include 'widgets/footer' }
    
    javascript yield(:javascript)
    tracking_script
  end
end