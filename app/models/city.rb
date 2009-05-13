require 'uri'
class City< ActiveRecord::Base
  set_table_name 'citiesByCountry'
  
  def name
    URI.decode(self.read_attribute('name'))
  end
  
end
