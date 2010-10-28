# Adds method to Array to allow output of flash-based charts from
# active record result sets
module Charting
  module ActiveRecordArray
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
  
    module InstanceMethods
      def to_chart(columns, label_column, options = {})
        chart_object(columns, label_column, options).to_html
      end
      
      def to_container_and_script(columns, label_column, options = {})
        chart = chart_object(columns, label_column, options)
        return chart.container, chart.script
      end
      
      def to_sparkline(column, options = {})
        sparkline_object(column, options).to_html
      end
      
    private
      # Eventually we'll do charting engine selection here.  For now 
      # only Highcharts.
      def chart_object(label_column, columns, options)
        Charting::Highcharts::Renderer.new(self, columns, label_column, merged_options(options))
      end
      
      def sparkline_object(column, options)
        Charting::Sparklines::Renderer.new(self, column, merged_options(options))    
      end
      
      def merged_options(options)
        {}.merge(options)
      end
      
    end
  
    module ClassMethods

    end
  end
end