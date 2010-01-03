class ReportsController < ApplicationController
  helper_method     :resource
  before_filter     :identify_resource

  def overview
    resource
  end

  def events
    @events_summary = resource.events_summary(params).all
  end

  def video
    @videos = resource.video_labels(params)
  end

  # Here's where we implement most of the reporting.  Since reporting
  # is quite consistent but based upon different dimensions we can
  # generalise the solutions
  def method_missing(method, *args)
    if Track.session_dimensions.include?(params[:action])
      if params[:action] == 'locality'
        params[:action] = ['locality','region','country']
        params[:original_action] = 'locality'
      end
      @site_summary = resource.site_summary(params).all
      render :action => 'site_summary'
    elsif Track.campaign_dimensions.include?(params[:action])
      @campaign_summary = resource.campaign_summary(params).all
      render 'campaigns/campaign_summary'      
    elsif Track.loyalty_dimensions.include?(params[:action])
      @visit_summary = resource.visit_summary(params).all\
        .sort{|a,b| a[params[:action]].to_i <=> b[params[:action]].to_i }
      render :action => 'visit_summary'      
    elsif Track.event_dimensions.include?(params[:action])
      @site_summary = resource.content_summary(params).all
      render :action => 'content_summary'
    else
      raise ActiveRecord::RecordNotFound, "Couldn't find #{method}"
    end
  end
  
private
  def resource
    @resource ||= current_account.send(@parent).send(:find, @parent_id)
  end
  
  def identify_resource
    if params[:property_id]
      @parent     = :properties
      @parent_id  = params[:property_id]
    elsif params[:account_id]
      @parent     = :accounts
      @parent_id  = params[:account_id]
    else
      @parent     = :campaigns
      @parent_id  = params[:campaign_id]
    end
  end
end