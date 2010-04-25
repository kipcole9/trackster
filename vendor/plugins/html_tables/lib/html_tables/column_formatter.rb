module HtmlTables
  module ColumnFormatter
    
    def self.included(base)
      base.class_eval do
        extend  ActiveSupport::Memoizable
        memoize :integer_with_delimiter
        memoize :float_with_precision
        memoize :currency_without_sign
      end
    end
    
    MIN_PERCENT_BAR_VALUE   = 2.0   # Below which no bar is drawn
    REDUCTION_FACTOR        = 0.80  # Scale the bar graps so they have room for the percentage number in most cases
    
    def not_set_on_blank(val, options)
      if options[:cell_type] == :th
        val
      else
        val.blank? ? I18n.t(options[:not_set_key]) : val
      end
    end

    def group_not_set_on_blank(val, options)
      # Need more context to do this
    end
  
    def unknown_on_blank(val, options)
      if options[:cell_type] == :th
        val
      else    
        val.blank? ? I18n.t(options[:unknown_key]) : val
      end
    end

    def seconds_to_time(val, options)
      hours = val / 3600
      minutes = (val / 60) - (hours * 60)
      seconds = val % 60
      (minutes += 1; seconds = 0) if seconds == 60
      (hours += 1; minutes = 0) if minutes == 60
      "#{"%02d" % hours}:#{"%02d" % minutes}:#{"%02d" % seconds}"
    end
    #memoize :seconds_to_time
  
    def hours_to_time(val, options)
      "#{"%02d" % val}:00"
    end
  
    def percentage(val, options)
      number_to_percentage(val ? val.to_f : 0, :precision => 1)
    end
  
    # TODO this should be done just once at instantiation but we have a potential
    # ordering issue  since I18n initializer may not have run yet (needs to be checked)
    def integer_with_delimiter(val, options = {})
      if I18n::Backend::Simple.included_modules.include? Cldr::Format 
        I18n.localize(val.to_i, :format => :short)
      else 
        number_with_delimiter(val.to_i)
      end
    end

    def float_with_precision(val, options)
      number_with_precision(val.to_f, :precision => 1)
    end

    def currency_without_sign(val, options)
      number_with_precision(val.to_f, :precision => 2)
    end
  
    # Output a horizontal bar and value
    # No bar if the value is <
    def bar_and_percentage(val, options)
      if options[:cell_type] == :td
        width = val * bar_reduction_factor(val)
        bar = (val.to_f > MIN_PERCENT_BAR_VALUE) ? "<div class=\"hbar\" style=\"width:#{width}%\">&nbsp;</div>" : ''
        bar + "<div>" + percentage(val, :precision => 1) + "</div>"
      else
        percentage(val, :precision => 1)
      end
    end
    
  private
    def bar_reduction_factor(value)
      case value
        when 0..79  then  REDUCTION_FACTOR
        when 80..99 then  0.6
        else 0.3
      end
    end  
  end
end