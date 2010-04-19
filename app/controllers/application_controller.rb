# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
# Add a line to test

class ApplicationController < ActionController::Base
  include ExceptionLoggable
  include PageTitle

  helper            :all # include all helpers, all the time
  helper_method     :current_account, :internet_explorer?, :current_user_agent, :user_scope, :permitted_to?, :logged_in?, :current_user
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  before_filter     :account_exists?,         :except => :redirect
  after_filter      :store_location,          :except => [:new, :create, :update, :destroy, :edit, :validations, :preview,
                                                :unique, :activate, :change_password, :update_password, :redirect]
  before_filter     :force_login_if_required, :except => :redirect
  before_filter     :set_locale,              :except => :redirect
  before_filter     :set_timezone,            :except => :redirect
  before_filter     :set_chart_theme,         :except => :redirect
  
  layout            'application', :except => [:rss, :xml, :json, :atom, :vcf, :xls, :csv, :pdf, :js]


protected
  def force_login_if_required
    access_denied unless login_status_ok?
  end
  
  def login_status_ok?
    (logged_in? && current_account) || logging_in? || activation? || redirecting? || validating?
  end

  # Prededence:
  # => :lang parameter, if it can be matched with an available locale
  # => locale in the user profile, if they're logged in
  # => priority locale from the Accept-Language header of the request
  # => The default site locale
  def set_locale
    language = params.delete(:lang)
    locale = I18n.available_locales & [language] if language
    locale = current_user.locale if logged_in? && !locale
    locale ||= request.preferred_language_from(I18n.available_locales)
    I18n.locale = locale || I18n.default_locale
  end

  # Set the timezone to the users timezone. If there is none
  # or it cannot be set then use the browsers timezone.
  def set_timezone
    Time.zone = current_user.try(:timezone) || browser_timezone
  end
  
  def set_chart_theme
    Charting::FlashChart.config = theme_chart_config
  end
  
  def logged_in?
    current_user
  end
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    ApplicationController.benchmark "set current_user" do
      User.current_user = current_user_session && current_user_session.record
      @current_user = User.current_user
    end
  end

  def store_location
    session[:return_to] = request.request_uri unless request.xhr?
  end

  def redirect_back_or_default(default = '/')
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def logging_in?
    params[:controller] == "user_sessions"
  end
  
  def activation?
    params[:controller] == 'users' && params[:action] == 'activate'
  end
  
  def redirecting?
    params[:controller] == 'redirects' && params[:action] == 'redirect'
  end
  
  def validating?
    params[:controller] == 'validations'
  end

  def access_denied
    respond_to do |format|
      format.html do
        if logged_in?
          flash[:alert] = t('not_authorized')
          redirect_back_or_default('/')
        else
          flash[:alert] = t('must_login') unless flash[:alert]
          store_location
          redirect_to login_path
        end
      end
      # format.any doesn't work in rails version < http://dev.rubyonrails.org/changeset/8987
      # Add any other API formats here.  (Some browsers, notably IE6, send Accept: */* and trigger 
      # the 'format.any' block incorrectly. See http://bit.ly/ie6_borken or http://bit.ly/ie6_borken2
      # for a workaround.)
      format.any(:json, :xml, :rss) do
        request_http_basic_authentication 'Web Password'
      end
    end
  end
  alias_method :permission_denied, :access_denied
    
  # The browsers give the # of minutes that a local time needs to add to
  # make it UTC, while TimeZone expects offsets in seconds to add to 
  # a UTC to make it local.
  def browser_timezone
    return nil if cookies[:tzoffset].blank?
    @browser_timezone = begin
      cookies[:tzoffset].to_i.hours
    end
    @browser_timezone
  end
  
  def users_ip_address
    request.env["HTTP_X_REAL_IP"] || request.remote_addr || request.remote_ip
  end
  
  def account_exists?
    raise ActiveRecord::RecordNotFound, "No such account: '#{request.host}'" unless current_account
  end

  def account_subdomain
    @account_subdomain ||= current_subdomain ? current_subdomain.split('.').first : User::ADMIN_USER
  end
  
  def current_account
    unless @current_account 
      @current_account = (Account.find_by_name(account_subdomain) || Account.find_by_custom_domain(request.host))
      Account.current_account = @current_account
    end
    @current_account
  end
  
  def current_user_agent
    request.env["HTTP_USER_AGENT"]
  end

  def protect_against_forgery?
    request.xhr? ? false : super
  end
  
  # IE is detected the MSIE string followed by a version number
  # The string itself is in many other browsers of the past
  def internet_explorer?
    current_user_agent =~ /MSIE \d/
  end
  
  # Scope to controller for translation keys
  # that start with a '.'
  def t(symbol, options = {})
    key = symbol.to_s.match(/\A\.(.*)/) ? "#{params[:controller]}.#{$1}" : symbol
    super key, options
  end  

  def controller
    self
  end
  
  # Scope any finder with the appropriate constraints
  # based upon user's role
  def current_scope(klass)
    current_account.send(klass.to_s)
  end

end
