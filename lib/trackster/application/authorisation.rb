module Trackster
  module Application
    module Authorisation
      def self.included(base)
        class_eval <<-EOF
          alias_method :permission_denied, :access_denied
        EOF
      end
      
    protected
      def logged_in?
        current_user
      end
    
      def force_login_if_required
        access_denied unless login_status_ok?
      end

      def logging_in?
        params[:controller] == "user_sessions"
      end

      def activating?
        params[:controller] == 'activations'
      end

      def validating?
        params[:controller] == 'validations'
      end

      def resetting_password?
        params[:controller] == 'password_resets'
      end

      def access_denied
        respond_to do |format|
          format.html do
            if logged_in?
              flash[:alert] = t('not_authorized')
              redirect_back_or_default('/')
            else
              flash[:alert] = t('must_login') unless flash[:alert]
              save_location_for_after_login
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
      
      def save_location_for_after_login
        cookies[:sloc] = request.request_uri
      end
    end
  end
end