require 'uri'
class City< ActiveRecord::Base
  
  def name
    URI.decode(self.read_attribute('name'))
  end
  
end
