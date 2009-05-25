class RedirectsController < ApplicationController
  require_role  [Role::ADMIN_ROLE, Role::ACCOUNT_ROLE], :except => [:redirect, :show, :index]
  before_filter       :retrieve_redirect, :only => [:edit, :update, :destroy, :show]
  before_filter       :retrieve_redirects, :only => :index

  def new
    render :action => 'edit'
  end

  def edit
    respond_to do |format|
      format.js   { render :partial => 'redirect_form', :locals => {:redirect => @redirect} }
      format.html { }
    end
  end

  def show
    respond_to do |format|
      format.js   { render_list_item @redirect, 'redirect_summary' }
      format.html { }
    end
  end

  def create
    @redirect = user_create_scope.create(params[:redirect])
    if @redirect.valid?
      flash[:notice] = t('.redirect_created')
      redirect_back_or_default('/')
    else
      flash[:error] = t('.redirect_not_created')
      render :action => 'edit'
    end
  end

  def update
    if @redirect.update_attributes(params[:redirect])
      flash[:notice] = t('.redirect_updated')
      redirect_back_or_default('/')
    else
      flash[:error] = t('.redirect_not_updated')
      render :action => 'edit'
    end
  end
  
  # This is the redirector.  It does as little as possible to ensure
  # speedy response.  Note that the web server will have a log record
  # for this interaction which the log parsing task will pick up and 
  # resolve for us.
  def redirect
    if !params[:redirect].blank? && redirection = Redirect.find_by_redirect_url(params[:redirect])
      redirect_to redirection.url
    elsif params[:redirect].blank?
      Rails.logger.warn "Redirect with no parameter requested."
      head :status => 404
    else
      Rails.logger.warn "Unknown redirection requested: #{params[:redirect]}"
      head :status => 404
    end
  end

private
  def retrieve_redirect
    @redirect = user_scope(:redirect, current_user).find(params[:id])
  end

  def retrieve_redirects
    @redirects = user_scope(:redirect, current_user).paginate(:page => params[:page])
  end
  
  def user_create_scope
    current_user.account.redirects
  end

end
