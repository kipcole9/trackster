require File.dirname(__FILE__) + '/lib/table_formatter.rb'
Array.send :include, HtmlTables
ActiveRecord::Base.send :include, ColumnFormats