# Include hook code here
I18n.load_path << Dir[ File.join(File.dirname(__FILE__), 'config', 'locales', '*.{rb,yml}') ]
require "#{File.dirname(__FILE__)}/lib/authoriser"

