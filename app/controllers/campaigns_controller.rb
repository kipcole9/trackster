class CampaignsController < ApplicationController
  require_role  [Role::ADMIN_ROLE, Role::ACCOUNT_ROLE], :except => [:show, :index]
  before_filter       :retrieve_campaign, :only => [:edit, :update, :destroy, :show]
  before_filter       :retrieve_property
  before_filter       :retrieve_campaigns, :only => :index

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
      format.js   { render_list_item @campaign, 'campaign_summary' }
      format.html { }
    end
  end

  def create
    @campaign = user_create_scope.create(params[:campaign])
    Rails.logger.info @campaign.inspect
    Rails.logger.info @campaign.property.inspect
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

  
end
