class AccountsController < TracksterResources
  unloadable
  respond_to          :html, :xml, :json
  layout              'accounts'
  defaults            :collection_name => 'clients'
  has_scope           :search

protected
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
    @accounts ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def get_my_account?
    current_account.id == params[:id].to_i
  end
  
  def get_my_account
    @account = current_account.reload
  end

end
