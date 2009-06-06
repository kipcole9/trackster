class CampaignsController < ApplicationController
  require_role  [Role::ADMIN_ROLE, Role::ACCOUNT_ROLE], :except => [:show, :index]
  before_filter       :retrieve_campaign, :only => [:edit, :update, :destroy, :show]
  before_filter       :retrieve_property
  before_filter       :retrieve_campaigns, :only => :index
  layout              :choose_layout

  def new
    @campaign = user_create_scope.new
    @campaign.property = @property
    render :action => 'edit'
  end

  def edit
    respond_to do |format|
      format.js   { render :partial => 'campaign_form', :locals => {:campaign => @campaign} }
      format.html { }
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
      format.html { 
        @campaign_summary = @campaign.tracks.distribution.impressions.clicks_through.campaign_bounces.unsubscribes.by(:name).between(Track.period_from_params(params)).all
        render 'campaign_summary' }
      format.js   { render_list_item @campaign, 'campaign_summary' }        
    end
  end

  def create
    @campaign = user_create_scope.create(params[:campaign])
    if @campaign.valid?
      flash[:notice] = t('.campaign_created')
      redirect_back_or_default('/')
    else
      flash[:error] = t('.campaign_not_created')
      render :action => 'edit'
    end
  end

  def update
    if @campaign.update_attributes(params[:campaign])
      flash[:notice] = t('.campaign_updated')
      redirect_back_or_default('/')
    else
      flash[:error] = t('.campaign_not_updated')
      render :action => 'edit'
    end
  end
  
  def destroy
    if @campaign.destroy
      flash[:notice] = t('.campaign_deleted')
    else
      flash[:error] = t('.campaign_not_deleted')
    end
    redirect_back_or_default('/')    
  end
  
  def _page_title
    @campaign ? @campaign.name : super
  end

private
  def retrieve_campaign
    @campaign = user_scope(:campaign, current_user).find(params[:id])
  end
  
  def retrieve_property
    @property = user_scope(:property, current_user).find(params[:property_id]) if params[:property_id]
  end

  def retrieve_campaigns
    @campaigns = user_scope(:campaign, current_user).paginate(:page => params[:page], :conditions => conditions_from_params)
  end

  def user_create_scope
    if current_user.has_role?(Role::ADMIN_ROLE)
      Campaign
    else
      current_user.account.campaigns
    end
  end

  def conditions_from_params
    return {} if params[:search].blank?
    search = "%#{params[:search]}%"
    ['name like ? or description like ?', search, search ]
  end

  def choose_layout
    if params[:action] == 'show'
      'dashboards'
    else
      'campaigns'
    end
  end
end
