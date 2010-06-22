class ActivationsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]

  def new
    @user = User.find_using_perishable_token(params[:activation_code], 1.week) || (raise Exception)
    raise Exception if @user.active?
  end

  def create
    @user = User.find_using_perishable_token(params[:id], 1.week) || (raise Exception)

    raise Exception if @user.active?

    @user.reset_perishable_token!
    if @user.activate!(params)
      UserSession.create(@user)
      redirect_to root_path
    else
      render :action => :new
    end
  end
  
protected
  def require_no_user
    current_user_session.destroy if current_user
  end

end