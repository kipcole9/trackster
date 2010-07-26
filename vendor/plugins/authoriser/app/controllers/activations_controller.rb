class ActivationsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :set_mailer_url_defaults, :only => :create

  def new
    @user = User.find_using_perishable_token(params[:activation_code], 1.week) || (raise Activation::CodeNotFound)
    raise Activation::UserAlreadyActive if @user.active?
  end

  def create
    @user = User.find_using_perishable_token(params[:id], 1.week) || (raise Activation::CodeNotFound)
    raise Activation::UserAlreadyActive if @user.active?
    
    if @user.activate!(params)
      # @user.reset_perishable_token!
      flash[:notice] = I18n.t('authorizer.user_activated')
      UserMailer.deliver_activation(@user)
      UserSession.create(@user)
      clear_return_location
      redirect_to edit_user_path(@user)
    else
      flash[:alert] = I18n.t('authorizer.couldnt_activate')
      redirect_to root_path
    end

  end
  
  
protected
  def require_no_user
    current_user_session.destroy if current_user
  end

  def set_mailer_url_defaults
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
end