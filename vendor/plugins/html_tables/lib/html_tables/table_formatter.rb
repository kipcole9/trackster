module HtmlTables
  class TableFormatter
    include                 HtmlTables::ColumnFormatter
    attr_accessor           :html, :table_columns, :klass, :merged_options, :rows, :totals
    attr_accessor           :column_cache
    include                 ::ActionView::Helpers::NumberHelper
    EXCLUDE_COLUMNS         = [:id, :updated_at, :created_at]
    DEFAULT_OPTIONS         = {
        :exclude      => EXCLUDE_COLUMNS, 
        :exclude_ids  => true, 
        :odd_row      => "odd", 
        :even_row     => "even", 
        :totals       => true,
        :total_one    => 'tables.total_one',
        :total_many   => 'tables.total_many',
        :unknown_key  => 'tables.unknown',
        :not_set_key  => 'tables.not_set'
    }
    CALCULATED_COLUMNS      = /(percent|percentage|difference|diff)_of_(.*)/
    
    def initialize(results, options)
      raise ArgumentError, "[to_table] First argument must be an array of ActiveRecord rows" \
        unless  results.try(:first).try(:class).try(:descends_from_active_record?) ||
                results.is_a?(ActiveRecord::NamedScope::Scope)
      raise ArgumentError, "[to_table] Sort option must be a Proc" \
        if options[:sort] && !options[:sort].is_a?(Proc)
          
      @klass          = results.first.class
      @rows           = results
      @column_order   = 0
      @merged_options = DEFAULT_OPTIONS.merge(options)
      @table_columns  = initialise_columns(rows, klass, merged_options)
      @totals         = initialise_totalling(rows, table_columns)
      results.sort(options[:sort]) if options[:sort]
      @merged_options[:rows] = results
      @html = Builder::XmlMarkup.new(:indent => 2)
      @column_cache   = {}
    end

    # Main method for rendering a table
    def to_html
      options = merged_options
      table_options = {}
      html.table table_options do
        html.caption(options[:caption]) if options[:caption]
        output_table_headings(options)
        output_table_footers(options)
        html.tbody do
          rows.each_with_index do |row, index|
            output_row(row, index, options)
          end
        end
      end 
    end

  protected
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
      output_table_totals(options) if options[:totals] && rows.length > 1
    end

    # Output totals (calculations)
    def output_table_totals(options)
      return unless table_has_totals?
      html.tfoot do
        html.tr do
          first_column = true
          table_columns.each do |column| 
            value = first_column ? first_column_total(options) : totals[column[:name].to_s]
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
      column_name = column[:name].to_sym
      column_cache[column_name] = {} unless column_cache.has_key?(column_name)

      if column_cache[column_name].has_key?(value)
        result = column_cache[column_name][value]
      else
        result = column[:formatter].call(value, options.reverse_merge({:cell_type => cell_type, :column => column}))
        result ||= ''
        column_cache[column_name][value] = result
      end
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
      case data
      when Fixnum
        integer_with_delimiter(data, options)
      else
        data.to_s
      end
    end
  
    def table_has_totals?
      !totals.empty?
    end
  
    def initialise_columns(rows, model, options)
      options[:include] = options[:include].map(&:to_s) if options[:include]
      options[:exclude] = options[:exclude].map(&:to_s) if options[:exclude]
      add_calculated_columns_to_rows(rows, options)
      requested_columns = columns_from_row(rows.first)
      columns = requested_columns.inject([]) do |definitions, column|
        definitions << column_definition(column) if include_column?(column, options)
        definitions
      end
      columns.sort{|a, b| a[:order] <=> b[:order] }
    end

    # Return a hash of hashes
    # :sum => {:column_name_1 => value, :column_name_2 => value}
    def initialise_totalling(rows, columns)
      columns.inject({}) do |totals, column|
        case column[:total]
          when :sum
            totals[column[:name]] = rows.make_numeric(column[:name]).sum(column[:name])
          when :mean, :average, :avg
            totals[column[:name]] = rows.make_numeric(column[:name]).mean(column[:name])
          when :count
            totals[column[:name]] = rows.make_numeric(column[:name]).count(column[:name])
        end
        totals
      end  
    end
  
    def first_column_total(options)
      if rows.count > 1
        I18n.t(options[:total_many], :count => rows.count)
      else
        I18n.t(options[:total_one], :count => rows.count)
      end
    end
  
    def column_definition(column)
      @column_order += 1
      @default_formatter ||= procify(:default_formatter)
    
      css_class, formatter = get_column_formatter(column.to_s)
      column_order = klass.format_of(column)[:order] || @column_order
      totals = klass.format_of(column)[:total]
      return {
        :name       => column,
        :label      => klass.human_attribute_name(column),
        :formatter  => formatter || @default_formatter,
        :class      => css_class,
        :order      => column_order,
        :total      => totals
      }
    end
  
    def columns_from_row(row)
      row.attributes.inject([]) {|columns, (k, v)| columns << k.to_s }
    end
  
    def get_column_formatter(column)
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
          raise ArgumentError, "[html_tables] Total value must not be 0 for percentage_of" if match[1] =~ /percent/ && v.to_f == 0
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
end