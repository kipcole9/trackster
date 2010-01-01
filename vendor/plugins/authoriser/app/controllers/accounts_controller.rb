class AccountsController < ApplicationController
  before_filter       :retrieve_account, :only => [:edit, :update, :destroy, :show]
  before_filter       :retrieve_accounts, :only => :index
  layout              :select_layout
    
  def new
    render :action => 'edit'
  end
  
  def edit
    respond_to do |format|
      format.html { }
      format.js   { render :partial => 'account_form', :locals => {:account => @account} }      
    end
  end

  def index
    respond_to do |format|
      format.html {  }
      format.js   { render :partial => 'index', :layout => false }      
    end
  end

  def show
    @page_subject = @account.name
    respond_to do |format|
      format.html {
        @campaign_summary = @account.campaign_summary(params).all
        render 'campaigns/campaign_summary' 
      }
      format.js   { render_list_item @account, 'account_summary' }        
    end
  end

  def create
    @account = Account.create(params[:account])
    if @account.valid?
      flash[:notice] = t('.account_created', :name => @account.name)
      redirect_back_or_default('/')
    else
      flash[:error] = t('.account_not_created', :name => @account.name)
      render :action => 'edit'
    end
  end

  def update
    if @account.update_attributes(params[:account])
      flash[:notice] = t('.account_updated', :name => @account.name)
      redirect_back_or_default('/')
    else
      flash[:error] = t('.account_not_updated', :name => @account.name)
      render :action => 'edit'
    end
  end

  def destroy
    if @account.destroy
      flash[:notice] = t('.account_deleted', :name => @account.name)
    else
      flash[:error] = t('.account_not_deleted', :name => @account.name)
    end
    redirect_back_or_default('/')    
  end

  def _page_title
    @account ? @account.name : super
  end

private
  def retrieve_account
    @account = current_scope(:accounts).find(params[:id])
  end

  def retrieve_accounts
    @accounts = current_scope(:accounts).paginate(:page => params[:page], :conditions => conditions_from_params)
  end

  def conditions_from_params
    return {} if params[:search].blank?
    search = "%#{params[:search]}%"
    ['name like ? or description like ?', search, search ]
  end
  
  def select_layout
    if ['index','create','edit','destroy','update','new'].include?(params[:action])
      'accounts'
    else
      'dashboards'
    end
  end
  

end
