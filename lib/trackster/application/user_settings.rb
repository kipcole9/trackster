module Trackster
  module Application
    module UserSettings
      def self.included(base)
        base.send :helper_method, :current_user_agent if base.respond_to? :helper_method
      end
    
    protected
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

    end
  end
end