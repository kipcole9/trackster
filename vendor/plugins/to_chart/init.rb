require File.dirname(__FILE__) + '/lib/flash_charts.rb'
require File.dirname(__FILE__) + '/lib/ar_flash_charts.rb'
Array.send :include, Trackster::FlashCharts
# ActiveRecord::Base.send :include, ColumnFormats