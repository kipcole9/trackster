class FlashChart
  DEFAULT_OPTIONS = {:width => "100%", :height => "100%", :flash_version => "9", 
                     :background_color => '#ffffff', :div => nil, :target_id => nil, :title => nil}
  DEFAULT_OPTIONS.each {|k, v| attr_accessor k.to_s}
  attr_accessor     :swf_file
  DEFAULT_CHART_TITLE = "Chart"
  
  
  def initialize(swf, options = {})
    raise ArguementError, 'No chart file provided' unless swf
    raise ArgumentError, "Chart file does not exist: '#{swf_file_path(swf)}'." unless File.exist?("#{swf_file_path(swf)}")
    @swf_file = swf
    validate_options!(DEFAULT_OPTIONS.dup.merge(options))
  end
  
  def to_html
    s =   "<div id=#{div}>\n"
    s +=  "<script type='text/javascript'>\n"			
    s +=	"		var s = new SWFObject(#{swf_file}, #{target_id}, #{width}, #{height}, #{flash_version}, #{background_color});\n"					
    s +=	"		s.write(#{div});\n"
    s +=  "</script>\n"
    s +=  "</div>\n"
    s
  end
  
  def target_id
    quote(@target_id || File.basename(@swf_file, '.*'))
  end
  
  def div
    quote(@div || (File.basename(@swf_file, '.*') + "_container"))
  end
  
  def height
    quote(@height)
  end
  
  def width
    quote(@width)
  end
  
  def background_color
    quote(@background_color)
  end
  
  def flash_version
    quote(@flash_version)
  end
  
  def title
    @title || DEFAULT_CHART_TITLE
  end
  
  def swf_file
    quote("/bin/#{@swf_file}")
  end
  
private
  def validate_options!(options)
    puts options.inspect
    options.each do |key, value|
      raise ArgumentError, "Invalid option to Chart: '#{key}'" unless DEFAULT_OPTIONS.has_key?(key)
      instance_variable_set("@#{key.to_s}", value)
    end
  end
      
      
  def swf_file_path(swf_file)
    @swf_file_path ||= "#{RAILS_ROOT}/public/bin/#{swf_file}"
  end
  
  def quote(s)
    '"' + s + '"'
  end
  
end
    