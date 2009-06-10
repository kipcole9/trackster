# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'login'
  
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:user][:login], params[:user][:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:user][:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_to root_url
      flash[:notice] = t('logged_in')
    else
      note_failed_signin
      @login       = params[:user][:login]
      @remember_me = params[:user][:remember_me]
      render :action => 'new'
    end
  end
  
  def destroy
    logout_killing_session!
    flash[:notice] = t('logged_out')
    redirect_to root_url
  end

  def _page_title
    ''
  end
  
protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = t('login_failed', :login => params[:user][:login])
    logger.warn "Failed login for '#{params[:user][:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
