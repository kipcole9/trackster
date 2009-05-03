# TODO
# - Format spec in AR
# - Format outputs properly
# - odss and evens
# - ID? For table at least

class TableFormatter
  attr_accessor     :html, :table_columns, :klass, :merged_options, :rows
  include           ::ActionView::Helpers::NumberHelper
  EXCLUDE_COLUMNS = [:id, :updated_at, :created_at]
  DEFAULT_OPTIONS = {:exclude => EXCLUDE_COLUMNS, :exclude_ids => true, :odd_row => "odd", :even_row => "even"}

  def initialize(results, options)
    raise ArgumentError, "First argument must be an array of ActiveRecord rows" \
        unless results.try(:first).try(:class).try(:descends_from_active_record?)
    @klass = results.first.class
    @rows = results
    @merged_options = options.merge(DEFAULT_OPTIONS)
    @table_columns = initialise_columns(rows, klass, merged_options)
    @html = Builder::XmlMarkup.new(:indent => 2)
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
        table_columns.each {|column| html.th(column[:label]) }
      end
    end
  end

  # Outputs one row
  def output_row(row, count, options)
    html.tr :class => (count.even? ? options[:even_row] : options[:odd_row]), :id => row_id(row) do
      table_columns.each {|column| output_cell(row, column, options) }
    end
  end

  # Outputs one cell
  def output_cell(row, column, options)
    html.td column[:formatter].call(row[column[:name]]), (column[:class] ? {:class => column[:class]} : {})
  end

  # Output totals (calculations)
  def output_table_totals(options)
  end

  # And table footers
  def output_table_footers(options)
  end

  def render_table
    options = merged_options
    html.table (:summary => options[:summary]) do
      html.caption options[:caption] if options[:caption]
      output_table_headings(options)
      html.tbody do
        rows.each_with_index do |row, index|
          output_row(row, index, options)
        end
      end
      output_table_footers(options)
    end 
  end

private
  # Craft a CSS id
  def row_id(row)
    "#{klass.name.underscore}_#{row['id']}"
  end
  
  def default_formatter(data)
    data
  end
  
  def initialise_columns(rows, model, options)
    columns = []
    options[:include] = options[:include].map(&:to_s) if options[:include]
    options[:exclude] = options[:exclude].map(&:to_s) if options[:exclude]
    requested_columns = columns_from_row(rows.first)
    columns_hash = model.columns_hash
    requested_columns.each do |requested_column|
      column = columns_hash[requested_column]
      columns << column_template(column) if include_column?(column, options)
    end
    columns
  end

  def column_template(column)
    css_class, formatter = get_column_formatter(column)
    @default_formatter ||= procify(:default_formatter)
    template = {
      :name       => column.name,
      :label      => klass.human_attribute_name(column.name),
      :formatter  => formatter || @default_formatter,
      :class      => css_class
    }
  end
  
  def columns_from_row(row)
    columns = []
    row.attributes.each {|k, v| columns << k.to_s }
    columns
  end
  
  def get_column_formatter(column)
    format = klass.format(column.name)
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
    return options[:include].include?(column.name) if options[:include]
    return false if options[:exclude] && options[:exclude].include?(column.name)
    return false if options[:exclude_ids] && column.name.match(/_id\Z/)  
    true
  end
end
