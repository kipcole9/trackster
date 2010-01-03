class CampaignsController < TracksterResources
  layout              :choose_layout
  respond_to          :html, :xml, :json
  has_scope           :search
  
  def preview
    if !@campaign.preview_available? && !current_user.is_administrator?
      flash[:notice] = t('.no_preview_available')
    elsif @campaign.email_html.blank? 
      flash[:notice] = t('.no_email_html')
    elsif !(@campaign = @campaign.relink_email_html! {|redirect| redirector_url(redirect) })
      flash[:alert] = t('.translink_errors')
    end
    redirect_back_or_default('/') unless flash.empty?
  end

private
  def begin_of_association_chain
    current_account
  end

  def collection
    @campaigns ||= end_of_association_chain.paginate(:page => params[:page])
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
