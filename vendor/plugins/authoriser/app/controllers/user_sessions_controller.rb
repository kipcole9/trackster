# This controller handles the login/logout function of the site.  
class UserSessionsController < ApplicationController
  unloadable
  layout 'login'
  
  def new
    @user_session = UserSession.new
  end

  def create
    user = User.find_by_email(params[:user_session][:email])
    @user_session = admin_session || account_user_session || agent_account_user_session || nil_session
    
    if @user_session.save
      flash[:notice] = I18n.t('authorizer.logged_in_as', :name => user && user.name)
      redirect_to root_path
    else
      flash[:alert] = I18n.t('authorizer.could_not_login_as', :name => params[:user_session][:email])
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy if current_user
    redirect_to login_path
  end

protected
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
  
  def _page_title
    ''
  end
  
end
