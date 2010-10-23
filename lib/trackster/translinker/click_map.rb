# Takes content map and maps the campaign clickthrough on it
module Trackster
  module Translinker
    class ClickMap < Trackster::Translinker::Base
      
      def initialize(options)
        super
        @campaign_summary  = campaign.campaign_summary(options).first
        @total_impressions = campaign_summary.impressions rescue 0
        @total_clicks      = campaign.clicks_through.to_i rescue 0
        @effective_at      = campaign.effective_at
      end
      
      def translink_parsed_document(html, options = {})
        add_javascripts(html)
        add_css(html)
        add_banner(html, options)
        add_script(html, options)
        return unfix_entities(html.to_html)
      end
      
      def add_javascripts(html)
        javascripts = File.read("#{File.dirname(__FILE__)}/click_map/javascript_includes.html")
        html.css("head").children.first.before(javascripts)
      end
      
      def add_css(html)
        css = File.read("#{File.dirname(__FILE__)}/click_map/click_map.css")
        html.css("head").children.last.after(css)      
      end
      
      def add_banner(html, options)
        template = ERB.new(File.read("#{File.dirname(__FILE__)}/click_map/click_banner.html.erb"))
        banner = template.result(binding)
        html.css("body").children.first.before(banner)        
      end
      
      def add_script(html, options)
        @url_clicks = click_throughs(options)
        template = ERB.new(File.read("#{File.dirname(__FILE__)}/click_map/click_map.js.erb"))
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
      
      def click_throughs(options)
        click_records = campaign.campaign_clicks_by_url(options).all.reject{|r| r.clicks_through.to_i == 0}
        click_records.inject({}) do |url_clicks, click|
          url_clicks[click[:url].strip] = click[:clicks_through].to_i
          url_clicks
        end
      end
    end
  end
end
