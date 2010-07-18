module Analytics
  # Formatting of geo data is tuned to fit
  # the ideosyncracies of the hostip data.  ie
  # some localities have ', state' in them
  # some country names are inconsistently formatted for case
  class Location
    def initialize(ip_address)
      @city, @country = IpAddress.reverse_geocode(ip_address)
    end
    
    def country
      @country.code if @country
    end
    
    def region
      @city.state.titleize if @city
    end
    alias :state :region
    alias :province :region
    
    def locality
      return nil unless @city && !@city.name.blank?
      Iconv.iconv('utf8','iso-8859-1', URI.decode(@city.name.split(',').first.strip)).first.titleize
    end
    alias :city :locality
    alias :town :locality
    
    def latitude
      @city.lat if @city
    end
    alias :lat :latitude
    
    def longitude
      @city.lng if @city
    end
    alias :lng :longitude
    
    def geocoded_at
      @geocoded_at ||= Time.now if self.country
    end
    
    # Calculate based upon Longitude - very rough estimate only
    # TODO Can do better with Lat/Lng lookups
    def timezone
      return nil unless self.longitude
      (self.longitude / 15).round * 60
    end

  end
  
end