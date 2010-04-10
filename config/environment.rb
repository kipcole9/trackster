# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "file-tail", :lib => 'file/tail' 
  config.gem "inifile"
  config.gem "graticule"
  config.gem 'will_paginate'
  config.gem 'daemons'
  config.gem 'nokogiri'
  config.gem 'RedCloth'
  config.gem "vpim"
  config.gem "authlogic"
  config.gem "cancan"
  config.gem "inherited_resources", :version => "1.0.3"
  config.gem "has_scope"
  config.gem "newrelic_rpm"
  config.gem "acts-as-taggable-on"
  config.gem 'fastercsv'
  config.gem 'delayed_job'
  config.gem 'lockfile'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  config.active_record.observers = :user_observer, :history_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  config.i18n.load_path += Dir[Rails.root.join("#{Rails.root}", 'config', 'locales', '**', '*.{rb,yml}')]
  config.i18n.default_locale = "en"

  
  # Make sure the admin user is all sorted.
  # On an initial deploy this could fail since the 
  # schema isn't loaded.  Hence the exception
  # recovery.
  config.after_initialize do
    Synthesis::AssetPackage.merge_environments = ["staging", "production"]
  end

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = YAML.load(File.read("#{Rails.root}/config/mailer.yml"))['mailer']
end