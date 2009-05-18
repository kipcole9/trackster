require File.dirname(__FILE__) + '/lib/flash_chart.rb'
require File.dirname(__FILE__) + '/lib/active_record_flash_chart.rb'
Array.send :include, ActiveRecord::FlashChart
# ActiveRecord::Base.send :include, ColumnFormats