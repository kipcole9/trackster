class CaerusFormBuilder < ActionView::Helpers::FormBuilder
  DEFAULT_SUFFIX  = ":"
  include ActionView::Helpers::FormTagHelper
  
  # Default class definitions
  FORM_FIELD      = "formField"
  LABEL           = "formLabel"
  FORM_TEXT       = "formText"
 
  # Standard input fields; wrapped in a standard wrapper and with
  # my usual defaults
  def text_field(method, options = {})
    default_options = {}
    field_options = {:before => options.delete(:before), :after => options.delete(:after), 
                     :autocomplete => options.delete(:autocomplete), 
                     :optional => options.delete(:optional), :no_prompt => options.delete(:no_prompt)}
    with_field(method, field_options) do
      super(method, default_options.merge(options))
    end
  end
  
  def password_field(method, options = {})
    default_options = {:size => 30}
    with_field(method) do
      super(method, default_options.merge(options))
    end
  end
    
  def hidden_field(method, options = {})
    default_options = {}
    @template.concat super
  end
     
  def text_area(method, options = {})
    default_options = {:size => "50x5"}
    with_field(method, options) do
      super(method, default_options.merge(options))
    end 
  end

  def file_field(method, options = {})
    default_options = {:size => 50}
    with_field(method) do
      super(method, default_options.merge(options))
    end   
  end
   
  def select(method, choices, options = {}, html_options = {})
    default_html_options = {}
    with_field(method, options) do
      super(method, choices, options, default_html_options.merge(html_options))
    end
  end
  
  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    default_html_options = {}
    with_field(method, options) do
      super(method, collection, value_method, text_method, options = {}, default_html_options.merge(html_options))
    end
  end
   
  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    default_options = {:label_class => "checkbox", :suffix => '?'}
    with_field(method, default_options.merge(options)) do
      super(method, options, checked_value, unchecked_value)
    end
  end
    
  def country_select(method, priority_countries = nil, options = {}, html_options = {})
    default_html_options = {}
    with_field(method) do
      super(method, priority_countries, options, default_html_options.merge(options))
    end
  end
  
  def datetime_select(method, options = {}, html_options = {})
    default_html_options = {:class => 'datetime'}
    default_options = {:wrap_in_div => true}
    with_field(method, default_options.merge(options)) do
      super(method, options, default_html_options.merge(options))
    end
  end
 
  def date_select(method, options = {}, html_options = {})   
    default_html_options = {:class => :date}
    with_field(method) do
      @template.content_tag(:div, super(method, options, default_html_options.merge(options)), :class => :date)
    end
  end
  
  def time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
    default_html_options = {}
    with_field(method) do
      super(method, priority_zones, options, default_html_options.merge(html_options))
    end
  end
  
  def buttons(*args)
    if args.include?(:delete)
      hidden_field('_delete', :class => "_delete")
    end
    @template.buttons(args)
  end
    
private

  # Standard field definitions
  def with_field(method, args = {}, &block)
    default_options = {:before => '', :after => '', :autocomplete => false, 
                       :label_class => :field_label, :optional => false,
                       :field_class => :field, :wrap_in_div => false  }
    options = default_options.merge(args)
    field_definition = @template.capture(&block)
    field_definition = @template.content_tag(:div, field_definition) if options.delete(:wrap_in_div)
    field_id = field_definition.match(/id=\"(.+?)\"/)[1]
    before = options.delete(:before)
    after = options.delete(:after)
    prompt = get_prompt(object_name, method, options)
    label = get_label(field_id, method, options)
    field_message = get_field_message(field_id)
    field_options = field_options_from(options)
    field_content = "#{label}#{field_message}#{before}#{field_definition}#{after}#{prompt}"
    content = @template.content_tag(:div, field_content, field_options)
    add_autocompleter(method, field_id, options)
    ruby_template? ? @template.concat(content + "\n") : content
  end
  
  def field_options_from(options)
    field_options = {}
    field_options[:class] = options.delete(:field_class).to_s
    options.delete(:label_class)
    if options.delete(:optional)
      field_options[:class] += " optional"
      field_options[:style] = "display:none"
    end
    field_options
  end
  
  def ruby_template?
    File.extname(@template.template.filename) == ".rb"
  end
  
  def spinner_images(object_name, method)
    "<img id='#{object_name}_#{method}_spinner' src='/images/spinners/arrows.gif' class='spinner' style='display:none' />" + \
    "<img id='#{object_name}_#{method}_cross' src='/images/icons/cross.png' class='spinner' style='display:none' />" + \
    "<img id='#{object_name}_#{method}_tick' src='/images/icons/tick.png' class='spinner' style='display:none' />"
  end

  def get_field_message(field_id)
    @template.content_tag(:span, '', :id => "#{field_id}_message", :class => 'field_message')
  end
  
  def get_label(field_id, method, options)
    return '' if options.delete(:no_label)
    label_options = {}
    label_options[:class] = options.delete(:label_class) if options[:label_class]
    label_options[:for] = field_id
    @template.content_tag(:label, format_label(method, options), label_options)
  end
  
  def format_label(label, options = {})
    label = object.class.human_attribute_name(label.to_s) + (options[:suffix] || DEFAULT_SUFFIX)
  end
  
  def get_prompt(table, column, options)
    if options.delete(:no_prompt)
      ''
    else
      prompt = I18n.translate("column_descriptions.#{object_name}.#{column}", :default => "__none")
      prompt = I18n.translate("column_descriptions.#{column}", :default => "") if prompt == "__none"
      prompt.blank? ? '' : @template.content_tag(:p, prompt, :class => "prompt")
    end
  end
  
  def add_autocompleter(method, field_id, options)
    if options.delete(:autocomplete)
      controller = method.to_s.split('_').first.pluralize
      autocomplete_js = "var #{field_id} = new AutoComplete('#{field_id}', { json: true, script:'/#{controller}/autocomplete.json?' });\n"
      if field_id =~ /NEW_RECORD/
        @template.javascript(autocomplete_js) 
      else
        @template.content_for :javascript, autocomplete_js
      end
    end
  end
end


