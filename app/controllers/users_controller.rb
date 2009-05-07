class UsersController < ApplicationController
  require_role  [Role::ADMIN_ROLE, Role::ACCOUNT_ROLE], :except => [:activate, :change_password, :update_password, :edit, :update]
  before_filter :set_mailer_url_defaults, :only => [:create, :activate]
  before_filter :check_edit_permission, :only => [:edit, :update]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge, :edit, :update]
  before_filter :find_users, :only => [:index]
 
  def index
    respond_to do |format|
      format.js   {render :partial => 'user', :collection => @users}
      format.html { }
    end
  end
  
  def create
    @user = User.new(params[:user])
    @user.password = ActiveSupport::SecureRandom.base64(6)
    @user.password_confirmation = @user.password
    @user.account = current_user.account if @user.account_id.blank?
    @user.register! if @user && @user.valid?
    success = @user && @user.valid?
    if success && @user.errors.empty?
      flash[:notice] = t("user_created_pending_activation")
      redirect_back_or_default('/')
    else
      flash[:error]  = t('could_not_create_user')
      render :action => 'new'
    end
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = t("user_updated")
      redirect_back_or_default('/')
    else
      flash[:error]  = t('user_not_updated')
      render :action => 'edit'
    end
  end
  
  def activate
    logout_keeping_session!
    @user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && @user && !@user.active?
      @user.activate!
      flash[:notice] = t('signup_complete')
    when params[:activation_code].blank?
      flash[:error] = t('missing_activation_code')   
    else 
      flash[:error]  = t('unknown_activation_code')
    end
    redirect_back_or_default('/')    
  end
  
  def change_password
    @user = current_user
  end

  def update_password
    if @user = User.authenticate(params[:user][:login], params[:user][:password])
      @user.password = params[:user][:new_password]
      @user.password_confirmation = params[:user][:new_password_confirmation]  
      if @user.save
        flash[:notice] = t('password_changed')
        redirect_back_or_default('/')
      else
        flash[:error] = t('password_could_not_be_changed')
        render :action => :change_password
      end
    else 
      flash[:error]  = t('unknown_user_or_password')
      redirect_back_or_default('/')
    end    
  end
  
  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

protected
  def find_user
    @user = user_scope.find(params[:id])
  end

  def find_users
    @users = user_scope.find(:all, :conditions => conditions_from_params)
  end

  def set_mailer_url_defaults
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
  
  def check_edit_permission
    access_denied unless params[:id].to_i == current_user.id || current_user.has_role?(Role::ADMIN_ROLE)
  end
  
  def user_scope
    if current_user.has_role?(Role::ADMIN_ROLE)
      User
    else
      current_user.account.users
    end
  end
  
  def conditions_from_params
    return {} if params[:search].blank?
    search = "%#{params[:search]}%"
    ['given_name like ? or family_name like ?', search, search ]
  end
end
