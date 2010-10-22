module Trackster
  class Theme
    def css
      @theme_css ||= "#{current_theme_path}/theme.css"
    end

    def print_css
      @theme_print_css ||= "#{current_theme_path}/print.css"
    end

    def branding(print)
      if print
        @theme_branding ||= "#{current_theme_directory}/print_branding.html.rb"
      else
        @theme_branding ||= "#{current_theme_directory}/branding.html.rb"
      end
    end

    def brand_file
      @theme_brand_file ||= "#{current_theme_directory}/_branding.html.rb"
    end

    def chart_config
      unless @chart_config
        @chart_config = YAML.load(File.read("#{current_theme_directory}/chart.yml")) rescue nil
      end
      @chart_config || {}
    end

    def has_custom_branding?
      @theme_has_branding ||= File.exist?(brand_file)
    end

    def menu_bullet?
      @theme_menu_bullet ||= File.exist?(menu_bullet_file)
    end

    def current_theme
      unless @current_theme
        if Account.current_account
          @current_theme = Account.current_account.theme
        end
        @current_theme = Trackster::Config.default_theme if @current_theme.blank?
      end
      @current_theme
    end

    def menu_bullet_file
      @theme_menu_bullet_file ||= "#{current_theme_directory}/icons/menu_bullet.png"
    end

    def menu_bullet_path
      @theme_bullet_path ||= "#{current_theme_path}/icons/menu_bullet.png"
    end

    def favicon_path
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
    
    def self.method_missing(method, *args)
      current_theme = Thread.current[:theme] || self.new
      current_theme.send(method, *args)
    end
  end
end