# Methods added to this helper will be available to all templates in the application.
module Caerus
  module FormsHelper
    include Caerus::PageLayout
    include Caerus::MenuMaker
    include Caerus::Tabs
    include Caerus::Accordions

    # Fieldset used to wrap form sections
    def fieldset(legend = '', options = {}, &block)
      default_options = {}
      legend    = @template.content_tag(:legend, legend + buttons_from(options)) unless legend.blank?
      optional  = optional_field_from(options)
      content   = @template.capture(&block)
      fieldset  = @template.content_tag(:fieldset, legend + content, default_options.merge(options))    
      @template.concat @template.content_tag(:div, "#{optional}#{fieldset}")
    end
  
    # Marks up a form title
    def heading(title, options = {})
      suffix = options[:append] || ''
      heading_type = options[:type] || :h2
      @template.content_tag(heading_type, tt(title) + suffix)
    end
  
    # defines a form section.  Sections include a title (heading).  By default the
    # section is continuous on a page.  Adding an optional position parameter
    # will include markup to arrange "left" and "right" sections.  CSS is used
    # to do the actual layout.
    def section(options = {}, &block)
      default_options = {:class => :section_left}
      default_options[:class] = :section_right if options[:position] == :right
      options[:class] = "#{default_options[:class].to_s} section_width_#{options.delete(:width)}" if options[:width]
      section_heading = options.delete(:title)
      heading_tag = ''
      heading_tag = @template.content_tag(:p, section_heading, :class => :title) if section_heading
      @template.concat @template.content_tag(:div,
        heading_tag + @template.capture(&block), 
        default_options.merge(options)
      )
    end

    # Tries a translation, but the default is the supplied string
    def tt(title)
      I18n.t(title, :default => title)
    end
  
    # Render the flash
    def display_flash
      flash.each do |key, message|
        with_tag(:div, :class => "flash_#{key}") do
          with_tag(:p) do
            store image_tag("/images/icons/flash_#{key}.png")
            store message
          end
        end
      end
    end
  
    # Display validation and active record errors
    def display_errors(model)
      store error_messages_for(model.to_s, :class => "box errorExplanation", :id => "#{model.to_s}_errors")
    end
  
    # Get a list of time zones that are in the same UTC offset
    # as the supplied zone.  Takes a TimeZone instance or a number
    def time_zones_like(time_zone)
      offset = time_zone.is_a?(ActiveSupport::TimeZone) ? time_zone.utc_offset : time_zone
      ActiveSupport::TimeZone.all.select { |z| z.utc_offset == offset }
    end
    
    # Creates a Submit button and a Cancel link
    # wrapped in a div
    def submit_combo(options = {})
      back = options.delete(:back) || session[:return_to] || root_url
      text = options.delete(:text) || :save
      @template.concat @template.content_tag(:div, 
        link_to(I18n.t(:cancel), back) + " #{I18n.t(:or)} " + submit_tag(I18n.t(text), options), 
        :class => "submit_button"
      )
    end
  
    def sidebar(content)
      @sidebars ||= []
      @sidebars << content
    end
  
    def render_sidebars
      @sidebars.each {|s| @template.concat(render(:partial => s))} if @sidebars
    end
  
    def banner
      @banner
    end
  
    def banner_exists?
      @banner
    end
  
    def edit_action?
      params[:action] == 'edit'
    end
  
    def remove_link_unless_new_record(fields)
      out = ''
      out << fields.hidden_field(:_destroy)  unless fields.object.new_record?
      out << link_to("remove", "##{fields.object.class.name.underscore}", :class => 'remove')
      out
    end
 
    # This method demonstrates the use of the :child_index option to render a
    # form partial for, for instance, client side addition of new nested
    # records.
    #
    # This specific example creates a link which uses javascript to add a new
    # form partial to the DOM.
    #
    #   <% form_for @project do |project_form| -%>
    #     <div id="tasks">
    #       <% project_form.fields_for :tasks do |task_form| %>
    #         <%= render :partial => 'task', :locals => { :f => task_form } %>
    #       <% end %>
    #     </div>
    #   <% end -%>
 
 
    def generate_html(form_builder, method, options = {})
      options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
      options[:partial] ||= method.to_s.singularize
      options[:form_builder_local] ||= options[:partial].to_sym  
 
      form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
        render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
      end
    end
 
    def generate_template(form_builder, method, options = {})
      escape_javascript generate_html(form_builder, method, options = {})
    end
  
    def render_form(form_builder, partial, options = {})
      options[:form_builder_local] ||= partial.to_sym
      @template.concat render(:partial => partial, :locals => {options[:form_builder_local] => form_builder})
    end
  
    def javascript(content)
      @template.concat @template.content_tag(:script, content, :type => 'text/javascript')
    end
  
    def associated_template_for_new(form_builder, association)
      template = generate_template(form_builder, association)
      "var #{association.to_s.singularize}='#{template}';"
    end
  
    def form_template_for(partial)
      form = render :partial => partial.to_s
      "var #{partial} = '#{escape_javascript form}';"
    end
  
    def buttons(buttons)
      store buttons_from(:buttons => buttons)
    end
    
    
    def capture(&block)
      temp_output_buffer = @output_buffer
      @output_buffer = ""
      capture_response = yield
      capture_response = @output_buffer if capture_response.blank?
      @output_buffer = temp_output_buffer
      capture_response
    end

    def concat(text)
      @output_buffer += text unless text.blank?
    end    
  
  private
    def optional_field_from(options)
      if optional = options.delete(:optional)
        message   = tt('show_all_fields')
        check_box = check_box_tag(random_id, "1", (optional == :show))
        @template.content_tag(:span, "#{message}#{check_box}", :class => 'showOptional')
      else
        ''
      end
    end
  
    def random_id
      "i#{Time.now.to_i}"
    end
  
    def buttons_from(options)
      buttons = options.delete(:buttons)
      return '' unless buttons
      button_images = []
      buttons = [buttons.to_sym] unless buttons.is_a?(Array)
      buttons.each do |button|
        case button
        when :add
          button_images << "<img src='/images/icons/add.png' class='add' />"
        when :delete
          button_images << "<img src='/images/icons/delete.png' class='delete' />"
        end
      end
      button_images.join(' ')
    end

  end
end