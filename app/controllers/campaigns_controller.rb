class CampaignsController < ApplicationController
  require_role  [Role::ADMIN_ROLE, Role::ACCOUNT_ROLE], :except => [:show, :index]
  before_filter       :retrieve_campaign, :only => [:edit, :update, :destroy, :show]
  before_filter       :retrieve_campaigns, :only => :index

  def new
    render :action => 'edit'
  end

  def edit
    respond_to do |format|
      format.js   { render :partial => 'campaign_form', :locals => {:campaign => @campaign} }
      format.html { }
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
    if @campaign.valid?
      flash[:notice] = t('.campaign_created')
      campaign_back_or_default('/')
    else
      flash[:error] = t('.campaign_not_created')
      render :action => 'edit'
    end
  end

  def update
    if @campaign.update_attributes(params[:campaign])
      flash[:notice] = t('.campaign_updated')
      campaign_back_or_default('/')
    else
      flash[:error] = t('.campaign_not_updated')
      render :action => 'edit'
    end
  end

private
  def retrieve_campaign
    @campaign = user_scope(:campaign, current_user).find(params[:id])
  end

  def retrieve_campaigns
    @campaigns = user_scope(:campaign, current_user).paginate(:page => params[:page])
  end

  def user_create_scope
    current_user.account.campaigns
  end

  
end
