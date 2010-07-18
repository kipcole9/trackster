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
  
  def self.reverse_geocode(ip_address)
    if lookup = find(:first, :conditions => ['ip = ?', convert_to_integer_cidr24(ip_address)])
      @country = Country.find_by_id(lookup.country)
      @city = City.find_by_country_and_city(lookup.country, lookup.city)
    end
    return @city, @country
  end
    
  
end
