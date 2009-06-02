module Charting
  class FlashChart

    include OpenFlashChart::View
    include OpenFlashChart::Controller
    include OpenFlashChart
    include ActiveSupport::CoreExtensions::String::Inflections
    include ActionView::Helpers::NumberHelper    
    
    DEFAULT_OPTIONS = { :type               => AreaLine, 
                        :line_width         => 4, 
                        :dot_size           => 5, 
                        :colour             => '#1987D5', #'#E41B17'
                        :fill_colour        => '#1987D5', #'#CFECEC',
                        :fill_alpha         => 0.2,
                        :background_colour  => '#dddddd',
                        :grid_colour        => '#ffffff',
                        :grid_division      => 5,
                        :label_steps        => 2,
                        :width              => '100%',
                        :height             => '200',
                        :regression         => false,             # Also produce a regression series?
                        :offset             => true               # Offset x-axis from y?
                      }
      
    def initialize(data_source, column, label = nil, options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @div_name = @options[:id] || "chart_" + ActiveSupport::SecureRandom.hex(5)
      @options[:text] = data_source.first.class.human_attribute_name(column.to_s) if @options[:text].blank? && !data_source.empty?
      @chart = graph_data(data_source, column, label, @options)      
    end
    
    def render_chart
      if @chart
        open_flash_chart_embedded(@options[:width], @options[:height], @div_name, @chart.render)
      else
        I18n.t('no_data_for_chart')
      end
    end

    def graph_data(data_source, column, label, options, &block) 
      return nil if data_source.empty?
      series            = options[:type].new
      series.values     = data_set = series_from_data(data_source, column, options)
      series.tooltip    = options[:tooltip] if options[:tooltip]        
      series.text       = options[:text] if options[:text]
      series.width      = options[:line_width]
      series.colour     = options[:colour]
      series.fill       = options[:fill_colour]
      series.fill_alpha = options[:fill_alpha]
      series.dot_size   = options[:dot_size]
      
      # Linear regression option (create basic trend line)
      if options[:regression]
        regression          = Line.new
        regression.colour   = '#555555'
        regression.tooltip  = "#{I18n.t('estimate', :default => 'Estimate')} #val#"
        regression.text     = "#{options[:text]} trend"
        regression.values   = regression_data = data_set.regression.map{|i| i < 0 ? 0 : i}
      end
      
      y = YAxis.new
      y_max = data_set.max
      y_min = [data_set.min, 0].min
      if regression
        y_max = [y_max, regression_data.max].max
      end
      y.set_range(y_min, y_max, ((y_max - y_min) / options[:grid_division]).to_i)
      y.set_grid_colour(options[:grid_colour])

      x = XAxis.new
      x.offset = options[:offset]
      x.labels = labels_from_data(data_source, label, options)
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
    
    def series_from_data(data_source, column, options)
      data_source.inject([]){|result_array, item| result_array << item[column].to_i}
    end
    
    def labels_from_data(data_source, label, options)
      data_source.inject([]) do |label_array, item|
        label_array << label_from_row(item, label, label_visible?(label_array, options[:label_steps]))
      end
    end
          
    def label_from_row(item, attrib, visible)
      label = format_label(item, attrib)
      {:text => label, :visible => visible, :justify => 'center'}
    end
    
    def format_label(item, label)
      value = item[label]  
      case label
        when :date
          "#{value.day} #{I18n.t('date.abbr_month_names')[value.month]}"
        when :hour, :local_hour
          "#{"%02d" % value}:00"
        when :day_of_week
          I18n.t('date.abbr_day_names')[value]
        when :month
          I18n.t('date.abbr_month_names')[value]
        when :week, :year, :hour
          value.to_s
        else case value
          when Integer, Fixnum, Bignum, Float
            number_with_delimiter(value)
          else
            value.to_s
        end  
      end
    end
    
    def label_visible?(array, modulus)
      (array.size % modulus == 0)
    end
  end
end    