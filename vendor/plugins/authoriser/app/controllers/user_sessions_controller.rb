# This controller handles the login/logout function of the site.  
class UserSessionsController < ApplicationController
  unloadable
  layout 'login'
  
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = current_account.user_sessions.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "logged in"
      redirect_back_or_default('/')
    else
      flash[:error] = "couldn't log in"
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end

  def _page_title
    ''
  end
  
end
