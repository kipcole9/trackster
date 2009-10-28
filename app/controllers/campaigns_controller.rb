class CampaignsController < ApplicationController
  require_role  [Role::ADMIN_ROLE, Role::ACCOUNT_ROLE], :except => [:show, :index]
  before_filter       :retrieve_campaign, :except => [:index, :new, :create]
  before_filter       :retrieve_property
  before_filter       :retrieve_campaigns, :only => :index
  layout              :choose_layout

  def new
    @campaign = user_create_scope.new
    @campaign.property = @property
    @campaign.account = current_account
    render :action => 'edit'
  end

  def edit
    respond_to do |format|
      format.html { }      
      format.js   { render :partial => 'campaign_form', :locals => {:campaign => @campaign} }
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
        @campaign_summary = @campaign.campaign_summary(params).all
        render 'campaign_summary' 
      }
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
  
  def preview
    if !@campaign.preview_available? && !current_user.is_administrator?
      flash[:notice] = t('.no_preview_available')
    elsif @campaign.email_html.blank? 
      flash[:notice] = t('.no_email_html')
    elsif !(@campaign = @campaign.relink_email_html! {|redirect| redirector_url(redirect) })
      flash[:error] = t('.translink_errors')
    end
    redirect_back_or_default('/') if flash[:notice] || flash[:error]
  end
    
  def _page_title
    if @campaign && @property
      I18n.t('campaigns.campaign_for_property', :campaign => @campaign.name, :property => @property.name)
    else
      super
    end
  end

private
  def retrieve_campaign
    @campaign = user_scope(:campaign, current_user).find(params[:id])
  end
  
  def retrieve_property
    @property = user_scope(:property, current_user).find(params[:property_id]) if params[:property_id]
    @property ||= @campaign.property if @campaign
  end

  def retrieve_campaigns
    @campaigns = campaigns_scope.paginate(:page => params[:page], :conditions => conditions_from_params)
  end
  
  def campaigns_scope
    @property ? @campaigns = @property.campaigns : @campaigns = user_scope(:campaign, current_user)
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
    case params[:action]
    when 'show'
      'dashboards'
    when 'preview'
      nil
    else
      'campaigns'
    end
  end
end
