module Analytics
  class SystemInfo
    attr_accessor :browscap, :device
  
    class MobileDevice
      def initialize(file = "#{Rails.root}/lib/analytics/device_atlas.json")
        require 'json'
        @device_atlas = DeviceAtlas.new
        @tree = @device_atlas.getTreeFromFile(file)
        @cached_entries = {}
      end
    
      def from_user_agent(user_agent)
        device = {}
        return device if device = @cached_entries[user_agent]
        device = @device_atlas.getProperties(@tree, user_agent)
        if device['model']
          @cached_entries[user_agent] = device
        end
        device
      end
    end
  
    def initialize
      @browscap = Browscap.new
      @device = MobileDevice.new
    end
  
    def info!(row)
      platform_info!(row)
      device_info!(row)
      transform_platform_info!(row)
    end
  
  protected
  
    def platform_info!(row)
      if agent = browscap.query(row[:user_agent])
        row[:browser] = agent.browser
        row[:browser_version] = agent.version
        row[:os_name] = agent.platform
        row[:mobile_device] ||= agent.is_mobile_device    
      end
    end
  
    def device_info!(row)
      item = device.from_user_agent(row[:user_agent])
      if item['model']
        row[:device] = item['model']
        row[:device_vendor] = item['vendor']
        row[:mobile_device] ||= item['mobileDevice']
      end
    end
  
    # We want to use Browscap and DeviceAtlas as is since they are updated
    # frequently.  However the coding of some parameters isn't as friendly 
    # as we like.  So we add this transformation layer.
    def transform_platform_info!(row)
      if row[:os_name] =~ /Win(.*)/
        row[:os_name] = "Windows"
        row[:os_version] = $1
        row[:device] = "Windows PC"
      elsif row[:os_name] =~ /MacOSX/
        row[:os_name] = "Mac OS X"
        row[:os_version] = row[:user_agent].match(/Mac OS X ([0-9_\.]+);/).try(:[], 1)
        row[:device] = "Macintosh"
        row[:device_vendor] = "Apple"
      elsif row[:os_name] =~ /iPhone OSX/
        row[:os_name] = "iPhone OS"
        row[:os_version] = row[:user_agent].match(/iPhone OS ([0-9_]+) /).try(:[], 1)
      elsif row[:os_name] =~ /Linux/
        row[:device] = "Linux PC"
      elsif row[:os_name] =~ /SymbianOS/
        row[:os_name] = "Symbian OS"
        row[:os_version] = row[:user_agent].match(/SymbianOS\/([0-9\.]+) /).try(:[], 1)
      elsif row[:browser] =~ "Chrome 4"
        row[:browser] = "Chrome" 
      end
    end
  end
end