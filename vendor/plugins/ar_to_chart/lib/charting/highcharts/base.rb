module Charting
  module Highcharts
    class Base
      attr_reader :data_source, :category_column, :data_columns, :options
      
      WEEKEND         = [0,6]   # The days of the week that are the weekend (Sun, Sat)
      AXIS_START_UNIT = 0.5     # Where highcharts starts its x-axis in axis units
      MAX_X_LABELS    = 10      # Display no more than this number of category labels
      DEFAULT_OPTIONS = {

      }

      def initialize(data_source, category_column, data_columns, options = {})
        @options          = DEFAULT_OPTIONS.merge(options)
        @category_column  = category_column
        @data_columns     = data_columns
        @data_source      = data_source
        @data_source      = linearize if @options.delete(:linearize)       
        @options[:x_step] ||= (@data_source.size.to_f / MAX_X_LABELS.to_f).round
      end

      def chart_options
        {
          :title        => options[:title],
          :subtitle     => options[:subtitle],
          :x_axis       => options[:x_axis_title], 
          :y_axis       => options[:y_axis_title], 
          :x_step       => options[:x_step],
          :x_plot_bands => weekend_plot_bands
        }
      end

      # Define in concrete subclass
      def series
        nil
      end
      
      # Define in concrete subclass
      def categories
        nil
      end
      
      # Returns a plotbands definition for the data source
      # Only if the category column is a date or datetime
      def weekend_plot_bands
        return unless options[:weekend_plot_bands] && data_source.first[category_column].respond_to?(:to_date)
        x_plot_bands = data_source.inject_with_index([]) do |plot_bands, row, index|
          if WEEKEND.include?(row[category_column].to_date.wday)
            plot_bands << {:from => (index + AXIS_START_UNIT - 1), :to => (index + AXIS_START_UNIT)}
          end
          plot_bands
        end
      end
      
      def series_name(column)
        data_source.first.class.human_attribute_name(column)
      end
      
      def chart_type
        @chart_type ||= self.class.name.split('::').last.downcase
      end

      def container
        options[:container]
      end
    
      def to_js
        <<-EOF
          chart.#{chart_type}('#{container}', 
            #{categories.to_json}, 
            #{series.to_json},
            #{chart_options.to_json}
          );
        EOF
      end
      
      # When we retrieve datat from the data base it may have gaps where not
      # results are available. For charting we want to have a linearized
      # series of data so here we plug the gaps.
      # 
      # Punt that the categeory column tells us enough to know what the data
      # should be.
      def linearize
        range = Period.range_from(options)
        range = data_source.first[category_column]..range.last if range.first > data_source.first[category_column]
        klass = data_source.first.class
        index = 0
        range.inject(Array.new) do |linear_data, data_point|
          if data_source[index] && data_source[index][category_column] == data_point
            Rails.logger.info "Range: #{data_point}: Index[#{index}]: #{data_source[index][category_column]}[#{data_source[index][data_columns.first]}]: Copying"
            linear_data << data_source[index]
            index += 1
          else
            ds = data_source[index] ? " #{data_source[index][category_column]}[#{data_source[index][data_columns.first]}]: " : ''
            Rails.logger.info "Range: #{data_point}: Index[#{index}]:#{ds} Inserting"
            new_row = klass.new(category_column => data_point)
            data_columns.each {|column| new_row[column] = 0 }
            yield new_row if block_given?
            linear_data << new_row
          end
          linear_data
        end
      end
    end
  end
end