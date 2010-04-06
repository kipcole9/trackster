require 'contacts/import_export'
require 'contacts/vcard_importer'
require 'contacts/vcard'
require 'contacts/csv'
I18n.load_path << Dir[ File.join(File.dirname(__FILE__), 'config', 'locale', '*.{rb,yml}') ]
