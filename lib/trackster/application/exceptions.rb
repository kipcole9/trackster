module Trackster
  module Application
    module Exceptions
      def self.included(base)
        base.class_eval <<-EOF
          rescue_from Exception do |exception|
            notify_hoptoad(exception)
            handle_exception exception, :message => I18n.t('sorry'), :status => 500
          end if Rails.env == "production"
       
          rescue_from CanCan::AccessDenied do |exception|
            access_denied
          end

          rescue_from ActiveRecord::RecordNotFound do |exception|
            handle_exception exception, :message => I18n.t('not_found'), :status => 404
          end
  
          rescue_from ActionView::MissingTemplate do |exception|
            notify_hoptoad(exception)
            page_or_format_not_found(exception)
          end
  
          rescue_from Activation::CodeNotFound do |exception|
            flash[:alert] = I18n.t('authorizer.unknown_activation_code')
            redirect_to login_url
          end

          rescue_from Activation::UserAlreadyActive do |exception|
            flash[:alert] = I18n.t('authorizer.user_already_active')
            redirect_back_or_default
          end
        EOF
      end
    
    private
  
      def page_or_format_not_found(exception = nil)
        message = html_format? ? I18n.t('not_found') : I18n.t('format_not_found', :format => params[:format])
        handle_exception exception, :message => message, :status => 404
      end
  
      def handle_exception(exception, options)
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