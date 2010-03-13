# This controller handles the login/logout function of the site.  
class UserSessionsController < ApplicationController
  #unloadable
  layout 'login'
  
  def new
    @user_session = UserSession.new
  end

  def create
    if (u = User.find_by_email(params[:user_session][:email])) && u.admin?
      @user_session = UserSession.new(params[:user_session])
    else
      @user_session = current_account.user_sessions.new(params[:user_session])
    end
    if @user_session.save
      flash[:notice] = I18n.t('authorizer.logged_in_as', :name => u && u.name)
      redirect_to root_path
    else
      flash[:alert] = I18n.t('authorizer.could_not_login_as', :name => u && u.name)
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy if current_user
    redirect_to login_path
  end

  def _page_title
    ''
  end
  
end
