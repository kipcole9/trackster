# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionLoggable
  include AuthenticatedSystem
  include RoleRequirementSystem

  helper            :all # include all helpers, all the time
  helper_method     :current_account, :internet_explorer?, :current_user_agent, :user_scope
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  before_filter     :force_login_if_required
  before_filter     :set_locale
  before_filter     :set_timezone
  before_filter     :store_location, :except => [:new, :create, :update, :destroy, :edit, :validations, :unique, :activate]

  layout            'application', :except => [:rss, :xml, :json, :atom, :vcf, :xls, :csv, :pdf, :js]

  def _page_title
    I18n.t("#{params['controller']}.index.name", :default => params[:controller].titleize)
  end

  def force_login_if_required
    access_denied unless login_status_ok?
  end
  
  def login_status_ok?
    if current_user_agent =~ /W3C_Validator/ && Rails.env == "development"
      self.current_user = User.find_by_login('admin')
      return true
    end
    logged_in? || logging_in? || activation? || redirecting? || validating?
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

  def set_timezone
    Time.zone = logged_in? ? current_user.timezone : browser_timezone
  end

  def current_account
    current_user.account if current_user
  end

  def logging_in?
    params[:controller] == "sessions"
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
        store_location
        flash[:error] = t('must_login') unless flash[:error] || flash[:notice]
        redirect_to login_path
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

  def current_user_agent
    request.env["HTTP_USER_AGENT"]
  end

  def protect_against_forgery?
    request.xhr? ? false : super
  end
  
  def internet_explorer?
    current_user_agent =~ /.*MSIE.*/
  end
  
  # Scope to controller for translation keys
  # that start with a '.'
  def t(symbol, options = {})
    if symbol.to_s.match(/\A\.(.*)/)
      key = "#{params[:controller]}.#{$1}"
    else
      key = symbol
    end
    super key, options
  end  

  # Scope any finder with the appropriate constraints
  # based upon user's role
  def user_scope(model, user)
    klass = model.to_s.classify.constantize
    if user.has_role?(Role::ADMIN_ROLE)
      klass
    elsif user.has_role?(Role::ACCOUNT_ROLE)
      user.account.scope[model.to_s.pluralize]
    else
      klass.user(user)
    end
  end

end
