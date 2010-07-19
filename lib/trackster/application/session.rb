module Trackster
  module Application
    module Session
      def self.included(base)
        base.send :helper_method, :current_account, :internet_explorer?, :logged_in?, :current_user if base.respond_to? :helper_method
      end
    
    protected
      def logged_in?
        current_user
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
          @current_account = (Account.find_by_name(account_subdomain) || Account.find_by_custom_domain(request.host))
          Account.current_account = @current_account
        end
        @current_account
      end
      
      # IE is detected the MSIE string followed by a version number
      # The string itself is in many other browsers of the past
      def internet_explorer?
        current_user_agent =~ /MSIE \d/
      end    
    end
  end
end