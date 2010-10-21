# Adds method to Array to allow output of flash-based charts from
# active record result sets
module ActiveRecord
  module FlashChart
    def self.included(base)
      base.class_eval do
        # extend ClassMethods
        include InstanceMethods
      end
    end
  
    module InstanceMethods
      def to_chart(column, labels = nil, options = {}, &block)
        default_options = {}
        merged_options = default_options.merge(options)
        @chart = Charting::Highcharts.new(self, labels.to_sym, column, merged_options, &block)
        #@chart = Charting::FlashChart.new(self, column, labels.to_sym, merged_options, &block)
        @chart.to_html
      end
      
      def to_sparkline(column, options = {}, &block)
        default_options = {}
        merged_options = default_options.merge(options)
        @chart = Charting::Sparkline.new(self, column, merged_options, &block)
        @chart.to_html
      end
    end
  
    module ClassMethods

    end
  end
end