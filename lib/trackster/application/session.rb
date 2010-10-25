module Trackster
  module Application
    module Session
      def self.included(base)
        if base.respond_to? :helper_method
          base.send :helper_method, :current_account, :internet_explorer?, :logged_in?, :current_user, :current_user_agent
        end
      end
    
    protected 
      def store_location
        session[:return_to] = request.request_uri if html_format? && !request.xhr? 
      end
      
      def clear_return_location
        session[:return_to] = nil
      end

      def redirect_back_or_default(default = root_path)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
      end
      
      def set_mailer_url_defaults
        ActionMailer::Base.default_url_options[:host] = request.host_with_port
      end

      def html_format?
        params[:format].nil? || params[:format] == 'html'
      end

      def current_user_session
        return @current_user_session if defined?(@current_user_session)
        @current_user_session = UserSession.find
      end

      def current_user
        return @current_user if defined?(@current_user)
        User.current_user = current_user_session && current_user_session.record
        @current_user = User.current_user
      end

      def account_exists?
        raise ActiveRecord::RecordNotFound, "No such account: '#{request.host}'" unless current_account
      end

      def account_subdomain
        @account_subdomain ||= current_subdomain ? current_subdomain.split('.').first : User::ADMIN_USER
      end

      def current_account
        unless @current_account 
          @current_account = (Account.find_by_subdomain(account_subdomain) || Account.find_by_custom_domain(request.host))
          Account.current_account = @current_account
        end
        @current_account
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
      
      # IE is detected the MSIE string followed by a version number
      # The string itself is in many other browsers of the past
      def internet_explorer?
        current_user_agent =~ /MSIE \d/
      end    
    end
  end
end