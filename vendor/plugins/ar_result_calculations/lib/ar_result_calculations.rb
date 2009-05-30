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
          return super() unless column && first && first.class.respond_to?(:descends_from_active_record?)
          column = column.to_sym unless column.is_a?(Symbol)
          inject( 0 ) { |sum, x| x[column].nil? ? sum : sum + x[column] }
        end
        
        def mean(column = nil)
          return super() unless column && first && first.class.respond_to?(:descends_from_active_record?)
          (length > 0) ? sum(column) / length : 0
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
        
        def make_numeric(column)
          return self unless column && first && first.class.respond_to?(:descends_from_active_record?)
          each do |row|
            next if row[column].is_a?(Fixnum) || row[column].is_a?(Float) || row[column].is_a?(Integer) || row[column].is_a?(Bignum)
            if row[column] =~ /[-+]?[0-9]+(\.[0-9]+)/
              row[column] = row[column].to_f
            else
              row[column] = row[column].to_i
            end
          end
          self
        end        
      end
      

      
      module ClassMethods
        # Courtesy of http://blog.internautdesign.com/2008/4/21/simple-linear-regression-best-fit
        class Array::LinearRegression
          attr_accessor :slope, :offset

          def initialize dx, dy=nil
            @size = dx.size
            dy,dx = dx,axis() unless dy  # make 2D if given 1D
            raise ArgumentError, "arguments not same length!" unless @size == dy.size
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
