class WebAnalytics
  VALID_PARAMS = {
                  :utac         =>  :site_code,
                  :utvis        =>  :visitor,
                  :utses        =>  :session,
                  :utmdt        =>  :page_title,	
                  :utmsr        =>  :screen_size, 
                  :utmsc        =>  :color_depth, 
                  :utmul        =>  :language, 
                  :utmcs        =>  :charset, 
                  :utmfl        =>  :flash_version, 
                  :utmn         =>  :unique_request,
                  :utm_campaign =>  :campaign_name, 
                  :utm_source   =>  :campaign_source,
                  :utm_medium   =>  :campaign_medium,
                  :utm_content  =>  :campaign_content,
                  :utmp         =>  :url,
                  :utob         =>  :outbound
                }
                  
  attr_accessor :params 
  
  URL = /\A(\/tracker.gif)\?(.*)/

  # Parse the analytics url.  We recognise that the 
  # referring URL parameter (utmr) might itself have 
  # parameters.  We assume that there is not overlap
  # between the referer parameters and the GA
  # parameters.  That might need to change.
  def parse_url(url)
    params = split_into_parameters(url)
    params ? params_to_hash(params) : {}
  end
  
  def create(url, model = Track)
    row = model.new
    data = parse_url(url)
    data.each do |k, v|
      row.send "#{VALID_PARAMS[k].to_s}=", v
    end
    row
  end
  
  def save(url, model = Track)
    row = create(url, model)
    row.save!
  end
    
private
  def split_into_parameters(url)
    param_string = url.match(URL)
    param_string ? param_string[2].split('&') : []
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
