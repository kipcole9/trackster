class TableFormatter
  attr_accessor   :html, :table_columns, :klass, :merged_options, :rows, :totals
  include         ::ActionView::Helpers::NumberHelper
  EXCLUDE_COLUMNS       = [:id, :updated_at, :created_at]
  DEFAULT_OPTIONS       = {:exclude => EXCLUDE_COLUMNS, :exclude_ids => true, :odd_row => "odd", :even_row => "even"}
  CALCULATED_COLUMNS    = /(percent|percentage|difference|diff)_of_(.*)/
  MIN_PERCENT_BAR_VALUE = 0.5   # Below which no bar is drawn
  REDUCTION_FACTOR      = 0.80  # Scale the bar graps so they have room for the percentage number in most cases

  def initialize(results, options)
    raise ArgumentError, "First argument must be an array of ActiveRecord rows" \
        unless  results.try(:first).try(:class).try(:descends_from_active_record?) ||
                results.is_a?(ActiveRecord::NamedScope::Scope)
    @klass  = results.first.class
    @rows   = results
    @column_order   = 0
    @merged_options = options.merge(DEFAULT_OPTIONS)
    @table_columns  = initialise_columns(rows, klass, merged_options)
    @totals         = initialise_totalling(rows, table_columns)
    results.sort(options[:sort]) if options[:sort] && options[:sort].is_a?(Proc)
    @merged_options[:rows] = results
    @html = Builder::XmlMarkup.new(:indent => 2)
  end

  # Main method for rendering a table
  def render_table
    options = merged_options
    table_options = options[:summary] ? {:summary => options[:summary]} : {}
    html.table table_options do
      html.caption options[:caption] if options[:caption]
      output_table_headings(options)
      output_table_footers(options)
      html.tbody do
        rows.each_with_index do |row, index|
          output_row(row, index, options)
        end
      end
    end 
  end

  # Outputs colgroups and column headings
  def output_table_headings(options)
    # Table heading
    html.colgroup do
      table_columns.each {|column| html.col :class => column[:name] }
    end
    
    # Column groups
    html.thead do
      html.tr(options[:heading], :colspan => columns.length) if options[:heading]
      html.tr do
        table_columns.each do |column| 
          html_options = {}
          html_options[:class] = column[:class] if column[:class]
          html.th(column[:label], html_options)
        end
      end
    end
  end

  # Outputs one row
  def output_row(row, count, options)
    html_options = {}
    html_options[:class] = (count.even? ? options[:even_row] : options[:odd_row])
    html_options[:id] = row_id(row) if row[klass.primary_key]
    html.tr html_options  do
      table_columns.each {|column| output_cell(row, column, options) }
    end
  end

  # Table footers
  def output_table_footers(options)
    output_table_totals(options)
  end

  # Output totals (calculations)
  def output_table_totals(options)
    return unless table_has_totals?
    html.tfoot do
      html.tr do
        first_column = true
        table_columns.each do |column| 
          value = first_column ? I18n.t('total') : totals[column[:name].to_s]
          output_cell_value(:th, value, column, options)
          first_column = false
        end
      end
    end    
  end

  # Outputs one cell
  def output_cell(row, column, options = {})
    output_cell_value(:td, row[column[:name]], column, options)
  end
  
  def output_cell_value(cell_type, value, column, options = {})
    result = column[:formatter].call(value, {:cell_type => cell_type, :column => column}.merge(options))
    result = result.nil? ? '' : result
    html.__send__(cell_type, (column[:class] ? {:class => column[:class]} : {})) do
      html << result
    end
  end

