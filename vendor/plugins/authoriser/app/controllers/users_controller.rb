class UsersController < TracksterResources
  unloadable
  respond_to          :html
  before_filter       :set_mailer_url_defaults, :only => [:create, :activate]
  has_scope           :search

  def create
    if current_account.user_exists?(params[:user][:email])
      flash[:alert] = I18n.t('authorizer.user_already_on_account')
      redirect_back_or_default
      return
    elsif @user = User.exists?(params[:user][:email])
      current_account.add_user(@user, params[:user][:roles])
      UserMailer.deliver_added_to_account_notification(current_account, @user) if @user.errors.empty?
    else
      @user = User.add_new(params[:user])
      UserMailer.deliver_signup_notification(@user) if @user.errors.empty?
    end

    unless @user.errors.empty?
      flash.now[:alert] = I18n.t('authorizer.cant_create_new_user')
      render :action => :new
    else
      flash[:notice] = I18n.t('authorizer.new_user_created')
      redirect_back_or_default
    end
  end

protected
  def collection
    @users ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def set_mailer_url_defaults
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

end
