class UsersController < TracksterResources
  unloadable
  respond_to          :html, :xml, :json
  before_filter       :set_mailer_url_defaults, :only => [:create, :activate]
  has_scope           :search

  def create
    @user = User.new(params[:user])
    @user.reset_password if @user.password.blank?
    create! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end

  def change_password
    @user = current_user
  end

  def update_password
    if current_user.valid_password?(params[:user][:password])
      current_user.password = params[:user][:new_password]
      current_user.password_confirmation = params[:user][:new_password_confirmation]  
      if current_user.save
        flash[:notice] = t('authorizer.password_changed')
        redirect_back_or_default
      else
        flash[:alert] = t('authorizer.password_could_not_be_changed')
        render :action => :change_password
      end
    else 
      flash[:alert]  = t('authorizer.unknown_user_or_password')
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
