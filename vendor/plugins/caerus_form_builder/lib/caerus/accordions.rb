module Caerus
  module Accordions
    ACCORDION               = 'accordion'
    ACCORDION_ITEM          = 'targ'
    ACCORDION_ITEM_HEADING  = 'trig'
    ACCORDION_ITEM_OPEN     = "#{ACCORDION_ITEM_HEADING} open"
    
    # accordion (concertina) formatting
    def accordion(options = {}, &block)
      default_options = { :class => ACCORDION }
      options = default_options.merge(options)
      @template.concat @template.content_tag(:div, @template.capture(&block), options)
    end

    def accordion_item(heading, options = {}, &block)
      default_h3_options = { :class => options.delete(:open) ? ACCORDION_ITEM_OPEN : ACCORDION_ITEM_HEADING}
      default_div_options = { :class => ACCORDION_ITEM }
      @template.concat @template.content_tag(:h3, formatted_accordion_item(heading), default_h3_options)
      @template.concat @template.content_tag(:div, @template.capture(&block), default_div_options.merge(options))    
    end

    # Items in an accordion - add a bullet if the theme defines one
    def nav(text)
      Trackster::Theme.menu_bullet? ? p("#{image_tag Trackster::Theme.menu_bullet_path} #{text}") : p(text)
    end
  
    # From a text string do
    # => Resolve an icon image
    # => Localize the text
    def formatted_accordion_item(heading)
      icon_file = "#{heading.downcase.gsub(' ','_')}.png"
      icon_path = "#{Trackster::Theme.current_theme_path}/icons/#{icon_file}"
      heading_text = I18n.t(heading, :default => heading)
      if File.exist?("#{Rails.root}/public#{icon_path}")
        "#{image_tag icon_path, :class => 'accordion_item_image'} #{heading_text}"
      else
       heading_text
      end
    end
  end

end
