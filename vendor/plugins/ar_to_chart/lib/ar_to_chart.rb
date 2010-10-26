require 'charting/highcharts.rb'
require 'charting/sparklines.rb'

require 'charting/active_record_array.rb'
Array.send :include, Charting::ActiveRecordArray

require 'charting/transforms.rb'
ActiveRecord::Base.send :include, Charting::Transforms
I18n.load_path << Dir[ File.join(File.dirname(__FILE__), 'config', 'locale', '*.{rb,yml}') ]