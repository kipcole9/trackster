class IpAddress < ActiveRecord::Base
  set_table_name 'ip4'
  require 'uri'
  
  def self.convert_to_integer(dot_notation)
    octets = dot_notation.split('.').map(&:to_i)
    result = (octets[0] * 16777216) + (octets[1] * 65536) + (octets[2] * 256) + octets[3]
  end
  
  def self.convert_to_integer_cidr24(string)
    octets = string.split('.').map(&:to_i)
    result = (octets[0] * 16777216) + (octets[1] * 65536) + (octets[2] * 256)
  end
  
  # Formatting of geo data is tuned to fit
  # the ideosyncracies of the hostip data.  ie
  # some localities have ', state' in them
  # some country names are inconsistently formatted for case
  def self.reverse_geocode(ip_address, row = Hash.new)
    if ip_address.blank?
      raise row.inspect
    end
    if lookup = find(:first, :conditions => ['ip = ?', convert_to_integer_cidr24(ip_address)])
      country = Country.find_by_id(lookup.country).try(:code)
      city = City.find_by_country_and_city(lookup.country, lookup.city)
      # We store the country code only and translate on output so we can
      # have locale specific country names. We can't really do that for
      # region and locality though.
      row[:country] = country
      if city
        row[:locality]  = Iconv.iconv('utf8','iso-8859-1', URI.decode(city.name.split(',').first.strip)).first.titleize unless city.name.blank?
        row[:region]    = city.state.titleize unless city.state.blank?
        row[:latitude]  = city.lat
        row[:longitude] = city.lng
      end
      row[:geocoded_at] = Time.now
    else
      # If we can't geocode but we got here via a search engine, then try to use the
      # country TLD of the search engine and make an assumption about the country.
      row[:country] = row[:country_code] unless row[:country_code].blank?
    end
    row
  end
    
  
end
