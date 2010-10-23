module Analytics
  class Referrer
    attr_reader :url
    extend ::ActiveSupport::Memoizable
    include Analytics::Params
    
    def initialize(referrer)
      @referrer = referrer
      @url = Analytics::Url.new(referrer)
    end
    
    def traffic_source
      if @referrer.blank? || @referrer == "-" || @referrer == 'mhtmlmain:'
        'direct'
      elsif self.search_engine
        'search'
      else
        'referral'
      end
    end
    
    def host
      @url.host
    end
    
    # Should categorise as 'map', 'image', 'blog' and so on
    def category
      nil
    end
    
    def search_engine
      SearchEngine.find_from_host(@url.host)
    end
    memoize :search_engine
    
    def country
      search_engine ? search_engine.country : nil
    end
    alias :country_code :country
    
    def search_terms
      if search_engine 
        @search_terms = @url.params[search_engine.query_param]
        if search_engine.query_param == 'prev' && @search_terms
          # Hack for google images.  Search terms are the q param within the prev param.
          revised_terms = params_to_hash(@search_terms.sub(/\A.*\?/,''))
          @search_terms = revised_terms['q']
        end
      end
      @search_terms
    end
    
    def gmail?
      self.url.host =~ /mail\.google.*\/mail/
    end
    
    def hotmail?
      self.url.host =~ /\.hotmail\./
    end
    
    def yahoo_mail?
      self.url.host =~ /mail\.yahoo\./
    end
    
    def live_mail?
      self.url.host =~ /mail\.live\./
    end
  end
end