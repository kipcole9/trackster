class WebAnalytics
  REDIRECT_URL = /\A\/r\//
  TRACKER_URL  = /\A\/_tks.gif\?/
  VALID_PARAMS = {
                  # The tracking code, linked to an account
                  # Needs to be on each tracking request or URL
                  # If hand-crafting tracking URLs it needs to
                  # be included on those urls
                  :utac         =>  :property_code,
                  
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
                  
                  # An identifier of this user in a customer
                  # cms system. Must be manually added through
                  # tracker.trackContact() or added to the tracking
                  # url as &cms=contact_code_of_some_kind.  The system
                  # only stores this info, it cannot interpret it.
                  :ucms         =>  :crm_contact
                }
                  
  attr_accessor :params, :browscap, :device
  
  class MobileDevice
    def initialize
      @device_atlas = DeviceAtlas.new
      @tree = @device_atlas.getTreeFromFile("#{Rails.root}/lib/analytics/device_atlas.json")
      @cached_entries = {}
    end
    
    def get_device_from_user_agent(user_agent)
      device = {}
      return device if device = @cached_entries[user_agent]
      device = @device_atlas.getProperties(@tree, user_agent)
      if device['model']
        @cached_entries[user_agent] = device
      end
      device
    end
  end
    

  def initialize
    @browscap = Browscap.new
    @device = MobileDevice.new
  end
  
  # Parse the analytics url.  We recognise that the 
  # referring URL parameter (utmr) might itself have 
  # parameters.  We assume that there is not overlap
  # between the referer parameters and the GA
  # parameters.  That might need to change.
  def parse_tracker_url_parameters(url)
    uri = URI.parse(url)
    row = tracker_params_to_hash(uri.query)
    row[:path] = uri.path
    row
  rescue URI::InvalidURIError
    Rails.logger.error "[Web Analytics] Invalid tracker URI detected: #{url}"
    {}
  end
  
  # Parse any url parameters (no tracker specific)
  def parse_url_parameters(url)
    uri = URI.parse(url)
    params_to_hash(uri.query)
  rescue URI::InvalidURIError
    Rails.logger.error "[Web Analytics] Invalid URI detected: #{url}"
    {}
  end
  
  # A redirect URL. Parameters are kept in the 
  # Redirects table
  def parse_redirect_parameters(url)
    return nil unless row = parse_tracker_url_parameters(url)
    return nil unless redirect = Redirect.find_by_redirect_url(row[:path].sub(REDIRECT_URL, ''))
    [:category, :action, :label, :value, :url].each do |attrib|
      row[attrib] = redirect.send(attrib) unless row[attrib]
    end
    row[:property_code] = redirect.property.tracker unless !redirect.property || row[:property_code]
    row[:redirect_id] = redirect['id']
    row[:page_title] = redirect.name
    row[:redirect] = true
    row
  end
  
  # From a parsed log entry create the source of data for
  # Session and Event entries.
  def create(entry)
    if entry[:url] =~ REDIRECT_URL
      row = parse_redirect_parameters(entry[:url])
    else
      row = parse_tracker_url_parameters(entry[:url])
    end
    if row
      get_log_data!(row, entry)
      get_traffic_source!(row)
      get_platform_info!(row)
      get_mobile_device_info!(row)
      get_visitor!(row)
      get_session!(row)
      geocode!(row)
      time_zone_from_longitude!(row) if row[:longitude] && !row[:timezone]
    end
    row
  end
  
  def get_platform_info!(row)
    if agent = browscap.query(row[:user_agent])
      row[:browser] = agent.browser
      row[:browser_version] = agent.version
      row[:os_name] = agent.platform
      row[:mobile_device] = agent.is_mobile_device    
    end
  end
  
  def get_mobile_device_info!(row)
    mobile_device = device.get_device_from_user_agent(row[:user_agent])
    if mobile_device['model']
      row[:device] = mobile_device['model']
      row[:device_vendor] = mobile_device['vendor']
    end
  end  
  
  # Based upon the referrer decide is the traffic source is
  # search, direct or referred
  def get_traffic_source!(row)
    referrer = row[:referrer]
    if referrer.blank? || referrer == "-" || referrer == 'mhtmlmain:'
      row[:traffic_source] = 'direct'
      return
    end
    
    uri = URI.parse(referrer)
    row[:referrer_host] = uri.host
    if search_engine = SearchEngine.find_by_host(uri.host.sub(/\Awww\./,''))
      params = params_to_hash(uri.query)
      row[:search_terms] = params[search_engine.query_param]
      row[:traffic_source] = 'search'
    else
      row[:traffic_source] = 'referral'      
    end
  rescue
    Rails.logger.error "[Web Analytics] Invalid URI Referrer detected: #{referrer}"
    row[:traffic_source] = 'referral'
  end

  def is_crawler?(user_agent)
    if browser = browscap.query(user_agent)
      browser.crawler
    else
      nil
    end
  end
  
  def is_tracker?(url)
    url && (url =~ REDIRECT_URL || url =~ TRACKER_URL)
  end
  
private
  def geocode!(row)
    IpAddress.reverse_geocode(row[:ip_address], row)
  end
  
  # 15 degrees is one hour of time difference
  # Rounded to nearest hour.  Which is not strictly accurate
  # especially for some places (India, Adelaide, ...) that 
  # actually have 30 minute TZ variances
  # We store timezone in minutes
  def time_zone_from_longitude!(row)
    row[:timezone] = (row[:longitude] / 15).round * 60
    row[:lon_local_time] = true
  end
  
  def get_log_data!(row, entry)
    row[:ip_address]  = entry[:ip_address]
    row[:tracked_at]  = entry[:datetime]
    row[:user_agent]  = entry[:user_agent]
  end    
  
  # Visitor may have several parts when imported from the tracking system
  # => 0: Visitor id
  # => 1: Number of visits
  # => 2: Current session timestamp
  # => 3: Previous session timestamp
  def get_visitor!(row)
    return if row[:visitor].blank?
    parts = row[:visitor].split('.')
    raise "[Web Analytics] Badly formed visitor variable: '#{v}" if parts.size > 4
    row[:visitor]           = parts[0]
    row[:visit]             = parts[1] if parts[1]
    row[:previous_visit_at] = to_time(parts[3]) unless parts[3].blank?
  end

  # Session has two possible parts
  # => Session id (a timestamp)
  # => A pageview count incremented on each pageview for this session
  def get_session!(row)
    return if row[:session].blank?
    parts = row[:session].split('.')
    row[:session] = parts[0]
    row[:view] = parts[1] if parts[1]    
  end

  def to_time(timestamp)
    return nil unless timestamp
    the_time = timestamp.size > 10 ? (timestamp.to_i / 1000) : timestamp.to_i
    Time.at(the_time) if the_time
  end

  def split_into_parameters(query_string)
    return {} if query_string.blank?
    query_string.split('&')
  end
  
  def tracker_params_to_hash(params)
    result = {}
    split_into_parameters(params).delete_if do |p|
      var, value = p.split('=')
      if value
        VALID_PARAMS[var.to_sym] ? result[VALID_PARAMS[var.to_sym]] = URI.unescape(value) : false
      end
    end if params
    result[:timezone] = result[:timezone].to_i if result[:timezone]
    result
  end
  
  def params_to_hash(params)
    result = {}
    split_into_parameters(params).each do |p|
      var, value = p.split('=')
      result[var] = CGI.unescape(value)
    end if params
    result
  end
end
