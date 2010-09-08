module Analytics
  class TrackEvent
    include Analytics::Params
    REDIRECT_URL = /\A\/r\//
    TRACKER_URL  = /\A\/_tks.gif\?/
    VALID_PARAMS = {
      # The tracking code, linked to an account
      # Needs to be on each tracking request or URL
      # If hand-crafting tracking URLs it needs to
      # be included on those urls
      :utac         =>  :account_code,
    
      # Managed by the system; should not be provided
      # in a url
      :utvis        =>  :visitor,
      :utses        =>  :session,
      :uttz         =>  :timezone,
      :utmdt        =>  :page_title,	
      :utmsr        =>  :screen_size, 
      :utmsc        =>  :color_depth, 
      :utmul        =>  :language, 
      :utmcs        =>  :charset, 
      :utmfl        =>  :flash_version, 
      :utmn         =>  :unique_request,
      :utmp         =>  :url,
      :utref        =>  :referrer,                
    
      # User defined (in a link)
      # Campaign data may or may not be included
      # (its a dimension of an event, not a requirement)
      :utm_campaign =>  :campaign_name, 
      :utm_source   =>  :campaign_source,
      :utm_medium   =>  :campaign_medium,
      :utm_content  =>  :campaign_content,
    
      # User defined, or application defined
      # All tracking requests, including pageviews
      # are considered events and must have at least
      # a category and an action.  Absence of category/action
      # results in the event being categorised as a
      # category=page; action=view
      :utcat        =>  :category,
      :utact        =>  :action,
      :utlab        =>  :label,
      :utval        =>  :value,
      
      # Sessions (NOT Events) can have tags that can
      # later be used to segment visits. Tags are
      # comma-separated lists or arbitrary text.
      :utags        => :tags,
    
      # An identifier of this user in a customer
      # cms system. Must be manually added through
      # tracker.setCid(id) or added to the tracking
      # url as &utid=contact_code_of_some_kind.
      :utid         =>  :contact_code
    }
    
    attr_accessor :log, :tracks, :logger, :_system, :_referrer, :_email_client, :_url, :_visitor, :_session, :_location

    def self.analyse(log_record, &block)
      if trackable?(log_record)
        tracker = new(log_record)
        yield(tracker) unless tracker.agent_banned? || tracker.crawler_agent?
      end
    end
    
    def self.trackable?(log_record)
      log_record && (log_record[:request_uri] =~ TRACKER_URL || log_record[:request_uri] =~ REDIRECT_URL)
    end
    
    def self.has_attribute?(attrib)
      instance_methods.include?(attrib.to_s) || VALID_PARAMS.has_value?(attrib.to_sym)
    end
    
    def initialize(log_record)
      @log          = log_record
      @logger       = Trackster::Logger
      @tracks       = tracker_url_parameters(@log[:request_uri])
      @tracks.merge!(redirect_parameters(@log[:request_uri])) if event_is_redirect?(@log[:request_uri])

      @_visitor      = Analytics::Visitor.new(@tracks[:visitor])
      @_session      = Analytics::Session.new(@tracks[:session])
      @_url          = Analytics::Url.new(@tracks[:url])
      @_referrer     = Analytics::Referrer.new(@tracks[:referrer])
      @_email_client = Analytics::EmailClient.new(@log[:user_agent], @_referrer)
      @_system       = Analytics::System.new(@log[:user_agent])
      @_location     = Analytics::Location.new(@log[:ip_address])
    end

    def visitor
      _visitor.visitor
    end
    
    def visit
      _visitor.visit
    end
    
    def previous_visit_at
      _visitor.previous_visit_at
    end
    
    def session
      _session.session
    end
    
    def view
      _session.view
    end
    
    def country
      _location.country || _referrer.country
    end
    alias :country_code :country
    
    def region
      _location.region
    end
    
    def locality
      _location.locality
    end
    
    def latitude
      _location.latitude
    end
    
    def longitude
      _location.longitude
    end
    
    def geocoded_at
      _location.geocoded_at
    end

    def category
      tracks[:category] || Event::PAGE_CATEGORY
    end
    
    def action
      tracks[:action] || Event::VIEW_ACTION
    end

    def timezone
      tracks[:timezone].try(:to_i)
    end
    
    def dialect
      tracks[:language] ? tracks[:language].sub('_','-') : nil
    end
    
    def language
      self.dialect ? self.dialect.split('-').first : nil
    end
 
    def host
      _url.host
    end
    
    def path
      _url.path
    end
      
    def tracked_at
      log[:datetime]
    end
 
    def email_client
      _email_client.name
    end
    
    def traffic_source
      email? ? Event::EMAIL_CATEGORY : self.traffic_source
    end
    
    def device
      _system.device
    end
    
    def device_vendor
      _system.device_vendor
    end
    
    def os_name
      _system.os_name
    end
    
    def os_version
      _system.os_version
    end
    
    def mobile_device
      _system.mobile_device?
    end
    
    def browser
      _system.browser
    end
    
    def browser_version
      _system.browser_version
    end
    
    def user_agent
      log[:user_agent]
    end
    
    def traffic_source
      _referrer.traffic_source
    end
    
    def search_terms
      _referrer.search_terms
    end
    
    def forwarded_for
      log[:forwarded_for]
    end
    
    def referrer_category
      email? ? Event::EMAIL_CATEGORY : _referrer.category
    end
    
    def referrer_host
      _referrer.host
    end
    
    def timezone
      tracks[:timezone] || _location.try(:timezone)
    end
    
    def lon_local_time
      return false if tracks[:timezone]
      return true if _location.timezone
      nil
    end
    
    def ip_address
      log[:ip_address]
    end
    
    def redirect?
      tracks[:redirect]
    end
    
    def redirect_code
      tracks[:redirect_code]
    end
    
    def agent_banned?
      _system.banned?
    end
    
    def crawler_agent?
      _system.crawler?
    end

    def method_missing(method, *args)
      if VALID_PARAMS.has_value?(method)
        tracks[method]
      elsif method == :[] && args.last
        send args.last
      else
        super
      end
    end

  private
  
    def email?
      campaign_open? ? email_client : nil
    end
    
    def campaign_open?
      tracks[:category] == Event::EMAIL_CATEGORY && tracks[:action] == Event::OPEN_ACTION
    end
    
    # Parse the analytics url.  We recognise that the 
    # referring URL parameter (utmr) might itself have 
    # parameters.  We assume that there is not overlap
    # between the referer parameters and the GA
    # parameters.  That might need to change.
    def tracker_url_parameters(url)
      uri = URI.parse(url)
      tracker_params_to_hash(uri.query)
    rescue URI::InvalidURIError
      logger.error "[Track Event] Invalid tracker URI detected: '#{url}'"
      {}
    end
    
    def tracker_params_to_hash(params)
      result = {}
      split_into_parameters(params).delete_if do |p|
        var, value = p.split('=')
        if value
          VALID_PARAMS[var.to_sym] ? result[VALID_PARAMS[var.to_sym]] = URI.decode(value) : false
        end
      end if params
      result
    end

    def event_is_redirect?(url)
      url =~ REDIRECT_URL
    end
    
    def redirect_parameters(url)
      begin
        redirect_code = redirect_code_from(url)
        params = {}
        if redirect = Redirect.find_by_redirect_url(redirect_code)
          [:category, :action, :label, :value, :url].each do |attrib|
            params[attrib] = redirect.send(attrib) unless tracks[attrib]
          end
          params[:account_code] = redirect.account.tracker
          params[:redirect_id]  = redirect['id']
          params[:redirect_code] = redirect_code
          params[:page_title]   = redirect.name
          params[:redirect]     = true
        else
          logger.error "[Track Event] Redirect not found: '#{redirect_code}'"
        end  
      rescue NoMethodError => e
        logger.error "[Track Event] Redirect error detected: #{e.message}"   
        logger.error "[Track Event] #{redirect.inspect}" 
      end  
      params
    end
    
    # Extract the redirect code from the source URL
    def redirect_code_from(url)
      uri = URI.parse(url)
      code = uri.path.split('/').last
      # logger.info "[Track Event] Parsed redirect url '#{url}' and got code '#{code}'"
      code
    rescue URI::InvalidURIError
      logger.error "[Track Event] Invalid redirect detected extracting redirect code: '#{url}'"
      nil     
    end
  end
end