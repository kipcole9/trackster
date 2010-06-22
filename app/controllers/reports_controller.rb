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
  def entry_page;         end
  def exit_page;          end
  def events;             end
  def video;              end

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
    # not 'numeric' enough for MySQL to sort properly
    elsif Track.loyalty_dimensions.include?(params[:action])
      @result = resource.visits_summary(params)
      @visits_summary = @result.sort {|a,b| a[params[:action]].to_i <=> b[params[:action]].to_i }
      render :action => 'visit_summary'
      
    # Content info such as URL, page title, entry/exit/bounce pages        
    elsif Track.event_dimensions.include?(params[:action])
      render :action => 'content_summary'
    else
      render :action => params[:action]
    end
  end
  
private
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