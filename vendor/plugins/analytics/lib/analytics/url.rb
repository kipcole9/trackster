module Analytics
  class Url
    include Analytics::Params
    attr_accessor :url, :host, :path, :params, :logger
    
    def initialize(url)
      return if url.blank?
      @logger     = Rails.logger
      @url        = url
      parsed_url  = URI.parse(url)
      @host       = parsed_url.host
      @path       = parsed_url.path
      @params     = params_to_hash(parsed_url.query)
    rescue
      @logger.error "[URL] Invalid URI detected when extracting host data: '#{url}'"
    end
  end
  
end