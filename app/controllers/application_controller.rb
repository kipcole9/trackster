# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
# Add a line to test
class ApplicationController < ActionController::Base
  include Trackster::PageTitle
  include Trackster::Application::UserSettings
  include Trackster::Application::Session
  include Trackster::Application::Authorisation
  include Trackster::Application::Exceptions
  
  helper            :all # include all helpers, all the time

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter     :account_exists?
  before_filter     :force_login_if_required
  before_filter     :set_locale
  before_filter     :set_timezone
  before_filter     :set_chart_theme
  before_filter     Period
  
  after_filter      :store_location, :only => [:show, :index]
  
  def page_not_found
    raise ActiveRecord::RecordNotFound
  end
  
protected
  def controller
    self
  end

private
  def login_status_ok?
    (logged_in? && current_account) || resetting_password? || logging_in? || activating? || validating?
  end

  def protect_against_forgery?
    request.xhr? ? false : super
  end

  # Scope to controller for translation keys
  # that start with a '.'
  #def t(symbol, options = {})
  #  key = symbol.to_s.match(/\A\.(.*)/) ? "#{params[:controller]}.#{$1}" : symbol
  #  super key, options
  #end  

  
  # Scope any finder with the appropriate constraints
  # based upon user's role
  #def current_scope(klass)
  #  current_account.send(klass.to_s)
  #end

end
