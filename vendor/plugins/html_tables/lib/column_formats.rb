# Allow us to define the column formats to be used in to_table
# for AR result sets
module ColumnFormats
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module InstanceMethods

  end
  
  module ClassMethods
    def table_format(method, options)
      @attr_formats = (@attr_formats || default_formats).deep_merge({method.to_s => options})
    end
    
    def format_of(name)
      @attr_formats ||= default_formats
      @attr_formats[name] || {}
    end
    
  private
    # Default column formats used in to_table for active_record
    # result arrays
    #
    # Hash options are:
    # => :class => 'class_name' # used to add a CSS class to the <td> element
    # => :formatter => A symbol denoting a method or a proc to be used to 
    #    format the data element.  It will be passed the elemet only.
    #
    def default_formats
      attr_formats = {}
      columns.each do |column|
        attr_formats[column.name] = case column.type
        when :integer, :float
          {:class => :right, :formatter => :number_with_delimiter}
        when :text, :string
          {}
        when :date, :datetime
          {}
        else
          {}
        end
      end
      attr_formats
    end
  end

end
