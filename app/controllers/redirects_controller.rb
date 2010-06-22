class RedirectsController < TracksterResources

private
  def collection
    @redirects ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end

end
