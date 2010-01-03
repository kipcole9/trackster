class PropertiesController < TracksterResources
  layout              :select_layout
  respond_to          :html, :xml, :json
  has_scope           :search
  before_filter       :resource, :except => [:index]
  
  def overview
    # default render
  end

  def events
    @events_summary = @property.events_summary(params).all
  end
  
  def video
    @videos = @property.video_labels(params)
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
      @site_summary = @property.site_summary(params).all
      render :action => 'site_summary'
    elsif Track.campaign_dimensions.include?(params[:action])
      @campaign_summary = @property.campaign_summary(params).all
      render 'campaigns/campaign_summary'      
    elsif Track.loyalty_dimensions.include?(params[:action])
      @visit_summary = @property.visit_summary(params).all\
        .sort{|a,b| a[params[:action]].to_i <=> b[params[:action]].to_i }
      render :action => 'visit_summary'      
    elsif Track.event_dimensions.include?(params[:action])
      @site_summary = @property.content_summary(params).all
      render :action => 'content_summary'
    else
      raise ActiveRecord::RecordNotFound
    end
  end

private
  def begin_of_association_chain
    current_account
  end

  def collection
    @properties ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end
  
  def select_layout
    if ['index','create','edit','destroy','update','new','show'].include?(params[:action])
      'properties'
    else
      'dashboards'
    end
  end

end
