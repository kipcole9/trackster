# This controller handles the login/logout function of the site.  
class UserSessionsController < ApplicationController
  unloadable
  layout 'login'
  
  def new
    @user_session = UserSession.new
    set_test_cookie
  end

  def create
    if cookies_cannot_be_set?
      flash[:alert] = I18n.t('authorizer.could_not_set_cookie')
      redirect_to login_path
    else
      delete_test_cookie
      user = User.find_by_email(params[:user_session][:email])
      @user_session = admin_session || account_user_session || agent_account_user_session || nil_session
    
      if @user_session.save
        flash[:notice] = I18n.t('authorizer.logged_in_as', :name => user && user.name)
        saved_location? ? redirect_to_saved_location : redirect_to(root_path)
      else
        flash[:alert] = I18n.t('authorizer.could_not_login_as', :name => params[:user_session][:email])
        render :action => :new
      end

    end
  end
  
  def destroy
    current_user_session.destroy if current_user
    redirect_to login_path
  end

protected
  def saved_location
    cookies[:sloc]
  end
  alias :saved_location? :saved_location
  
  def redirect_to_saved_location
    redirect_to saved_location
    cookies.delete :sloc
  end
  
  def admin_session
    if (u = User.find_by_email(params[:user_session][:email])) && u.admin?
      @user_session = UserSession.new(params[:user_session])
    end
    @user_session
  end
  
  def account_user_session
    if current_account.users.find_by_email(params[:user_session][:email])
      @user_session = current_account.user_sessions.new(params[:user_session])
    end
    @user_session
  end
  
  def agent_account_user_session
    if agent = current_account.agent
      @user_session = agent.user_sessions.new(params[:user_session])
    end
    @user_session  
  end
  
  def nil_session
    UserSession.new
  end
  
  def set_test_cookie
    #cookies[:trackstertest] = "set"
    #Rails.logger.debug "Cookie set to value '#{cookies[:trackstertest]}'"
  end
  
  def cookies_cannot_be_set?
    #Rails.logger.debug "Cookie can be set? value is '#{cookies[:trackstertest]}'"
    #cookies[:trackstertest].blank?
    false
  end

  def delete_test_cookie
    #cookies.delete :trackstertest
  end
end
