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
  def self.reverse_geocode(ip_address, row = nil)
    if ip_address.blank?
      raise row.inspect
    end
    if lookup = find(:first, :conditions => ['ip = ?', convert_to_integer_cidr24(ip_address)])
      country = Country.find_by_id(lookup.country])
      city = City.find_by_country_and_city(lookup.country, lookup.city)
      if row 
        if country
          row[:country] = country.name.titleize unless country.name.blank?
        end
        if city
          row[:locality]  = Iconv.iconv('utf8','iso-8859-1', URI.decode(city.name.split(',').first.strip)).first.titleize unless city.name.blank?
          row[:region]    = city.state.titleize unless city.state.blank?
          row[:latitude]  = city.lat
          row[:longitude] = city.lng
        end
        row[:geocoded_at] = Time.now
      end
    elsif !row[:country_code].blank? && country = Country.find_by_code(row[:country_code])
      # No IP Address lookup, but check if there was a search engine that got us here.
      # and perhaps we can use the country suffix to tell us the probable country
      row[:country] = country.name.titleize unless country.name.blank?
    end
  end
    
  
end
