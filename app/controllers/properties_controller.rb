class PropertiesController < ApplicationController
  require_role  [Role::ADMIN_ROLE, Role::ACCOUNT_ROLE], :only => [:create, :new, :update, :destroy]
  before_filter       :retrieve_property, :except => [:index, :create, :new]
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
    @property = user_create_scope.create(params[:property])
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
  
  def overview
    # default render
  end

  # Here's where we implement most of the reporting.  Since reporting
  # is quite consistent but based upon different dimensions we can
  # generalise the solutions
  def method_missing(method, *args)
    if Track.session_dimensions.include?(params[:action])
      params[:action] = ['locality','region','country'] if params[:action] == 'locality'
      @site_summary = @property.tracks.visits.page_views_per_visit.duration.new_visit_rate.bounce_rate.by(params[:action])\
                          .having('visits > 0').order('visits DESC').between(Track.period_from_params(params)).all
      render :action => 'site_summary'
    elsif Track.loyalty_dimensions.include?(params[:action])
      @visit_summary = @property.tracks.visits.event_count.by(params[:action]).between(Track.period_from_params(params)).all.sort{|a,b| a[params[:action]].to_i <=> b[params[:action]].to_i }
      render :action => 'visit_summary'      
    elsif Track.event_dimensions.include?(params[:action])
      @site_summary = @property.tracks.page_views(:with_events).page_duration.bounce_rate.exit_rate.entry_rate.by(params[:action])\
                        .order('page_views DESC').between(Track.period_from_params(params)).all
      render :action => 'content_summary'

    else
      super
    end
  end

  def _page_title
    if @property
      "#{@property.name}"
    else
      super
    end
  end
  
private
  def select_layout
    if ['index','create','edit','destroy','update','new','show'].include?(params[:action])
      'properties'
    else
      'dashboards'
    end
  end
  
  def retrieve_property
    @property = user_scope(:properties, current_user).find(params[:id])
  end
  
  def retrieve_properties
    @properties = user_scope(:properties, current_user).paginate(:page => params[:page], :conditions => conditions_from_params)
  end
  
  def conditions_from_params
    return {} if params[:search].blank?
    search = "%#{params[:search]}%"
    ['name like ? or url like ?', search, search ]
  end
  
  def user_create_scope
    if current_user.has_role?(Role::ADMIN_ROLE)
      Property
    else
      current_user.account.properties
    end
  end
end
