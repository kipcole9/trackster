# Adds method to Array to allow output of flash-based charts from
# active record result sets
module Trackster
  module FlashCharts
    def self.included(base)
      base.class_eval do
        # extend ClassMethods
        include InstanceMethods
      end
    end
  
    module InstanceMethods
      def to_chart(x, y = nil, options = {})
        default_options = {}
        merged_options = default_options.merge(options)
        @chart = Trackster::FlashChart.new(self, x, y, merged_options)
        @chart.render_chart
      end
    end
  
    module ClassMethods

    end
  end
end