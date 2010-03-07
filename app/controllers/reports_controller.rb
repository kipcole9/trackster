class ReportsController < ApplicationController
  helper_method :resource
  
  def events
    # @events_summary = resource.events_summary(params).all
  end

  def video
    # @videos = resource.video_labels(params)
  end

  # Here's where we implement most of the reporting.  Since reporting
  # is quite consistent but based upon different dimensions we can
  # generalise the solutions
  def method_missing(method, *args)
    
    # Platform/device metrics and main visitor metrics (country,language, new/returning)
    if Track.session_dimensions.include?(params[:action])
      if params[:action] == 'locality'
        params[:action] = ['locality','region','country']
        params[:original_action] = 'locality'
      end
      render :action => 'visitor_summary'
      
    # Campaign Reporting  
    elsif Track.campaign_dimensions.include?(params[:action])
      @campaign_summary = resource.campaign_summary(params).all
      render 'campaigns/campaign_summary'
      
    # Loyalty Reporting such as length of visit, pages per visit
    # We sort these in place since the column data is derived and
    # no 'numeric' enough for MySQL to sort   
    elsif Track.loyalty_dimensions.include?(params[:action])
      @visits_summary = resource.visits_summary(params).all\
        .sort{|a,b| a[params[:action]].to_i <=> b[params[:action]].to_i }
      render :action => 'visit_summary'
      
    # Content info such as URL, page title, entry/exit/bounce pages        
    elsif Track.event_dimensions.include?(params[:action])
      render :action => 'content_summary'
    else
      super
    end
  end
  
private
  def resource
    @resource ||= if params[:property_id]
      current_account.properties.find(params[:property_id])
    elsif params[:campaign_id]
      current_account.campaigns.find(params[:campaign_id])
    else
      current_account
    end
  end

end