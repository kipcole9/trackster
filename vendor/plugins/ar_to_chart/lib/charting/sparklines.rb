module Charting
  module Sparklines
    class Renderer
      DEFAULT_OPTIONS = {
        :type                  => :line,
      }

      attr_accessor :series, :options, :chart
      
      # Generate jQuery sparkline based charts.
      #
      # Ensure jquery-sparkine library is loaded before use, for example:
      #
      #  <script src="/javascripts/jquery.sparkline.js" type="text/javascript"></script>
      # 
      # And that you invoke somethink like:
      #
      #   /* Initialize sparklines */
      #   $(document).ready(function() {
      #     $('.sparkline').sparkline();
      #   });
      #
      # in your document script.
      #
      # Styling in CSS is required for the <span> container which
      # has a class of 'sparkline'
      #
      # ====Parameters
      #
      #   data_source:      The active record result set
      #   data_column:      one column name to be charted 
      #   options:          options hash 
      #
      # ====Options
      #
      #
      def initialize(data_source, data_column, options = {})
        @options = DEFAULT_OPTIONS.merge(options)
        @options[:container] ||= generate_container_name
        @data_column = data_column
        @chart = chart_class.new(data_source, @data_column, @options)
      end
      
      def to_html
        @chart.to_html
      end
      
      def self.configure
        yield self
      end
      
    private
      def chart_class
        @chart_class ||= "Charting::Sparklines::#{options[:type].to_s.titleize}".constantize
      end

      def generate_container_name
        "sparkline_" + ActiveSupport::SecureRandom.hex(3)
      end

    end
  end
end