private
  # Craft a CSS id
  def row_id(row)
    "#{klass.name.underscore}_#{row[klass.primary_key]}"
  end
  
  def default_formatter(data, options)
    data.to_s
  end
  
  def table_has_totals?
    !totals.empty?
  end
  
  def initialise_columns(rows, model, options)
    columns = []
    options[:include] = options[:include].map(&:to_s) if options[:include]
    options[:exclude] = options[:exclude].map(&:to_s) if options[:exclude]
    add_calculated_columns_to_rows(rows, options)
    requested_columns = columns_from_row(rows.first)
    requested_columns.each do |column, value|
      columns << column_definition(column, value) if include_column?(column, options)
    end
    columns.sort{|a, b| a[:order] <=> b[:order] }
  end

  # Return a hash of hashes
  # :sum => {:column_name_1 => value, :column_name_2 => value}
  def initialise_totalling(rows, columns)
    totals = {}
    columns.each do |column|
      next unless column[:total]
      case column[:total]
        when :sum
          totals[column[:name]] = rows.make_numeric(column[:name]).sum(column[:name])
        when :mean, :average, :avg
          totals[column[:name]] = rows.make_numeric(column[:name]).mean(column[:name])
        when :count
          totals[column[:name]] = rows.make_numeric(column[:name]).count(column[:name])
      end
    end
    totals    
  end
  
  def column_definition(column, value)
    @column_order += 1
    @default_formatter ||= procify(:default_formatter)
    
    css_class, formatter = get_column_formatter(column.to_s, value)
    column_order = klass.format_of(column)[:order] || @column_order
    totals = klass.format_of(column)[:total]
    {
      :name       => column,
      :label      => klass.human_attribute_name(column),
      :formatter  => formatter || @default_formatter,
      :class      => css_class,
      :order      => column_order,
      :total      => totals
    }
  end
  
  def columns_from_row(row)
    columns = []
    row.attributes.each {|k, v| columns << k.to_s }
    columns
  end
  
  def get_column_formatter(column, value)
    format = klass.format_of(column)
    case format
    when Symbol
      formatter = procify(format)
    when Proc
      formatter = format  
    when Hash
      css_class = format[:class] if format[:class]
      formatter = format[:formatter] if format[:formatter]
      formatter = procify(formatter) if formatter && formatter.is_a?(Symbol)
    end
    return css_class, formatter
  end
  
  # A data formatter can be a symbol or a proc
  # If its a symbol then we 'procify' it so that
  # we have on calling interface in the output_cell method
  # - partially for clarity and partially for performance
  def procify(sym)
    proc { |val, options| send(sym, val, options) }
  end

  def not_set_on_blank(val, options)
    if options[:cell_type] == :th
      val
    else
      val.blank? ? I18n.t('not_set') : val
    end
  end

  def group_not_set_on_blank(val, options)
    # Need more context to do this
  end
  
  def unknown_on_blank(val, options)
    if options[:cell_type] == :th
      val
    else    
      val.blank? ? I18n.t('unknown') : val
    end
  end

  def seconds_to_time(val, options)
    minutes = val / 60
    hours = val / 3600
    seconds = val - (hours * 3600) - (minutes * 60)
    "#{"%02d" % hours}:#{"%02d" % minutes}:#{"%02d" % seconds}"
  end
  
  def hours_to_time(val, options)
    "#{"%02d" % val}:00"
  end
  
  def percentage(val, options)
    number_to_percentage(val ? val.to_f : 0, :precision => 1)
  end
  
  def integer_with_delimiter(val, options)
    number_with_delimiter(val.to_i)
  end
  
  def float_with_precision(val, options)
    number_with_precision(val.to_f, :precision => 1)
  end
  
  def currency_no_sign(val, options)
    number_with_precision(val.to_f, :precision => 2)
  end
  
  # Output a horizontal bar and value
  # No bar if the value is <
  def bar_and_percentage(val, options)
    if options[:cell_type] == :td
      width = val * REDUCTION_FACTOR
      bar = (val.to_f > MIN_PERCENT_BAR_VALUE) ? "<div class=\"hbar\" style=\"width:#{width}%\">&nbsp;</div>" : ''
      bar + "<div>" + percentage(val, :precision => 1) + "</div>"
    else
      percentage(val, :precision => 1)
    end
  end 
     
  # Decide if the given column is to be displayed in the table
  def include_column?(column, options)
    return options[:include].include?(column) if options[:include]
    return false if options[:exclude] && options[:exclude].include?(column)
    return false if options[:exclude_ids] && column.match(/_id\Z/)  
    true
  end
  
  def add_calculated_columns_to_rows(rows, options)
    options.each do |k, v|
      if match = k.to_s.match(CALCULATED_COLUMNS)
        raise ArgumentError, "[html_tables] Total value must be 0 for percentage_of" if match[1] =~ /percent/ && v.to_f == 0
        rows.each do |row|
          row[k.to_s] = case match[1]
            when 'percent', 'percentage'
              row[match[2]].to_f / v.to_f * 100
            when 'difference', 'diff'
              row[match[2]].to_f - v.to_f
            else
              raise ArgumentError, "[html_tables] Invalid calculated column '#{match[1]}' for '#{match[2]}'"
          end
        end
      end
    end  
  end

end
