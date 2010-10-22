#require File.dirname(__FILE__) + '/lib/charting/flash_chart.rb'
#require File.dirname(__FILE__) + '/lib/charting/sparkline.rb'
require File.dirname(__FILE__) + '/lib/charting/highcharts.rb'
require File.dirname(__FILE__) + '/lib/ar_to_chart.rb'
Array.send :include, Charting::ActiveRecord
I18n.load_path << Dir[ File.join(File.dirname(__FILE__), 'config', 'locale', '*.{rb,yml}') ]