class WebAnalytics
  require 'uri'
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
                  :utmdt        =>  :page_title,	
                  :utmsr        =>  :screen_size, 
                  :utmsc        =>  :color_depth, 
                  :utmul        =>  :language, 
                  :utmcs        =>  :charset, 
                  :utmfl        =>  :flash_version, 
                  :utmn         =>  :unique_request,
                  :utmp         =>  :url,                  
                  
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
                  
  attr_accessor :params, :browscap
  
  # Wrapper class to store resolved browser capabilities
  # Currently "umlimited" caching - probably needs refinement.
  class CacheBrowscap
    def initialize
      @browscap = Browscap.new
      @cache = {}
    end
    
    def query(agent)
      @cache[agent] || @cache[agent] = @browscap.query(agent)
    end
  end

  def initialize
    @browscap = CacheBrowscap.new
  end
  
  # Parse the analytics url.  We recognise that the 
  # referring URL parameter (utmr) might itself have 
  # parameters.  We assume that there is not overlap
  # between the referer parameters and the GA
  # parameters.  That might need to change.
  def parse_url_parameters(url)
    uri = URI.parse(url)
    params_to_hash(split_into_parameters(uri.query))
  end
  
  # From a parsed log entry, create the Track row
  # which we keep around for a while in case we need to reprocess
  # log data.  It's also used as the source of data for
  # Session and Event entries.
  def create(entry, model = Track)
    row = model.new
    row.referrer    = entry[:referer]
    row.ip_address  = entry[:ip_address]
    row.tracked_at  = entry[:datetime]
    row.user_agent  = entry[:user_agent]
    parse_url_parameters(entry[:url]).each do |k, v|
      row.send "#{VALID_PARAMS[k].to_s}=", v
    end
    get_traffic_source!(row)
    get_platform_info!(row)    
    row
  end
  
  def save(url, model = Track)
    row = create(url, model)
    row.save!
  end
  
  def is_crawler?(user_agent)
    if browser = browscap.query(user_agent)
      browser.crawler
    else
      nil
    end
  end
  
  def get_platform_info!(row)
    if agent = browscap.query(row.user_agent)
      row.browser = agent.browser
      row.browser_version = agent.version
      row.os_name = agent.platform
    end
  end    
  
  # Based upon the referrer decide is the traffic source is
  # search, direct or referred
  def get_traffic_source!(row)
    referrer = row.referrer
    if referrer.blank? || referrer == "-" || referrer == 'mhtmlmain:'
      row.traffic_source = 'direct'
      return
    end
    
    begin
      uri = URI.parse(referrer)
      if search_engine = SearchEngine.find_by_host(uri.host)
        params = parse_url_parameters(uri.query)
        row.referrer_host = uri.host
        row.search_terms = params[search_engine.query_param]
        row.traffic_source = 'search'
      else
        row.referrer_host = uri.host
        row.traffic_source = 'referral'      
      end
    rescue URI::InvalidURIError => e
      Rails.logger.error "Invalid URI detected: #{e.message}: #{referrer}"
      row.traffic_source = 'referral'
    end
  end
  
private

  def split_into_parameters(query_string)
    return {} if query_string.blank?
    query_string.split('&')
  end
  
  def params_to_hash(params)
    result = {}
    params.delete_if do |p|
      var, value = p.split('=')
      if value
        VALID_PARAMS[var.to_sym] ? result[var.to_sym] = URI.unescape(value) : false
      end
    end if params
    result
  end
end
