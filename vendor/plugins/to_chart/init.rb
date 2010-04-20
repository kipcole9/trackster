require File.dirname(__FILE__) + '/lib/flash_chart.rb'
require File.dirname(__FILE__) + '/lib/sparkline.rb'
require File.dirname(__FILE__) + '/lib/active_record_flash_chart.rb'
Array.send :include, ActiveRecord::FlashChart
# ActiveRecord::Base.send :include, ColumnFormats
I18n.load_path << Dir[ File.join(File.dirname(__FILE__), 'config', 'locale', '*.{rb,yml}') ]