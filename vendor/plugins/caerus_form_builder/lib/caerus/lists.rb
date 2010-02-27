module Caerus
  module Lists
    LIST_CLASS        = "list"
    LIST_MEMBER_CLASS = "listMember"
    LIST_ITEM_CLASS   = "listItem"
    ICONS_DIR         = Trackster::Config.icons_directory
    
    # Render a collection is a standard list format 
    # relies on css classes and javascript for behavior
    def render_list(collection, options)
      return if collection.nil? || collection.empty?
      raise ArgumentError, "[render_list] Options must include :partial: #{options.inspect}" unless partial = options.delete(:partial)
      klass = collection.first.class.name.downcase
      list_id = "#{klass}List"
      with_tag(:ul, :id => list_id, :class => LIST_CLASS) do
        collection.each {|item| render_list_member(item, partial, options) }
      end
    end
    
  protected  
  
    # Render each member of a list.  This creates a wrapper <li>
    # around each item
    def render_list_member(item, partial, options)
      with_tag(:li, :class => LIST_MEMBER_CLASS, :id => list_member(item)) do
        render_list_item(item, partial, options)
      end
    end

    # Render each item in the list by calling the supplied partial
    # The accepts option defines a set of classes that later can be used with
    # drag and drop
    #
    # TODO Need to do the drag and drop JS
    def render_list_item(item, partial, options)
      classes = [LIST_ITEM_CLASS, classes_from_accepts(options)].flatten.compact.join(' ')
      with_tag(:div, :class => classes, :id => list_item(item)) do
        store render(:partial => partial, :locals => {item.class.name.downcase.to_sym => item, :options => options})
        render_buttons(item, options.delete(:buttons))
      end
    end
    
  private   
    def render_buttons(item, options)
      klass = item.class.name.downcase
      with_tag(:div, :class => :buttons, :style => "display:none") do
        store link_to(image_tag('/images/icons/delete.png', :class => :deleteListItem), button_path(item, :delete), 
              :method => :delete, :confirm => t(".delete_#{klass}", :property => item.name),
              :remote => :true) if can? :delete, item
        store link_to(image_tag('/images/icons/add.png', :class => :addListItem), button_path(item, :new)) if can? :create, item
        store link_to(image_tag('/images/icons/pencil.png', :class => :editListItem), button_path(item, :edit)) if can? :update, item
      end
    end
    
    def button_path(item, button)
      klass = item.class.name.downcase
      case button
      when :delete
        send("#{klass}_path", item)
      when :new
        send("new_#{klass}_path")
      when :edit
        send("edit_#{klass}_path", item)
      end
    end
    
    def classes_from_accepts(options)
      return [] unless accepts = options[:accepts]
      accepts = [accepts] unless accepts.respond_to?(:each) 
      accepts.inject([]) {|classes, accept| classes << "accept_#{accept}" }  
    end

    def list_member(object)
      return unless object
      klass = object.class.name.downcase    
      "#{klass}_listMember_#{object.id}"
    end
  
    def list_item(object)
      return unless object
      klass = object.class.name.downcase
      "#{klass}_listItem_#{object.id}"
    end
  
    #def element_from(object)
    #  "#{object.class.name.downcase}_#{object.id}"
    #end
  end
end