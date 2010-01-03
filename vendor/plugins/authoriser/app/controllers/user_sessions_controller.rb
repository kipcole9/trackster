# This controller handles the login/logout function of the site.  
class UserSessionsController < ApplicationController
  #unloadable
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
      flash[:alert] = "couldn't log in"
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
