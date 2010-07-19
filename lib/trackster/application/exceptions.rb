module Trackster
  module Application
    module Exceptions
      def included(base)
        class_eval <<-EOF
          rescue_from CanCan::AccessDenied do |exception|
            access_denied
          end

          rescue_from ActiveRecord::RecordNotFound do |exception|
            flash[:alert] = I18n.t('not_found')
            redirect_back_or_default
          end
  
          rescue_from ActionView::MissingTemplate do |exception|
            flash[:alert] = I18n.t('format_not_found', :format => params[:format] || "html")
            redirect_back_or_default
          end
  
          rescue_from Activation::CodeNotFound do |exception|
            flash[:alert] = I18n.t('activation.activation_code_not_found')
            redirect_back_or_default
          end

          rescue_from Activation::UserAlreadyActivated do |exception|
            flash[:alert] = I18n.t('activation.user_already_activated')
            redirect_back_or_default
          end
        EOF
      end
    end
  end
end