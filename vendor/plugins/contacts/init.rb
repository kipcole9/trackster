config.gem 'lockfile'
config.gem 'vpim'
require 'contacts/import'
require 'contacts/vcard_importer'
require 'contacts/vcard/import'
require 'contacts/csv/import'
I18n.load_path << Dir[ File.join(File.dirname(__FILE__), 'config', 'locale', '*.{rb,yml}') ]
