module Trackster
  module Application
    module Exceptions
      def included(base)
        class_eval <<-EOF
          rescue_from Exception do |exception|
            handle_exception e, :message => I18n.t('sorry'), :status => 500
          end
       
          rescue_from CanCan::AccessDenied do |exception|
            access_denied
          end

          rescue_from ActiveRecord::RecordNotFound do |exception|
            handle_exception e, :message => I18n.t('not_found'), :status => 404
          end
  
          rescue_from ActionView::MissingTemplate do |exception|
            format_not_found
          end
  
          rescue_from Activation::CodeNotFound do |exception|
            handle_exception e, :message => I18n.t('activation.activation_code_not_found'), :status => 422
          end

          rescue_from Activation::UserAlreadyActivated do |exception|
            handle_exception e, :message => I18n.t('activation.user_already_activated'), :status => 422
          end
        EOF
      end
    
    private
      
      def format_not_found
        handle_exception nil, :message => I18n.t('format_not_found', :format => params[:format] || "html"), :status => 404
      end
      
      def handle_exception(e, options)
        request.format = :html unless params[:api_key]
        respond_to do |format|
          format.html do
            flash[:alert] = options[:message]
            redirect_back_or_default
          end
          format.any do
            head :status => options[:status], :text => options[:message]
          end
        end
      end
      
    end
  end
end