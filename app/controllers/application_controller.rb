# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
# Add a line to test
class ApplicationController < ActionController::Base
  include Trackster::PageTitle
  include Trackster::Application::UserSettings
  include Trackster::Application::Session
  include Trackster::Application::Authorisation
  #include Trackster::Application::Exceptions
  
  helper            :all # include all helpers, all the time

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation
  
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter     :account_exists?
  before_filter     :force_login_if_required
  before_filter     :set_locale
  before_filter     :set_timezone
  before_filter     Period

  after_filter      :store_location, :only => [:show, :index]

  def page_not_found
    raise ActiveRecord::RecordNotFound
  end
  
protected

  def controller
    self
  end
  
  def action
    params[:original_action] || params[:action]
  end
  
  def controllername
    params[:controller]
  end
  
  def template_exists?(template = nil)
    # Rails.logger.debug "Find Template: Asked to find #{template}"
    begin
      template_name = (template && template.is_a?(Hash)) ? template[:action] : template
      template_path = (template_name =~ /\// ? template_name : "#{params[:controller]}/#{template_name || params[:action]}") + ".#{params[:format]}"
      # Rails.logger.debug "Find Template: #{template_path}"
      return view_paths.find_template(template_path)
    rescue ActionView::MissingTemplate
      return false
    end
  end
  
#  def render_pdf(url = nil)
#    new_request = url_for(params.merge(:api_key => current_user.single_access_token, :print => true)).sub('.pdf','')
#    pdf_file = "#{Rails.root}/tmp/pdf-#{current_user[:id]}.pdf"
#    command = "/usr/local/bin/wkhtmltopdf \"#{new_request}\" #{pdf_file}"
#    raise "Can't execute: '#{command}'" unless system(command)
#    send_file(pdf_file, :filename => page_title, :type => 'application/pdf')
#  end
  
  def render_pdf(*render_args)
    params[:print] = true
    pdf_file = "#{Rails.root}/tmp/pdf-#{current_user[:id]}.pdf"
    html_file = "#{Rails.root}/tmp/html-#{current_user[:id]}.html"
    html = render_to_string(*render_args)
    html.gsub!("<head>","<head>\n<base href=\"http://#{request.host}\" />")
    File.open(html_file, 'w') {|f| f.write(html) }
    command = "/usr/local/bin/wkhtmltopdf #{html_file} #{pdf_file}"
    raise "Can't execute: '#{command}'" unless system(command)
    send_file(pdf_file, :filename => page_title, :type => 'application/pdf')
  end  

private
  def login_status_ok?
    (logged_in? && current_account) || resetting_password? || logging_in? || activating? || validating?
  end

  def protect_against_forgery?
    request.xhr? ? false : super
  end

end
