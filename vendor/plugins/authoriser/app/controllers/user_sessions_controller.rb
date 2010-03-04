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
      flash[:notice] = I18n.t('logged_in_as', :name => u && u.name)
      redirect_back_or_default('/')
    else
      flash[:alert] = I18n.t('counld_no_login_as', :name => u && u.name)
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy if current_user
    redirect_back_or_default
  end

  def _page_title
    ''
  end
  
end
