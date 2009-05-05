module Trackster
  # Exceptions
  class TracksterException < Error; end
  class Unauthorized < TracksterException; end
  
  # Loads and makes available config data
  class Config
    @@config = YAML.load(File.read("#{Rails.root}/config/trackster_config.yml"))
  
    def self.method_missing(method, *args)
      @@config[Rails.env][method] || @@config['production'][method]
    end
  end
  
  
end