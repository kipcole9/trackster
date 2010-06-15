# Using the information that is derived solely from standard HTTP
# requests, see how unique our visitor is.  This means we need to add some
# additional headers to the log format.
require 'singleton'
module Analytics
  class Fingerprint
    include Singleton
    
    attr_accessor :prints
    
    def initialize
      @prints = {}
    end
    
    def self.analyse
      
    end
  end
end
        