class ContentsController < TracksterResources
  respond_to      :html, :xml, :json
  has_scope       :search
  
private
  def begin_of_association_chain
    current_account
  end

  def collection
    @contents ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end

end
