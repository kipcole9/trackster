module Charting
  class FlashChart

    include OpenFlashChart::View
    include OpenFlashChart::Controller
    include OpenFlashChart
    include ActiveSupport::CoreExtensions::String::Inflections
    include ActionView::Helpers::NumberHelper
    PIE_COLOURS     = ["#d01f3c","#356aa0","#C79810",
                      "0x336699", "0x88AACC", "0x999933", "0x666699",
    		              "0xCC9933", "0x006666", "0x3399FF", "0x993300",
    		              "0xAAAA77", "0x666666", "0xFFCC66", "0x6699CC",
    		              "0x663366", "0x9999CC", "0xAAAAAA", "0x669999",
    		              "0xBBBB55", "0xCC6600", "0x9999FF", "0x0066CC",
    		              "0x99CCCC", "0x999999", "0xFFCC00", "0x009999",
    		              "0x99CC33", "0xFF9900", "0x999966", "0x66CCCC",
    		              "0x339966", "0xCCCC33"]
    
    DEFAULT_OPTIONS = { :type               => AreaLine, 
                        :line_width         => 4, 
                        :dot_size           => 5, 
                        :colour             => '#1987D5', #'#E41B17'
                        :fill_colour        => '#1987D5', #'#CFECEC',
                        :fill_alpha         => 0.2,
                        :background_colour  => '#dddddd', # '#E3E1D5', # '#dddddd',
                        :grid_colour        => '#ffffff',
                        :grid_division      => 5,
                        :label_steps        => 2,
                        :width              => '100%',
                        :height             => '200',
                        :regression         => false,             # Also produce a regression series?
                        :offset             => true               # Offset x-axis from y?
                      }
      
    def initialize(data_source, column, label = nil, options = {})
      options[:background_colour] = @@background_colour if defined?(@@background_colour) && !options[:background_colour]
      @options = DEFAULT_OPTIONS.merge(options)
      @div_name = @options[:id] || "chart_" + ActiveSupport::SecureRandom.hex(5)
      @options[:text] = data_source.first.class.human_attribute_name(column.to_s) if @options[:text].blank? && !data_source.empty?
      @chart = graph_data(data_source, column, label, @options)      
    end
    
    # Ugly hack until ofc can set a transparent background
    # We'll set this class variable from the outside until then 
    # so the callers don't have to know about this and it can be
    # removed later
    def self.set_background_colour(colour)
      @@background_colour = colour
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
      if options[:type] == Pie
        graph_data_for_pie(data_source, column, label, options, &block)
      else
        graph_data_for_line(data_source, column, label, options, &block)
      end
    end
    
    def graph_data_for_line(data_source, column, label, options, &block)
      series            = options[:type].new
      series.values     = data_set = series_from_data(data_source, column, label, options)
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
    
    def graph_data_for_pie(data_source, column, label, options, &block)
      series            = options[:type].new
      series.values     = data_set = series_from_data_for_pie(data_source, column, label, options)
      series.tooltip    = options[:tooltip] if options[:tooltip]
      series.colours    = PIE_COLOURS
      series.start_angle = 35
      series.animate    = true     

      chart = OpenFlashChart.new
      
      # The data series
      chart.add_element(series)
      chart.bg_colour = options[:background_colour]      
      chart.x_axis = nil
      chart.title = nil
      chart
    end
    
    def series_from_data_for_pie(data_source, column, label, options)
      result_array = []
      data_source.each do |item|
        next if (item[column].blank? || item[column].to_i == 0)
        pie_label = item[label].blank? ? I18n.t('not_set') : item[label]
        result_array << PieValue.new(item[column].to_i, pie_label) 
      end
      result_array
    end
    
    def series_from_data(data_source, column, label, options)
      data_source.inject([]){|result_array, item| result_array << item[column].to_i}
    end
    
    def labels_from_data(data_source, label, options)
      data_source.inject([]) do |label_array, item|
        label_array << label_from_row(item, label, label_visible?(label_array, data_source, options[:label_steps]))
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
    
    def label_visible?(array, data_source, modulus)
      (array.size % modulus == 0) || (data_source.size < 10)
    end
  end
end    