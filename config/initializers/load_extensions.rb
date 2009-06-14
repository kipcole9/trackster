require 'flex_stuff'
require 'analytics/log_parser'
require 'analytics/web_analytics'
require 'with_scope'
require 'core_extensions'

# Small hack to let us play with
# proxy options in other named scopes
module ActiveRecord
  class Base
    def current_scoped_find=(scope) #:nodoc:
      scoped_methods.last[:find] = scope
    end
    
    def current_scoped_find
      scoped_methods.last[:find]
    end
  end
end

