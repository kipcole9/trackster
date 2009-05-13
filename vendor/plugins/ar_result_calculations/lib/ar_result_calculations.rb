module ActiveRecord
  module Results
    module Calculations
      def self.included(base)
        base.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end

      module InstanceMethods
        def sum(column = nil)
          return super unless column && first && first.class.respond_to?(:descends_from_active_record?)
          column = column.to_sym unless column.is_a?(Symbol)
          inject( 0 ) { |sum, x| x[column].nil? ? sum : sum + x[column] }
        end
        
        def mean(column = nil)
          return super unless column && first && first.class.respond_to?(:descends_from_active_record?)
          (size > 0) ? sum(column).to_f / size : 0
        end
        alias :avg  :mean
        alias :average  :mean
        
        # Count the number of non-nil rows
        def count(column = nil)
          return super unless column && first && first.class.respond_to?(:descends_from_active_record?)
          column = column.to_sym unless column.is_a?(Symbol)          
          inject( 0 ) { |sum, x| x[column].nil? ? sum : sum + 1 }
        end
      end

      module ClassMethods

      end
    end
  end
end
