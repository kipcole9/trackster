module Caerus
  module ThemeHelper
  
    def theme_css
      @theme_css ||= "#{Trackster::Config.theme_dir.without_slash}/#{current_theme}/theme.css"
    end
  
    def theme_branding
      @theme_branding ||= "#{current_theme_directory}/branding.html.rb"
    end

    def theme_brand_file
      @theme_brand_file ||= "#{current_theme_directory}/_branding.html.rb"
    end
  
    def theme_chart_config
      unless @chart_config
        @chart_config = YAML.load(File.read("#{current_theme_directory}/chart.yml")) rescue nil
      end
      @chart_config || {}
    end
  
    def theme_has_custom_branding?
      @theme_has_branding ||= File.exist?(theme_brand_file)
    end
  
    def theme_menu_bullet?
      @theme_menu_bullet ||= File.exist?(theme_menu_bullet_file)
    end
  
    def current_theme
      unless @current_theme
        if current_account
          @current_theme = current_account.theme
        end
        @current_theme = Trackster::Config.default_theme if @current_theme.blank?
      end
      @current_theme
    end

    def theme_menu_bullet_file
      @theme_menu_bullet_file ||= "#{current_theme_directory}/icons/menu_bullet.png"
    end
  
    def theme_menu_bullet_path
      @theme_bullet_path ||= "#{current_theme_path}/icons/menu_bullet.png"
    end
    
    def theme_favicon_path
      @theme_favicon_path ||= File.exist?("#{current_theme_directory}/favicon.ico") ? "#{current_theme_path}/favicon.ico" : "#{default_theme_path}/favicon.ico"
    end
  
    # Theme directory is the full path to the directory relative to the file system root
    def current_theme_directory
      @current_theme_directory ||= "#{Rails.root}/public#{Trackster::Config.theme_dir.without_slash}/#{current_theme}"
    end
  
    # Theme path is the web server relative path to the theme directory
    def current_theme_path
      @current_theme_path ||= "#{Trackster::Config.theme_dir.without_slash}/#{current_theme}"    
    end
    
    def default_theme_path
      @default_theme_path ||= "#{Trackster::Config.theme_dir.without_slash}/#{Trackster::Config.default_theme}"
    end 
  
  end
end