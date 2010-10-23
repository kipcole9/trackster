#
# Abstract translinker class.  Inherit from this for your own translinker
# See Trackster::Translinker::Email for an example
#
module Trackster
  module Translinker
    class Base

      # Some options are email specific but kept to standardise the interface
      DEFAULT_OPTIONS = {
        :add_tracker            => true,        # Adds the tracking image at the end of the body
        :inline_css_files       => true,        # Moves CSS files into the document
        :image_location         => :remote,     # If :cloud, copies the images to the cloud and references them there
        :add_link               => [:webview],  # :webview => A link that says "Click here if you can't read this"
                                                # :unsubscribe => A link to an unsubscribe function
                                                # :forward => A link that leads to a form allowing the campaign to be forwarded
        :merge                  => nil,         # An object whose public methods can be used to interpolate
                                                # values into the document
        :campaign               => nil,         # Campaign context for the translink.  Can be any object that responds to
                                                # #code, #medium, #content, #source, #contact_code
        :base_url               => nil          # Prepended to any relative image and anchors links to make them absolute 
      }
      
      
      # Nokogiri is very strict on entities and parses them.  We actually
      # don't want them transformed so we edit them and then put them back
      MAGIC_ENTITY = '!!ZXZX!!'

      # And because of this entity issue we do a similar thing for the contact merge
      # field.
      CONTACT_MARKER = '!!XZXZ!!'

      # These are the only schemes we care about when transforming links
      # into redirects.  Ignore all others.
      REDIRECT_SCHEMES = %w(http https)
      
      # How to detect MAILTO URL's which are a special form the Ruby standard
      # URI.parse() doesn't like
      MAILTO_SCHEME    = /mailto/i
      
      # URLs that are document relative
      DOCUMENT_PATH    = /\A#.*/i
      
      # Unsafe characters in an URL that need to be encoded
      # Used because URI.parse is quite strict.
      UNSAFE_CHARS     = ' '
  
      attr_accessor :errors, :output
      attr_reader   :base_url, :campaign, :options, :records, :html
  
      #
      # Translink the html code and optionally intepolation data into
      # it.
      #
      # html    The html source
      # options:
      #   :merge  Any object instance.  Its public methods are considered available for interpolation variable
      #   &block  Executed for each merged record. Passed the translinked template and the current record
      #
      def self.translink(document, options = {}, &block)
        linker = new(options)
        output = linker.translink(document, options)
        output = linker.merge_records_into_template(output, linker.records, &block) unless linker.errors?
        linker.errors? ? linker.errors : output
      end
  
      def initialize(options)
        @errors   = []
        @options  = DEFAULT_OPTIONS.merge(options).symbolize_keys
        @records  = options[:merge]
        @records  = [@records].compact unless @records.respond_to?(:each)
        @campaign = options.delete(:campaign)
        @base_url = options.delete(:base_url) || ''     
      end
  
      def translink(document, options = {})
        if document.blank?
          errors << I18n.t('translink.no_source_document')
        else
          @html = parse_document(document)
          output = translink_parsed_document unless errors?
        end
        return errors? ? errors : output
      end

      # This method is probably generic enough to inherit from
      def merge_records_into_template(template, records, &block)
        return template unless !errors? && merge?
        merged_html = records.each do |record| 
          clear_errors
          merged_template = merge_record_into_template(template, record)
          yield merged_template, record if block_given?
          merged_template
        end
      end

      def errors?
        !errors.empty?
      end
  
    protected
  
      # If you need to parse the document (for example, as html or xml or json)
      # then implement a concrete method in your derived class
      def parse_document(document)
        document
      end
  
      # We should be able to inherit from this when we get around to building
      # it.
      def merge_record_into_template(template, record)
    
      end
  
      # Links to a web page for people who can't otherwise view the message
      def add_web_view_link(content)
  
      end

      # Links to a form that allows people to forward this campaign to
      # other people.
      def add_forward_link(content)
  
      end

      # Links to a form that allows people to unsubscribe.
      def add_unsubscribe_link(content)  
  
      end  
  
      # Campaign parameters are generic.  But note if not an email you
      # should adjust in your derived class
      def view_parameters
        [campaign_parameters, "utcat=page", "utact=view"].compress.join('&')
      end

      def open_parameters
        [campaign_parameters, "utcat=email", "utact=open"].compress.join('&')
      end

      def campaign_parameters
        params = ''
        if campaign
          params += "utac=#{Account.current_account.tracker}&utm_campaign=#{campaign.code}&utm_medium=#{campaign.medium}"
          params += "&utm_content=#{campaign.content_code}" unless campaign.content_code.blank?
          params += "&utm_source=#{campaign.source}"        unless campaign.source.blank?
          params += "&utid=#{CONTACT_MARKER}"               unless campaign.contact_code.blank?
        end
        params
      end

      def redirector_url(redirect)
        "#{Trackster::Config.redirect_url}/#{redirect}"
      end
  
      def copy_images?
        options[:image_location] && options[:image_location].to_sym == :cloud
      end

      def move_css_files_inline?
        options[:inline_css_files]
      end

      def add_tracker?
        options[:add_tracker]
      end

      def add_web_view_link?
        options[:add_link].include? :webview
      end

      def add_unsubscribe_link?
        options[:add_link].include? :unsubscribe     
      end

      def add_forward_link?
        options[:add_link].include? :unsubscribe
      end

      def merge?
        records && !records.empty? && records.respond_to?(:each)
      end    

      def clear_errors
        errors = []
      end
  
      # Whatever you need to do to the text BEFORE parsing
      def fix_entities(text)
    
      end

      # Whatever you need to do AFTER translinking but BEFORE merging
      def unfix_entities(text)

      end
  
    end
  end
end