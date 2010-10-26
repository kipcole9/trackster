# Adds method to ActiveRecord to support some chart
# transformations
module Charting
  module Transforms
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
        const_set(:DEFAULT_PIVOT_COLUMNS, {
          :attribute => :attribute, :value => :value
        })
      end
    end
  
    module InstanceMethods
      # Takes one row and returns an array of objects of the same class
      # where columns are pivoted to become rows.  The new rows are of the 
      # same class as the current instance
      #
      # Arguments
      #
      #   The columns that become the row/column pairs in the result array.
      #   An empty list means pivot all attributes.
      #
      # Options
      #
      #   Specify the optional column names for the result array.  The defaults
      #   are: 
      #       :category => :category 
      #       :value => value
      def pivot(*args)
        options = (args.last.is_a?(Hash) ? args.pop : {}).merge(self.class.const_get(:DEFAULT_PIVOT_COLUMNS))
        args.flatten!
        attributes = args.size > 0 ? args : self.attributes.map(&:first)
        klass = self.class
        return attributes.inject([]) do |rows, arg|
          row = klass.new
          row[options[:attribute]]  = arg.to_s
          row[options[:value]]      = self[arg].to_i
          rows << row
          rows
        end
      end
    end
  
    module ClassMethods

    end
  end
end