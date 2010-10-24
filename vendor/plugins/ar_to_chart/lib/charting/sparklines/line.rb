module Charting
  module Sparklines
    class Line < Charting::Sparklines::Base
      
      def series
        @chart_series ||= data_source.map{|row| row[data_column].to_i }
      end

    end
  end
end
      
