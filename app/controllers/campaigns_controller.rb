class CampaignsController < TracksterResources
  layout              :choose_layout
  respond_to          :html, :xml, :json
  has_scope           :search
  before_filter       :resource, :only => :preview

  def destroy
    destroy! do |success, failure|
      success.js {render :delete}
    end
  end
  
  def preview
    render :text => resource.relink_email_html
  end
  
private
  def begin_of_association_chain
    current_account
  end

  def collection
    @campaigns ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
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
