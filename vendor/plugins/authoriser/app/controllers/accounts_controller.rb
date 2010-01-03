class AccountsController < TracksterResources
  respond_to          :html, :xml, :json
  layout              'accounts'
  defaults            :collection_name => 'clients'
  has_scope           :search

  def update
    update! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end
  
  def create
    create! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end

  def _page_title
    @account ? @account.name : super
  end

private
  def begin_of_association_chain
    current_account
  end
  
  def resource
    @account ||= get_my_account? ? get_my_account : super    
  end

  def collection
    @accounts ||= end_of_association_chain.paginate(:page => params[:page])
  end

  def get_my_account?
    current_account.id == params[:id].to_i
  end
  
  def get_my_account
    @account = current_account.reload
  end

end
