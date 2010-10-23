# Takes content map and maps the campaign clickthrough on it
module Trackster
  module Translinker
    class ClickMap < Trackster::Translinker::Base
      JAVASCRIPT_FILE     = "#{File.dirname(__FILE__)}/click_map/click_map.js.erb"
      CSS_FILE            = "#{File.dirname(__FILE__)}/click_map/click_map.css"
      BANNER_FILE         = "#{File.dirname(__FILE__)}/click_map/click_banner.html.erb"
      JAVASCRIPT_INCLUDES = "#{File.dirname(__FILE__)}/click_map/javascript_includes.html"
        
      
      def initialize_template_variables
        @campaign_summary  = campaign.campaign_summary(options).first
        @total_impressions = @campaign_summary ? @campaign_summary.impressions : 0
        @total_clicks      = @campaign_summary ? @campaign_summary.clicks_through.to_i : 0
        @effective_at      = campaign.effective_at
        @url_clicks        = click_throughs
      end
      
      def translink_parsed_document
        initialize_template_variables
        add_javascripts
        add_css
        add_banner
        add_script
        return unfix_entities(html.to_html)
      end
      
      def add_javascripts
        javascripts = File.read(JAVASCRIPT_INCLUDES)
        html.css("head").children.first.before(javascripts)
      end
      
      def add_css
        css = File.read(CSS_FILE)
        html.css("head").children.last.after(css)      
      end
      
      def add_banner
        template = ERB.new(File.read(BANNER_FILE))
        banner = template.result(self.send :binding)
        html.css("body").children.first.before(banner)        
      end
      
      def add_script
        template = ERB.new(File.read(JAVASCRIPT_FILE))
        script = template.result(binding)
        script_node = Nokogiri::XML::CDATA.new(html, script)
        body = html.css("body").first
        body.add_child(script_node)
      end

      def parse_document(source)
        ::Nokogiri::HTML(fix_entities(source.strip)) do |config|
          # config.noent
        end
      end
      
    private
      # Nokogiri is very strict (or maybe libxml is) in handling html entities
      # We don't want entities to be touched even if they aren't valid.  So
      # we fiddle them here and put back after document processing.
      def fix_entities(text)
        text.gsub('&',MAGIC_ENTITY)
      end

      def unfix_entities(text)
        unfixed = text.gsub(MAGIC_ENTITY,'&')
        unfixed = unfixed.gsub(CONTACT_MARKER, campaign.contact_code) if campaign
        unfixed
      end
      
      def click_throughs
        click_records = campaign.campaign_clicks_by_url(options).all.reject{|r| r.clicks_through.to_i == 0}
        click_records.inject({}) do |url_clicks, click|
          url_clicks[click[:url].strip] = click[:clicks_through].to_i
          url_clicks
        end
      end

    end
  end
end
