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
  layout        :select_layout
    
  # Reports that have their own view template
  # Most reports are managed by method_missing below
  def new_v_returning;    end
  def visit_overview;     end
  def device_overview;    end
    
  def events
    @report = resource.events_summary(params)
    report :action => "events"
  end
  
  def entry_page
    @report = resource.entry_exit_summary(params)
    report :action => "entry_page"
  end
  
  def exit_page
    @report = resource.entry_exit_summary(params).each do |r|
      r['campaign_name'] = r.campaign.name if r.campaign
    end
    report :action => "exit_page"
  end
  
  def stream
    @report = resource.event_stream(params)
    report :action => 'stream'
  end
  
  def video
    @report = resource.video_summary(params)
    report :action => 'video'
  end

  def campaign_click_map
    if map = resource.click_map(params)
      render :text => map
    else
      flash[:alert] = I18n.t('campaigns.has_no_content')
      redirect_back_or_default
    end
  end


  # Here's where we implement most of the reporting.  Since reporting
  # is quite consistent but based upon different dimensions we can
  # generalise the solutions
  def method_missing(method, *args)
    
    if Track.session_dimensions.include?(params[:action])
      # Platform/device metrics and main visitor metrics (country,language, new/returning)
      visit_summary 
    elsif Track.campaign_dimensions.include?(params[:action])
      # Campaign Reporting  
      campaign_summary 
    elsif Track.loyalty_dimensions.include?(params[:action])
      # Loyalty Reporting such as length of visit, pages per visit
      loyalty_summary 
    elsif Track.event_dimensions.include?(params[:action])
      # Content info such as URL, page title, entry/exit/bounce pages        
      content_summary
    else
      super(method, *args)
    end
    
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
    @report = resource.send(params[:action], params)
    report "campaigns/reports/#{params[:action]}"
  end

  def content_summary
    @report = resource.content_summary(params)
    report :action => 'content_summary'
  end
  
  def report(*render_args)
    set_disposition_header
    respond_to do |format|
      format.html     { render *render_args }
      format.all      { format_not_found }
      if template_exists?(*render_args)
        format.xml      { render *render_args }
        format.json     { render *render_args }
        format.csv      { render *render_args}
        format.xcelsius { render *render_args }
      else
        format.xml      { render :xml =>  @report }
        format.json     { render :json => @report }
        format.csv      { render :text => @report.to_csv}
        format.xcelsius { render :action => 'report' }
      end
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
  
  def set_disposition_header
    filename = case params['format']
      when 'xml'
        "#{download_filename}.xml"
      when 'csv'
        "#{download_filename}.csv"
      when 'xcelsius'
        "#{download_filename}.xcelcius.xml"
      end
    headers['Content-disposition'] = "attachment; filename=#{filename}" unless filename.blank?
  end
  
  def download_filename
    @download_name = "#{Account.current_account.name}_#{params[:action]}_#{period}"
  end
  
  def period
    params[:period] || "#{params[:from]}_#{params[:to]}"
  end
  
  def select_layout
    if params[:campaign_id]
      'campaign_reports'
    #elsif params[:property_id]
    #  'property_reports'
    else
      'reports'
    end
  end

end