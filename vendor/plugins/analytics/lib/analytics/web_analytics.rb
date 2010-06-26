module Analytics
  class WebAnalytics
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
                  
    attr_accessor :params, :platform, :browscap, :logger
  
    def initialize(options = {})
      @logger = options[:logger] || Rails.logger
      @platform = SystemInfo.new
    end
  
    # From a parsed log entry create the source of data for
    # Session and Event entries.
    def create(entry)
      if row = parse_tracker_url_parameters(entry[:url])
        row[:logger] = logger
        log_data!(row, entry)
        host_data!(row)
        parse_redirect_parameters(entry[:url], row) if entry[:url] =~ REDIRECT_URL
        traffic_source!(row)
        platform.info!(row)
        email_client!(row) if Event.email_opening?(row)
        visitor!(row)
        session!(row)
        geocode!(row)
        time_zone_from_longitude!(row) if row[:longitude] && !row[:timezone]
        adjust_time_to_client_zone!(row)
      end
      row
    end
  
    # Parse the analytics url.  We recognise that the 
    # referring URL parameter (utmr) might itself have 
    # parameters.  We assume that there is not overlap
    # between the referer parameters and the GA
    # parameters.  That might need to change.
    def parse_tracker_url_parameters(url)
      uri = URI.parse(url)
      row = tracker_params_to_hash(uri.query)
      row
    rescue URI::InvalidURIError
      logger.error "[Web Analytics] Invalid tracker URI detected: '#{url}'"
      nil
    end
  
    # Parse any url parameters (not tracker specific)
    def parse_url_parameters(url)
      uri = URI.parse(url)
      params_to_hash(uri.query)
    rescue URI::InvalidURIError
      logger.error "[Web Analytics] Invalid URI detected: '#{url}'"
      {}
    end
  
    # A redirect URL. Parameters are kept in the 
    # Redirects table.
    def parse_redirect_parameters(url, row)
      begin
        redirect_code = redirect_code_from(url)
        if redirect = Redirect.find_by_redirect_url(redirect_code)
          [:category, :action, :label, :value, :url].each do |attrib|
            row[attrib] = redirect.send(attrib) unless row[attrib]
          end
          row[:account_code] = redirect.account.tracker
          row[:redirect_id] = redirect['id']
          row[:page_title] = redirect.name
          row[:redirect] = true
        else
          logger.error "[Web Analytics] Redirect not found: '#{redirect_code}'"
          return nil
        end  
      rescue NoMethodError => e
        logger.error "[Web Analytics] Redirect error detected: #{e.message}"   
        logger.error "[Web Analytics] #{row.inspect}" 
        logger.error "[Web Analytics] #{redirect.inspect}" 
      end  
      row
    end
  
    def host_data!(row)
      return nil if row[:url].blank?  # as it will be for redirects
      uri = URI.parse(row[:url])
      row[:host] = uri.host
      row[:path] = uri.path
    rescue
      logger.error "[Web Analytics] Invalid URI detected when extracting host data: '#{row[:url]}'"
    end
  
    # Based upon the referrer decide is the traffic source is
    # search, direct or referred
    def traffic_source!(row)
      referrer = row[:referrer]
      if referrer.blank? || referrer == "-" || referrer == 'mhtmlmain:'
        row[:traffic_source] = 'direct'
        return
      end
    
      uri = URI.parse(referrer)
      row[:referrer_host] = uri.host
      if search_engine = SearchEngine.find_from_host(uri.host)
        params = params_to_hash(uri.query)
        row[:country_code] = search_engine.country
        row[:search_terms] = params[search_engine.query_param]
        if search_engine.query_param == 'prev'
          # Hack for google images.  Search terms are the q param within the prev param.
          revised_terms = params_to_hash(row[:search_terms].sub(/\A.*\?/,''))
          row[:search_terms] = revised_terms['q']
        end
        row[:traffic_source] = 'search'
      else
        row[:traffic_source] = 'referral'      
      end
    rescue
      logger.error "[Web Analytics] Invalid URI Referrer detected: '#{referrer}'"
      row[:traffic_source] = 'referral'
    end

    def is_crawler?(user_agent)
      (browser = browscap.query(user_agent)) ? browser.crawler : nil
    end
  
    def is_tracker?(url)
      url && (url =~ REDIRECT_URL || url =~ TRACKER_URL)
    end
  
    def browscap
      platform.browscap
    end
  
  private
    # Extract the redirect code from the source URL
    def redirect_code_from(url)
      uri = URI.parse(url)
      code = uri.path.split('/').last
      # logger.info "[Web Analytics] Parsed redirect url '#{url}' and got code '#{code}'"
      code
    rescue URI::InvalidURIError
      logger.error "[Web Analytics] Invalid redirect detected extracting redirect code: '#{url}'"
      nil     
    end
    
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
    
    # All times should be in the clients timezone where possible
    def adjust_time_to_client_zone!(row)
      if row[:timezone]
        tz_adjustment = row[:timezone].minutes
        row[:tracked_at] = row[:tracked_at] + tz_adjustment
        row[:previous_visit_at] = row[:previous_visit_at] + tz_adjustment if row[:previous_visit_at]
      end
    end
  
    def log_data!(row, entry)
      row[:ip_address]  = entry[:ip_address]
      row[:tracked_at]  = entry[:datetime]
      row[:user_agent]  = entry[:user_agent]
    end    
  
    # Visitor may have several parts when imported from the tracking system
    # => 0: Visitor id
    # => 1: Number of visits
    # => 2: Current session timestamp
    # => 3: Previous session timestamp
    def visitor!(row)
      return if row[:visitor].blank?
      parts = row[:visitor].split('.')
      raise "[Web Analytics] Badly formed visitor variable: '#{v}'" if parts.size > 4
      row[:visitor]           = parts[0]
      row[:visit]             = parts[1] if parts[1]
      row[:previous_visit_at] = to_time(parts[3]) unless parts[3].blank?
    end

    # Session has two possible parts
    # => Session id (a timestamp)
    # => A pageview count incremented on each pageview for this session
    def session!(row)
      return if row[:session].blank?
      parts = row[:session].split('.')
      row[:session] = parts[0]
      row[:view] = parts[1] if parts[1]    
    end

    # This needs to be rewritten as a proper analyser
    def email_client!(row)
      original_browser = row[:browser]
      if row[:user_agent] =~ /MSOffice 12/i
        row[:email_client] = "Outlook 2007"
      elsif row[:referrer] =~ /mail\.google.*\/mail/
        row[:email_client] = "GMail"
      elsif row[:referrer] =~ /\.hotmail\./
        row[:email_client] = 'Hotmail'
      elsif row[:referrer] =~ /mail\.yahoo\./
        row[:email_client] = 'Yahoo Mail'
      elsif row[:referrer] =~ /mail\.live\./
        row[:email_client] = 'Microsoft Live'
      elsif row[:user_agent] =~ /iPod|iPhone/
        row[:email_client] = 'iPhone Mail'
      elsif row[:user_agent] =~ /AppleWebKit/
        row[:email_client] = 'Apple Mail'
      elsif row[:user_agent] =~ /Thunderbird/
        row[:email_client] = "Thunderbird"
      elsif row[:user_agent] =~ /Lotus-Notes/
        row[:email_client] = 'Lotus Notes' 
      elsif row[:user_agent] =~ /Eudora/
        row[:email_client] = 'Eudora'
      elsif row[:user_agent] =~ /MAC OS X.*Tasman/
        row[:email_client] = "Entourage"          
      elsif row[:user_agent] =~ /MSIE/
        row[:email_client] = 'Outlook 2003'
      else
        logger.info "[Web Analytics] Unknown Email Client: '#{row[:user_agent]}'"
      end
      if row[:email_client]
        row[:traffic_source] = 'email'
        row[:referrer_category] = 'campaign'
      end
    end
  
    def to_time(timestamp)
      return nil if timestamp.blank?
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
          VALID_PARAMS[var.to_sym] ? result[VALID_PARAMS[var.to_sym]] = URI.decode(value) : false
        end
      end if params
      result[:timezone] = result[:timezone].to_i if result[:timezone]
      result[:dialect] = result[:language]
      result
    end
  
    def params_to_hash(params)
      result = {}
      split_into_parameters(params).each do |p|
        var, value = p.split('=')
        result[var] = CGI.unescape(value) unless value.blank?
      end if params
      result
    end

  end
end