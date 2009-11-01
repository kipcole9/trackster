class RedirectsController < ApplicationController
  require_role  [Role::ADMIN_ROLE, Role::ACCOUNT_ROLE], :except => [:redirect, :show, :index]
  before_filter       :retrieve_property, :only => [:new, :create, :index]
  before_filter       :retrieve_redirect, :only => [:edit, :update, :destroy, :show]
  before_filter       :retrieve_redirects, :only => :index

  def new
    render :action => 'edit'
  end

  def edit
    respond_to do |format|
      format.html { }    
      format.js   { render :partial => 'redirect_form', :locals => {:redirect => @redirect} }
    end
  end

  def show
    respond_to do |format|
      format.html { }
      format.js   { render_list_item @redirect, 'redirect_summary' }
    end
  end

  def create
    @redirect = user_create_scope.new(params[:redirect])
    @redirect.property = @property
    @redirect.account = @property.account
    if @redirect.save
      flash[:notice] = t('.redirect_created', :name => @redirect.name)
      redirect_back_or_default('/')
    else
      flash[:error] = t('.redirect_not_created', :name => @redirect.name)
      render :action => 'edit'
    end
  end

  def update
    if @redirect.update_attributes(params[:redirect])
      flash[:notice] = t('.redirect_updated', :name => @redirect.name)
      redirect_back_or_default('/')
    else
      flash[:error] = t('.redirect_not_updated', :name => @redirect.name)
      render :action => 'edit'
    end
  end
  
  # This is the redirector.  It does as little as possible to ensure
  # speedy response.  Note that the web server will have a log record
  # for this interaction which the log parsing task will pick up and 
  # resolve for us.
  def redirect
    if !params[:redirect].blank? && redirection = Redirect.find_by_redirect_url(params[:redirect])
      query_string = URI.parse(request.url).query rescue nil
      redirect = query_string.blank? ? redirection.url : "#{redirection.url}?#{query_string}"
      redirect_to redirect
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
    @redirect = @property.redirects.find(params[:id])
  end

  def retrieve_redirects
    @redirects = @property.redirects.paginate(:page => params[:page])
  end
  
  def retrieve_property
    @property = user_scope(:property, current_user).find(params[:property_id]) if params[:property_id]
  end
  
  def user_create_scope
    @property.redirects
  end

end
