# Reporting - html only (not data extract)
#
# Basic idea is that we're pivoting different metrics about different dimensions. 
# This means that the processing can be generalised and only a few methods need 
# to be defined where they deviate from the 'standard' metrics for reporting.
#
# Analytics::Model::Reports for the main methods used for information retrieval
# Analytics::Model::ColumnFormats define the output format for a table
# Analytics::Model::Metrics for the metrics that can be retrieved
# Analytics::Model::Dimensions for the dimenstions around which we can pivot
#
# Reports can be scoped by:
# => An Account
# => A Web Property
# => A Campaign
# => A Contact
#
class ReportsController < ApplicationController
  helper_method :resource
  before_filter :check_time_period
  after_filter  :store_location
    
  # Reports that have their own view template
  # Most reports are managed by method_missing below
  def new_v_returning;    end
  def video;              end
    
  def events
    @report = resource.events_summary(params)
    report :action => "events"
  end
  
  def entry_page
    @report = resource.entry_exit_summary(params)
    report :action => "entry_page"
  end
  
  def exit_page
    @report = resource.entry_exit_summary(params)
    report :action => "exit_page"
  end
  
  def stream
    @dont_export = [:id, :referrer, :user_agent, :account_id, :redirect_id, :campaign_id, 
      :count, :sequence, :property_id, :session_id, :created_at, :updated_at]
    @report = resource.event_stream(params)
  end

  # Here's where we implement most of the reporting.  Since reporting
  # is quite consistent but based upon different dimensions we can
  # generalise the solutions
  def method_missing(method, *args)
    
    # Platform/device metrics and main visitor metrics (country,language, new/returning)
    visit_summary if Track.session_dimensions.include?(params[:action])
      
    # Campaign Reporting  
    campaign_summary if Track.campaign_dimensions.include?(params[:action])
      
    # Loyalty Reporting such as length of visit, pages per visit
    loyalty_summary if Track.loyalty_dimensions.include?(params[:action])
      
    # Content info such as URL, page title, entry/exit/bounce pages        
    content_summary if Track.event_dimensions.include?(params[:action])

  end
  
private
  def visit_summary
    @report = resource.visits_summary(params)
    if params[:action] == 'locality'
      params[:action] = ['locality','region','country']
      params[:original_action] = 'locality'
    end
    report :action => 'visitor_summary'
  end

  def loyalty_summary
    @report = resource.visits_summary(params).sort {|a,b| a[params[:action]].to_i <=> b[params[:action]].to_i }
    report :action => 'visit_summary'
  end

  def campaign_summary
    @report = resource.campaign_summary(params)
    report 'campaigns/campaign_summary'
  end

  def content_summary
    @report = resource.content_summary(params)
    report :action => 'content_summary'
  end
  
  def report(*render_args)
    respond_to do |format|
      format.html     { render *render_args }
      format.xml      { render :xml => @report }
      format.json     { render :json => @report }
      format.xcelsius { render :action => 'report' }
    end
  end
  
  def resource
    @resource ||= if params[:property_id]
      current_account.properties.find(params[:property_id])
    elsif params[:campaign_id]
      current_account.campaigns.find(params[:campaign_id])
    elsif params[:contact_id]
      current_account.contacts.find(params[:contact_id])      
    else
      current_account
    end
  end
  
  def check_time_period
    params[:period] = :last_30_days unless params[:period] || (params[:from] && params[:to])
  end

end