class RedirectsController < TracksterResources
  respond_to          :html, :xml, :json
  
  def create
    create! do |success, failure|
      success.html {redirect_back_or_default}
    end
  end
  
  def update
    update! do |success, failure|
      success.html {redirect_back_or_default}
    end
  end

private
  def collection
    @redirects ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end

end
