class CampaignsController < TracksterResources
  layout              :choose_layout
  respond_to          :html, :xml, :json
  has_scope           :search
  before_filter       :resource, :only => :preview

  def preview
    if !@campaign.preview_available? && !current_user.is_administrator?
      flash[:notice] = t('.no_preview_available')
    elsif @campaign.email_content.content.blank? 
      flash[:notice] = t('.no_email_html')
    elsif !(@campaign = @campaign.relink_email_html! {|redirect| redirector_url(redirect) })
      flash[:alert] = t('.translink_errors')
    end
    redirect_back_or_default unless flash.empty?
  end
  
  def destroy
    destroy! do |success, failure|
      success.js {render :delete}
    end
  end
  

private
  def begin_of_association_chain
    current_account
  end

  def collection
    @campaigns ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end
  
  def redirector_url(redirect)
    "#{Trackster::Config.tracker_url}/r/#{redirect}"
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
