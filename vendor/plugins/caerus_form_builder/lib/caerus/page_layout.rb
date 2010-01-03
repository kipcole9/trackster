module Caerus
  # Template handler to make it easy to define page layouts using the 
  # 960 Grid System ~ Core CSS. Learn more ~ http://960.gs/
  # The basic idea is that your CSS defines and supports a grid based layout.
  module PageLayout
  
    DOCTYPE = {
        :xhtml_strict => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
        :xhtml_trans  => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
    }

    TAGS      = [:div, :a, :img, :script, :meta]
    INDENT    = 2
  
    def doctype(type = DOCTYPE[:xhtml_strict])
      @doctype = store(type)
    end
  
    def javascripts(*args)
      store javascript_include_tag(*args)
    end
  
    def javascript_merged(*args)
      store javascript_include_merged(*args)
    end
  
    def stylesheets(*args)
      store stylesheet_link_tag(*args)
    end
  
    def stylesheet_merged(*args)
      store stylesheet_link_merged(*args)
    end
    
    def html(language = "en", &block)
      doctype unless @doctype
      with_tag(:html, :xmlns => "http://www.w3.org/1999/xhtml", :"xml:lang" => language, :lang => language) do
        store yield
      end
    end

    def head(options = {}, &block)
      @head = with_tag(:head) do
        if block_given?
          yield
        else
          stylesheets('application.css')
          javascripts(:defaults)
        end
      end
    end  
  
    # Options
    # :columns => n  (width of columns)
    # :prefix => 'container'; name of CSS class prefix
    def body(args = {}, &block)
      head unless @head
      default_options = {:columns => 12, :prefix => "container" }
      options = default_options.merge(args)
      with_tag(:body) do
        container(&block)
      end
    end

    def meta(args = {})
      arg_string = []
      args.each{|k, v| arg_string << "#{k.to_s}=\"#{v.to_s}\""}
      store "<meta #{arg_string.join(' ')} />"
    end

    def header_link(args = {})
      arg_string = []
      args.each{|k, v| arg_string << "#{k.to_s}=\"#{v.to_s}\""}
      store "<link #{arg_string.join(' ')} />"
    end  

    def container(args = {}, &block)
      default_options = {:columns => 12, :prefix => "container" }
      options = default_options.merge(args)
      with_tag(:div, :class => "#{options[:prefix]}_#{options[:columns]}", &block)
      clear
    end

    def column(args, &block)
      default_options = {:width => 3}
      options = default_options.merge(args)
      options[:class] = class_from_options(options)
      with_tag(:div, options, &block)
    end
  
    def clear(options = {})
      default_options = {:class => "clearfix"}
      with_tag(:div, default_options.merge(options)) do
        if block_given?
          yield
        else
          store "&nbsp;"
        end
      end
    end

    def toggle(text, options = {}, &block)
      default_options = {:only => {}, :except => {}, :initial => :show}
      toggle_id = "i#{Time.now().to_i}"
      store link_to(text, "#", :class => "toggle_handle", :rel => toggle_id)
      with_tag(:div, :id => toggle_id, &block)
    end
  
    def page(options = {}, &block)
      default_options = {:content => :page, :layout => '/layouts/application'}
      options = default_options.merge(options)
      keep(options[:content], &block)
      store render(:file => options[:layout])
    end

    def panel(title, args = {})
      default_options = {:class => ["box", args.delete(:class)].join(' ')}
      options = default_options.merge(args)
      include_flash_block = options.delete(:flash)
      errors_on = options.delete(:display_errors)
      with_tag(:div, options) do
        with_tag(:h2, :class => 'heading') do
          store link_to(title)
          with_tag(:div, :class => 'panel-links') do
            store link_to(t('edit'), options[:edit])
          end if options[:edit]
        end
        display_flash if include_flash_block
        display_errors(errors_on) if errors_on      
        yield
      end
    end
  
    def block(args = {}, &block)
      default_options = {:class => "block"}
      options = default_options.merge(args)
      with_tag(:div, options) do
        with_tag(:div, {}, &block)
      end
    end
  
    def title(t)
      with_tag(:title) { store t }
    end

    def store(content)
      return unless content
      @level ||= 0
      spacing = " " * (@level * INDENT)
      concat(spacing + content + "\n")
      content
    end
    alias :s :store
  
    def include(*args)
      store render(*args)
    end

    def keep(name, text = '')
      ivar = "@content_for_#{name}"
      temp_output_buffer = @output_buffer
      @output_buffer = ""
      block_given? ? yield : @output_buffer = text
      instance_variable_set(ivar, "#{instance_variable_get(ivar)}#{@output_buffer}")
      @output_buffer = temp_output_buffer
      nil
    end
  
    def p(text, options = {})
      with_tag(:p, options) do
        store text
      end
      nil
    end
  
    def link(*args)
      store link_to(*args)
      nil
    end
  
    def img(*args)
      store image_tag(*args)
      nil
    end

    def search(title = t('search'), options = {})
      default_options = {:class => 'search'}
      options   = default_options.merge(options)
      url       = options.delete(:url)
      replace   = options.delete(:replace)
      callback  = options.delete(:callback)
      var       = options[:id]
      script_options = ["url: '#{url}'", "replace: '#{replace}'"]
      script_options << ["callback: '#{callback}'"] if callback
      search_id = "#{options[:id]}Field"
      with_tag(:form, options) do
        store "<label>#{title}:</label>"
        store "<input class='search text' name='#{search_id}' type='text' id='#{search_id}' AutoComplete='off' />"
      end
      javascript "var #{var} = new LiveSearch('#{search_id}', {#{script_options.join(',')}})" if url && replace
    end
  
    def method_missing(method, *args, &block)
      if [:h4, :h3, :h2, :h1].include?(method)
        return nil if args.last.blank?
        content = args[0]
        options = args[1] || {}
        with_tag(method, options) do
          store content
        end
      else
        super
      end
    end
  
  private
    def with_tag(tag, options = {}, &block)
      tag_start = []
      tag_start << "<#{tag.to_s}"
      options.each{|k, v| tag_start << "#{k.to_s}=#{quote(v.to_s)}"}
      store tag_start.join(' ') + '>'
      increment_level
      yield if block_given?
      decrement_level
      store("</#{tag.to_s}>")
      ''
    end

    def class_from_options(options)
      klass = []
      klass << "grid_" + options.delete(:width).to_s if options[:width]
      klass << ("prefix_" + options.delete(:before).to_s) if options[:before]
      klass << ("suffix_" + options.delete(:after).to_s) if options[:after]
      klass << options[:class] if options[:class]
      klass.join(' ')
    end
  
    def increment_level
      @level += 1
    end
  
    def decrement_level
      @level -= 1
      @level = 0 if @level < 0
    end
  
    def quote(s)
      '"' + s + '"'
    end

  end  
end