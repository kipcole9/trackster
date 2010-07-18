module Analytics
  class System
    attr_accessor :browscap, :device_atlas, :user_agent
  
    class MobileDevice
      require 'json'
      def initialize(file = "#{File.dirname(__FILE__)}/../../data/device_atlas.json")
        @device_atlas = DeviceAtlas.new
        @tree = @device_atlas.getTreeFromFile(file)
        @cached_entries = {}
      end
    
      def from_user_agent(user_agent)
        device = nil
        return nil if user_agent.blank?
        return device if device = @cached_entries[user_agent]
        device = @device_atlas.getProperties(@tree, user_agent)
        @cached_entries[user_agent] = device if device['model']
        device
      end
    end
  
    def initialize(user_agent)
      @@browscap_proxy  = Browscap.new unless defined?(@@browscap_proxy)
      @@device_proxy    = MobileDevice.new unless defined?(@@device_proxy)
      
      @user_agent       = user_agent
      @browscap         = @@browscap_proxy.query(@user_agent)
      @device_atlas     = @@device_proxy.from_user_agent(@user_agent)
      transform_platform_info!
    end

    def browser
      @browser || browscap.try(:browser)
    end
    
    def browser_version
      @browser_version || browscap.try(:version)
    end
    
    # TODO - Map the platform detection code from system_info.rb
    def os_name
      @os_name || browscap.try(:platform)
    end
    
    def os_version
      @os_version
    end

    def device
      @device_type || device_atlas.try(:[], 'model')
    end
    
    def device_vendor
      @device_vendor || device_atlas.try(:[], 'vendor')
    end
    
    def banned?
      browscap.try(:is_banned)
    end
    
    def crawler?
      browscap.try(:crawler)
    end
    
    def mobile_device?
      browscap.try(:is_mobile_device) || device_atlas.try(:[], 'mobileDevice') == 1
    end
    
  private
    # We want to use Browscap and DeviceAtlas as is since they are updated
    # frequently.  However the coding of some parameters isn't as friendly 
    # as we like.  So we add this transformation layer.
    def transform_platform_info!
      return unless browscap
      if browscap.platform =~ /Win(.*)/ || (browscap.platform == 'unknown' && user_agent =~ /Windows (NT)/)
        @os_name = "Windows"
        @os_version = $1
        @device_type = "Windows PC"       
      elsif browscap.platform =~ /MacOSX/ || (browscap.platform == 'unknown' && user_agent =~ /Mac OS X/)
        @os_name = "Mac OS X"
        @os_version = user_agent.match(/Mac OS X ([0-9_\.]+);/).try(:[], 1)
        @device_type = "Macintosh"
        @device_vendor = "Apple"
      elsif browscap.platform =~ /iPhone OSX/
        @os_name = "iPhone OS"
        @os_version = user_agent.match(/iPhone OS ([0-9_]+) /).try(:[], 1)
      elsif browscap.platform =~ /Linux/
        @device_type = "Linux PC"
      elsif browscap.platform =~ /SymbianOS/
        @os_name = "Symbian OS"
        @os_version = user_agent.match(/SymbianOS\/([0-9\.]+) /).try(:[], 1)
      elsif browscap.browser =~ /Chrome 4/
        @browser = "Chrome"
      elsif browscap.browser == "BlackBerry"
        @os_name = "BlackBerry OS"
      elsif browscap.platform =~ /Android/
        @os_version = user_agent.match(/Android ([0-9\.]+)/).try(:[], 1)
      elsif browscap.platform =~ /Wii/
        @device_type = "Wii"
        @device_vendor = "Nintendo"
      elsif browscap.browser == "Windows Media Player"
        @os_name = "Windows"
        @device_type = "Windows PC"
      elsif @os_name == "iPad"
        @os_name = "iPhone OS"
        @device_vendor = "Apple"
        @device_type = "iPad"
        @os_version = user_agent.match(/CPU OS ([0-9_])/).try(:[], 1)
      end
    end
  end
end