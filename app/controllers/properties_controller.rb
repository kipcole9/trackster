class PropertiesController < ApplicationController
  require_role  [Role::ADMIN_ROLE, Role::ACCOUNT_ROLE]
  before_filter       :retrieve_property, :only => [:edit, :update, :destroy, :show]
  before_filter       :retrieve_properties, :only => :index
  layout              :select_layout
  
  def new
    render :action => 'edit'
  end
  
  def edit
    respond_to do |format|
      format.html { }      
      format.js   { render :partial => 'property_form', :locals => {:property => @property} }
    end
  end
  
  def index
    respond_to do |format|
      format.html {  }
      format.js   { render :partial => 'index', :layout => false }      
    end
  end
  
  def show
    respond_to do |format|
      format.html { }      
      format.js   { render_list_item @property, 'property_summary' }
    end
  end
  
  def create
    @property = user_scope.create(params[:property])
    if @property.valid?
      flash[:notice] = t('.property_created')
      redirect_back_or_default('/')
    else
      flash[:error] = t('.property_not_created')
      render :action => 'edit'
    end
  end
  
  def update
    if @property.update_attributes(params[:property])
      flash[:notice] = t('.property_updated')
      redirect_back_or_default('/')
    else
      flash[:error] = t('.property_not_updated')
      render :action => 'edit'
    end
  end
  
  def destroy
    @property.destroy
    respond_to do |format|
      format.html { redirect_back_or_default('/') }      
      format.js   { head :status => :ok }
    end
  end
  
private
  def select_layout
    if params[:action] == 'show'
      'dashboards'
    else
      'properties'
    end
  end
  
  def retrieve_property
    @property = user_scope.find(params[:id])
  end
  
  def retrieve_properties
    @properties = user_scope.paginate(:page => params[:page], :conditions => conditions_from_params)
  end
  
  def conditions_from_params
    return {} if params[:search].blank?
    search = "%#{params[:search]}%"
    ['name like ? or url like ?', search, search ]
  end
    
  def user_scope
    if current_user.has_role?(Role::ADMIN_ROLE)
      Property
    else
      current_user.account.properties
    end
  end
  
end
