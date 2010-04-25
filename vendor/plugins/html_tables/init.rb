require File.dirname(__FILE__) + '/lib/html_tables/table_formatter.rb'
require File.dirname(__FILE__) + '/lib/html_tables/column_formatter.rb'
require File.dirname(__FILE__) + '/lib/html_tables/html_tables.rb'
Array.send :include, HtmlTables
I18n.load_path << Dir[ File.join(File.dirname(__FILE__), 'lib', 'locale', '*.{rb,yml}') ]
ActiveRecord::Base.send :include, ColumnFormats