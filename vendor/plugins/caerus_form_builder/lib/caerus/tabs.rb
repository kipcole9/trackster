module Caerus
  module Tabs
    # Class names that are managed by javascript
    TAB                     = "tab"
    TAB_ITEM                = "tabItem"

    # Tab creation methods, using the tabulator.js script from
    # http://www.cyber-sandbox.com/
    # Markup should look like:
    #
    #<dl id="some_id">
    #  <dt>Tab heading 1</dt>
    #  <dd>Contents of tab 1</dd>
    #  <dt>Tab heading 2</dt>
    #  <dd>Contens of tab 2</dd>
    #  <dt>Tab heading 3</dt>
    #  <dd>Contents of tab 3</dd>
    #</dl>
    # 
    # CSS provides the layout.
    # 
    def tab(id, options = {}, &block)
      default_options = { :class => TAB }
      options = default_options.merge(options).merge(:id => id)
      @template.concat @template.content_tag(:dl, @template.capture(&block), options)
    end

    def tab_item(heading, options = {}, &block)
      default_dd_options = { :class => TAB_ITEM }
      default_dt_options = {}
      @template.concat @template.content_tag(:dt, heading, default_dd_options)
      @template.concat @template.content_tag(:dd, @template.capture(&block), default_dd_options.merge(options))    
    end
  end
end