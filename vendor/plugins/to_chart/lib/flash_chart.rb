module Trackster
  class FlashChart

    include OpenFlashChart::View
    include OpenFlashChart::Controller
    include OpenFlashChart
    include ActiveSupport::CoreExtensions::String::Inflections 
    
    DEFAULT_OPTIONS = { :type               => Line, 
                        :line_width         => 4, 
                        :dot_size           => 5, 
                        :colour             => '#DFC329',
                        :background_colour  => '#dddddd',
                        :grid_colour        => '#ffffff',
                        :grid_division      => 5,
                        :label_modulus      => 1,
                        :width              => '100%',
                        :height             => '200',
                        :regression         => false
                      }
      
    def initialize(data_source, column, label = nil, options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @div_name = @options[:id] || "chart_" + ActiveSupport::SecureRandom.hex(5)
      @options[:text] = data_source.first.class.human_attribute_name(column.to_s) if @options[:text].blank?
      @chart = graph_data(data_source, column, label, @options)      
    end
    
    def render_chart
      open_flash_chart_embedded(@options[:width], @options[:height], @div_name, @chart.render)
    end

    def graph_data(data_source, column, label, options, &block)
      series            = options[:type].new
      series.values     = data_set = data_source.inject([]){|result_array, item| result_array << item[column]}
      series.tooltip    = options[:tooltip] if options[:tooltip]        
      series.text       = options[:text] if options[:text]
      series.width      = options[:line_width]
      series.colour     = options[:colour]
      series.dot_size   = options[:dot_size]
      
      # Linear regression option (create basic trend line)
      if options[:regression]
        regression          = Line.new
        regression.colour   = '#555555'
        regression.text     = "#{options[:text]} trend"
        regression.values   = regression_data = data_set.regression
      end
      
      y = YAxis.new
      y_max = data_set.max
      y_min = [data_set.min, 0].min
      if regression
        y_max = [y_max, regression_data.max].max
        y_min = [y_min, regression_data.min].min
      end
      y.set_range(y_min, y_max, (y_max / options[:grid_division]).to_i)
      y.set_grid_colour(options[:grid_colour])

      x = XAxis.new
      x.labels = data_source.inject([]) do |label_array, item|
        label_array << ((label_array.size % options[:label_modulus] == 0) ? format_label(item, label) : '')
      end if label
      x.set_grid_colour(options[:grid_colour]);

      chart = OpenFlashChart.new
      chart.bg_colour = options[:background_colour]
      chart.y_axis    = y
      chart.x_axis    = x
      
      # The data series
      chart.add_element(series)
      chart.add_element(regression) if regression
      chart
    end
    
    def format_label(item, label)
      value = item[label]  
      case label
        when :date
          "#{value.day} #{I18n.t('date.abbr_month_names')[value.month]}"
        when :day
          I18n.t('date.abbr_day_names')[day]
        when :month
          I18n.t('date.abbr_month_names')[month]
        when :week, :year, :hour
          value.to_s
        else case value
          when Integer, Fixnum, Bignum, Float
            number_with_delimeter(value)
          else
            value.to_s
        end  
      end
    end
  end
end    