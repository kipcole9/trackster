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
    preview = resource.relink_email_html(params)
    if preview.is_a?(Array)
      # Then we should really render a proper error page
      flash[:alert] = preview.join('<br>')
      redirect_back_or_default
    else
      render :text => preview
    end
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
