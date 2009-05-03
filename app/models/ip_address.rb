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
  
  def self.reverse_geocode(ip_address, row = nil)
    if lookup = find(:first, :conditions => ['ip = ?', convert_to_integer_cidr24(ip_address)])
      country = Country.find(:first, :conditions => ['id = ?', lookup.country])
      city = City.find(:first, :conditions => ['country = ? AND city = ?', lookup.country, lookup.city])
      if row 
        if country
          row.country = country.name.capitalize unless country.name.blank?
        end
        if city
          row.locality = URI.decode(city.name) unless city.name.blank?
          row.region= city.state
          row.latitude = city.lat
          row.longitude = city.lng
        end
        row.geocoded_at = Time.now
      end
    end
  end
    
  
end
