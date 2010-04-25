module Caerus
  module Tabs
    # Class names that are managed by javascript
    TAB                     = "tab"

    # JQuery UI Tabs formation
    # http://docs.jquery.com/UI/Tabs
    #
    # <div id="tabs">
    #    <ul>
    #        <li><a href="#fragment-1"><span>One</span></a></li>
    #        <li><a href="#fragment-2"><span>Two</span></a></li>
    #        <li><a href="#fragment-3"><span>Three</span></a></li>
    #    </ul>
    #    <div id="fragment-1">
    #        <p>First tab is active by default:</p>
    #        <pre><code>$('#example').tabs();</code></pre>
    #    </div>
    #    <div id="fragment-2">
    #        Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.
    #        Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.
    #    </div>
    #    <div id="fragment-3">
    #        Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.
    #        Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.
    #        Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.
    #    </div>
    # </div>
    
    class Tab
      attr_accessor   :id, :options, :counter, :items, :template
      
      def initialize(id, options = {})
        @id           = id
        @items        = []
        @template     = options.delete(:template)
        @options      = options
        @counter      = 0
      end
      
      def to_html
        content_tag(:div, tab_item_list, options.reverse_merge(:class => TAB))
      end
      
      def next_item_id
        "#{id}_#{next_counter}"
      end
      
      def next_counter
        @counter += 1
      end
      
      def <<(item)
        self.items << item
      end
    
    protected
      def tab_item_list
        "#{tab_item_headers}\n#{tab_item_content}"
      end
      
      def tab_item_headers
        content_tag(:ul, 
          items.inject("") do |headers, item|
            headers << "#{item.header_to_html}\n"
          end
        )
      end
      
      def tab_item_content
        items.inject("") do |content, item|
          content << "#{item.content_to_html}\n"
        end
      
      end
      
    private
      def content_tag(*args)
        template.content_tag(*args)
      end
    end
    
    class TabItem
      attr_accessor   :heading, :options, :content, :href
      
      def initialize(heading, options, content)
        @heading  = heading
        @options  = options
        @href     = "##{options[:id]}"
        @content  = content
        @template = options.delete(:template)
      end
      
      def header_to_html
        content_tag(:li,
          link_to(content_tag(:span, heading), @href)
        )
      end
      
      def content_to_html
        content_tag(:div, content, options)
      end
      
    private
      def content_tag(*args)
        @template.content_tag(*args)
      end
      
      def link_to(*args)
        @template.link_to(*args)
      end
    end
    
    # Start of tab form processor
    def tab(id, options = {}, &block)
      @tab_content ||= []
      default_options = {:id => id, :template => @template}
      options = default_options.merge(options)
      @current_tab = @tab_content.push(Tab.new(id, options)).last
      @template.capture(&block) # builds tab content; capture results discarded
      @template.concat @current_tab.to_html
      @tab_content.pop
      @current_tab = @tab_content.last
    end

    def tab_item(heading, options = {}, &block)
      @current_tab << TabItem.new(heading, options.reverse_merge(:id => @current_tab.next_item_id, :template => @template), @template.capture(&block))
    end
  end
end