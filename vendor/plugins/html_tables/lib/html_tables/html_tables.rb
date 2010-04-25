# Adds method to Array to allow output of html tables - only works
# if the array is an ActiveRecord result set (see TableFormatter object)
module HtmlTables
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    def to_table(options = {})
      default_options = {}
      merged_options = default_options.merge(options)
      @formatter = HtmlTables::TableFormatter.new(self, merged_options)
      @formatter.to_html
    end
  end
  
  module ClassMethods

  end
end
