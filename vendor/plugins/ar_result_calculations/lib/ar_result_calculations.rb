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
          inject( 0 ) { |sum, x| x[column].nil? ? sum : sum + numeric_value(x[column]) }
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
        
        def max(column = nil)
          return super() unless column && first && first.class.respond_to?(:descends_from_active_record?)
          column = column.to_sym unless column.is_a?(Symbol)   
          self.map(&column).max
        end
        alias :maximum :max
        
        def min(column = nil)
          return super() unless column && first && first.class.respond_to?(:descends_from_active_record?)
          column = column.to_sym unless column.is_a?(Symbol)   
          self.map(&column).min
        end
        alias :minimum :min
        
        def regression(column = nil)
          if column && first && first.class.respond_to?(:descends_from_active_record?)
            column = column.to_sym unless column.is_a?(Symbol)   
            series = inject([]) { |array, x| array << x[column] }
          end
          Array::LinearRegression.new(series || self).fit
        end
        
      end
      
      def numeric_value(value)
        return value if value.is_a?(Fixnum) || value.is_a?(Float) || value.is_a?(Integer) || value.is_a?(Bignum)
        value.to_i
      end
      
      module ClassMethods
        # Courtesy of http://blog.internautdesign.com/2008/4/21/simple-linear-regression-best-fit
        class Array::LinearRegression
          attr_accessor :slope, :offset

          def initialize dx, dy=nil
            @size = dx.size
            dy,dx = dx,axis() unless dy  # make 2D if given 1D
            raise "arguments not same length!" unless @size == dy.size
            sxx = sxy = sx = sy = 0
            dx.zip(dy).each do |x,y|
              sxy += x*y
              sxx += x*x
              sx  += x
              sy  += y
            end
            @slope = ( @size * sxy - sx*sy ) / ( @size * sxx - sx * sx )
            @offset = (sy - @slope*sx) / @size
          end

          def fit
            return axis.map{|data| predict(data) }
          end

          def predict( x )
            y = @slope * x + @offset
          end

          def axis
            (0...@size).to_a
          end
        end

      end
    end
  end
end
