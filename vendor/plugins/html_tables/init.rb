require File.dirname(__FILE__) + '/lib/table_formatter.rb'
Array.send :include, HtmlTables
I18n.load_path << Dir[ File.join(File.dirname(__FILE__), 'lib', 'locale', '*.{rb,yml}') ]
ActiveRecord::Base.send :include, ColumnFormats