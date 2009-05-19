class TableFormatter
  attr_accessor     :html, :table_columns, :klass, :merged_options, :rows, :totals
  include           ::ActionView::Helpers::NumberHelper
  EXCLUDE_COLUMNS = [:id, :updated_at, :created_at]
  DEFAULT_OPTIONS = {:exclude => EXCLUDE_COLUMNS, :exclude_ids => true, :odd_row => "odd", :even_row => "even"}

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
      totals.each do |total, values|
        next if values.empty?
        html.tr do
          first_column = true
          table_columns.each do |column| 
            value = first_column ? I18n.t(total) : values[column[:name].to_s]
            output_cell_value(:th, value, column)
            first_column = false
          end
        end
      end
    end    
  end

  # Outputs one cell
  def output_cell(row, column, options = {})
    output_cell_value(:td, row[column[:name]], column, options)
  end
  
  def output_cell_value(cell_type, value, column, options = {})
    html.__send__(cell_type, column[:formatter].call(value), (column[:class] ? {:class => column[:class]} : {}))
  end

private
  # Craft a CSS id
  def row_id(row)
    "#{klass.name.underscore}_#{row[klass.primary_key]}"
  end
  
  def default_formatter(data)
    data
  end
  
  def table_has_totals?
    totals.all?{|t| !t.empty?}
  end
  
  def initialise_columns(rows, model, options)
    columns = []
    options[:include] = options[:include].map(&:to_s) if options[:include]
    options[:exclude] = options[:exclude].map(&:to_s) if options[:exclude]
    requested_columns = columns_from_row(rows.first)
    columns_hash = rows.first.attributes
    requested_columns.each do |column, value|
      columns << column_definition(column, value) if include_column?(column, options)
    end
    columns.sort{|a, b| a[:order] <=> b[:order] }
  end

  # Return a hash of hashes
  # :sum => {:column_name_1 => value, :column_name_2 => value}
  def initialise_totalling(rows, columns)
    totals = {:sum => {}, :average => {}, :count => {}}
    columns.each do |column|
      next unless column[:total]
      total = column[:total].is_a?(Array) ? column[:total] : [column[:total]]
      total.each do |t|
        case t
          when :sum
            totals[:sum][column[:name]] = rows.sum(column[:name])
          when :mean, :average, :avg
            totals[:average][column[:name]] = rows.mean(column[:name])
          when :count
            totals[:count][column[:name]] = rows.count(column[:name])
        end
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
    proc { |*args| send(sym, *args) }
  end

  # Decide if the given column is to be displayed in the table
  def include_column?(column, options)
    puts column.inspect
    return options[:include].include?(column) if options[:include]
    return false if options[:exclude] && options[:exclude].include?(column)
    return false if options[:exclude_ids] && column.match(/_id\Z/)  
    true
  end
end
