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

  config.gem 'will_paginate'
  config.gem 'nokogiri'
  config.gem 'RedCloth'
  config.gem "authlogic"
  config.gem "cancan", :version => "1.1.1"
  config.gem "inherited_resources", :version => "1.0.3"
  config.gem "has_scope"
  config.gem "acts-as-taggable-on"
  config.gem 'fastercsv'
  config.gem 'i18n', :version => "0.3.6"
  config.gem 'ruby-cldr', :lib => 'cldr'
  config.gem 'delayed_job'

  # Performance monitoring
  config.gem "newrelic_rpm"

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

  config.after_initialize do
    Synthesis::AssetPackage.merge_environments = ["staging", "production"]
    ActionView::Base.default_form_builder = Caerus::FormBuilder  
  end
  
  # These are the models we add reporting capability to
  # TODO we also need to factor out configuring the various
  # has_many relationships - class_eval?
  config.to_prepare do
    Account.send :include, Analytics::Model::Reports
    Property.send :include, Analytics::Model::Reports
    Campaign.send :include, Analytics::Model::Reports
  end

  config.action_mailer.delivery_method = :sendmail
end