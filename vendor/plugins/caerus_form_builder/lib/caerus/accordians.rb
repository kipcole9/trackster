module Caerus
  module Accordians
    ACCORDIAN               = 'concertina'
    ACCORDIAN_ITEM          = 'targ'
    ACCORDIAN_ITEM_HEADING  = 'trig'
    ACCORDIAN_ITEM_OPEN     = "#{ACCORDIAN_ITEM_HEADING} open"
    
    # Accordian (concertina) formatting
    def accordian(id = 'accordian', options = {}, &block)
      default_options = { :class => ACCORDIAN }
      options = default_options.merge(options).merge(:id => id)
      @template.concat @template.content_tag(:div, @template.capture(&block), options)
    end

    def accordian_item(heading, options = {}, &block)
      default_h3_options = { :class => options.delete(:open) ? ACCORDIAN_ITEM_OPEN : ACCORDIAN_ITEM_HEADING}
      default_div_options = { :class => ACCORDIAN_ITEM }
      @template.concat @template.content_tag(:h3, formatted_accordian_item(heading), default_h3_options)
      @template.concat @template.content_tag(:div, @template.capture(&block), default_div_options.merge(options))    
    end

    # Items in an accordian - add a bullet if the theme defines one
    def nav(text)
      theme_menu_bullet? ? p("#{image_tag theme_menu_bullet_path} #{text}") : p(text)
    end
  
    # From a text string do
    # => Resolve an icon image
    # => Localize the text
    def formatted_accordian_item(heading)
      icon_file = "#{heading.downcase.gsub(' ','_')}.png"
      icon_path = "#{Trackster::Config.theme_dir.without_slash}/#{current_theme}/icons/#{icon_file}"
      heading_text = I18n.t(heading, :default => heading)
      if File.exist?("#{Rails.root}/public#{icon_path}")
        "#{image_tag icon_path} #{heading_text}"
      else
       heading_text
      end
    end
  end

end
