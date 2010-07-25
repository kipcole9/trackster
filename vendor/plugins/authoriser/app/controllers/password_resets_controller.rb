class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :set_mailer_url_defaults
  layout 'login'

  def create
    if @user = current_account.users.find_by_email(params[:user][:email])
      @user.reset_perishable_token!
      UserMailer.deliver_password_reset_instructions(@user)  
      flash[:notice] = I18n.t('authorizer.password_reset_intructions_mailed')  
      redirect_to login_url
    else  
      flash[:alert] = I18n.t('authorizer.no_user_on_account')  
      render :action => :new  
    end  
  end
  
  def update
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save
      flash[:notice] = I18n.t('authorizer.password_updated')
      redirect_to root_url
    else  
      render :action => :edit  
    end  
  end  

private  
  def load_user_using_perishable_token
    token = params[:user] ? params[:user][:perishable_token] : params[:id]
    unless @user = current_account.users.find_using_perishable_token(token) 
      flash[:alert] = I18n.t('authorizer.no_user_on_account')   
      redirect_to login_path
    end  
  end  

end