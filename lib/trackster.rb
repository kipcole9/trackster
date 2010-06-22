# Configuration module for Trackster.
module Trackster
  # Exceptions
  class TracksterException < RuntimeError; end
  class Unauthorized < TracksterException; end
  
  # Loads and makes available config data
  class Config
  
    def self.method_missing(method, *args)
      @@config = YAML.load(File.read("#{Rails.root}/config/trackster_config.yml")) unless defined?(@@config)
      @@config[Rails.env][method] || @@config['production'][method]
    end
  end
  
  
end