require 'flex_stuff'
require 'log_parser'
require 'web_analytics'
require 'page_layout'
require 'with_scope'

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

