# Translinker overview
# 
# The translinkers  primary job is to take an html document and to do the following:
# 
# 1.  Make sure all image links are absolute.  
# 2.  Add the tracking image
# 3.  Turn all <a> tags into redirects so we can track them
# 4.  Add links for "forward to a friend", "unsubscribe" and "view on the web".  
# 
# The translinker can be provided with options to do some or all of these.  The defaults currently are to do (1), (2) and (3) plus add a "view on the web" link.
# 
# For convenience it also provides merge functionality
# 
# 1.  If provided a set of records it will attempt to merge fields into the HTML document
# 2.  The merge is run for each record until there are no more records OR until an error is detected.
# 3.  For each record it will yield to a provided block of code to do further processing (like send an email)
# 
# Order of Processing
# 
# The translinker first does the linking activities and then the merging activities. 
# 
# Whats returned
# 
# If no merging is specified then the translinked html text is returned.
# 
# If merging is specified then:
#   1. The linked and merged template is yielded to a provided block for each merged record
#   2. The last merged record is returned at the end of the process.
# 
# At no stage does the translinker touch the database in any way.
# 
# If errors are detected then instead of returning HTML it will return an array of the errors detected.  
# Errors are also logged in the production log.
# 
# Typical Usage
# 
# # This usage only links - it doesn't merge
# linker = Trackster::Translinker.new(options)
# linker.translink
# if linker.errors?
#   puts "Woops, there were errors"
#   linker.errors.each {|e| puts e}
# else
#   puts "All went well."
#   puts linker.html_output
# end
# 
# Merging
# 
# Now we have a template we can do some merging.  Assuming we did the code above:
#   linker.html => the result of linking
#   records   => some set of records to be merged.  Commonly from the database but can be anything that responds to #each
# 
# merge_records_into_template(linker.html_output, records) do |merged_html, contact|
#   send_email(contact, merged_html)    # Just an example - this code doesn't exist
# end
# 
# Merge fields are denoted by 
#   [field_name]
# 
# In the text part of a document.  Because of the way that Nokogiri and lixml2 work (our parser), merging won't happen for content inside html tags (like <a>, <img> and so on).  This might be fixed later if there's a real requirement identified.
# 
# What fields can be merged
# 
# Rather than have a static list of fields, we use the dynamic nature of ruby to let us dynamically define fields.  For now the we send the 'field_name' as a method call to the "record" that we are processing and we use the return value as the merged content.  This means that any public method available on the record can be used as a merge field.  Pretty cool really.
# 
# Follow-on work:  Allow merging from either the "record" or from the "campaign". Hmm, probably will do this right off the bat for the first version since it makes sense.
# 
# If we get a NoMethodError (or actually any other exception) then we log it and insert nothing (well, an empty string anyway).
# 
# Combining it all together
# 
# To combine it all together there is a class method that links and merges as follows:
# 
# Trackster::Translinker.translink(html, options) do |html_output, records|
#   # Do something with each merged record
# end
module Trackster
  module Translinker
    class HtmlEmail < Trackster::Translinker::Base
      include Trackster::Translinker::HtmlTagsWithUrls
      
      STYLES_FILE     = "#{File.dirname(__FILE__)}/templates/email_styles.erb"
      DIV_FILE        = "#{File.dirname(__FILE__)}/templates/email_body_div.erb"
      
      def translink_parsed_document
        make_anchors_into_redirects
        make_links_absolute(TAGS_WITH_URLS - ['a', 'img'])
        copy_images? ? copy_images_to_cloud : make_image_links_absolute
        move_css_files_inline if move_css_files_inline?
        add_trackers         if add_tracker?
        add_web_view_link     if add_web_view_link?
        add_unsubscribe_link  if add_unsubscribe_link?
        return unfix_entities(html.to_html)
      end

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
      def add_trackers
        add_view_tracker
        add_print_and_forward_trackers
      end
      
      def make_anchors_into_redirects  
        (html/"a").each do |link|
          next unless url = link_attribute?(link, 'href')
          begin
            parsed_url = URI.parse(url)
            next if unhosted_url?(parsed_url)
            next unless REDIRECT_SCHEMES.include?(parsed_url.scheme)
            make_anchor_into_redirect(link, url, parsed_url)
          rescue URI::InvalidURIError => e
            Rails.logger.error "[Translinker] Make Anchors Into Redirects: Invalid URL error detected: '#{url}'"
            errors << I18n.t('translinker.bad_uri', :url => url)
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "[Translinker] Make Anchors Into Redirects: Active record error: #{e.message}"
            Rails.logger.error "[Translinker] URL was '#{url}'"
            errors << e.message
          end
        end
      end
      
      def make_all_links_absolute
        make_links_absolute(TAGS_WITH_URLS)
      end
      
      def make_image_links_absolute
        html.search("img").each do |link|
          make_link_absolute(link)
        end
      end

      def make_links_absolute(tags_with_urls)
        html.search(*tags_with_urls).each do |link|
          make_link_absolute(link)
        end
      end

      # Move CSS files into the document. Most email readers don't support
      # external CSS files.
      def move_css_files_inline
        css_file_links.each do |css_link|
          begin
            move_css_file_inline(css_link)
            remove_css_file_link(css_link)
          rescue URI::InvalidURIError => e
            errors << e
          rescue SocketError => e
            errors << e
          rescue OpenURI::HTTPError => e
            errors << e
          end
        end
      end

      # Move the image files to cloud storage
      # and adjust the image references to suit.
      # Mutually exclusive of #make_image_links_absolute
      # We put the images in a container called #{account_name}
      def copy_images_to_cloud 
        cf = CloudFiles::Connection.new(:username => Trackster::Config.cloudfiles_user, :api_key => Trackster::Config.cloudfiles_api, :snet => (Rails.env == 'production'))
        container = get_or_create_container(cf, Account.current_account, :make_public => true)
        html.search('img').each do |image|
          begin
            image_source = image['src'].strip
            cloud_image_url = copy_image_to_container(container, image_source)
            image['src'] = cloud_image_url
          rescue URI::InvalidURIError => e
            errors << e
          rescue SocketError => e
            errors << e
          rescue OpenURI::HTTPError => e
            errors << e
          end
        end
      end
      
      # Adds an image link at the end of the body of the document whose
      # purpose is to create a tracking entry in the log that we use to
      # detect an email being opened.
      def add_view_tracker
        tracking_node = Nokogiri::XML::Node.new('img', html)
        tracking_node['src'] = [Trackster::Config.email_open_tracker_url, open_parameters].join('?')
        tracking_node['style'] = "display:none"
        body = html.css("body").first
        body.add_child(tracking_node)
      end
      
      # Some trickery to try to detect prints and forwards.
      def add_print_and_forward_trackers
        print_tracking_url = [Trackster::Config.tracker_url, print_parameters].join('?')
        forward_tracking_url = [Trackster::Config.tracker_url, forward_parameters].join('?')
        styles = ERB.new(File.read(STYLES_FILE)).result(binding)

        styles_node = Nokogiri::XML::CDATA.new(html, styles)
        html.css("head").first.add_child(styles_node)

        div = ERB.new(File.read(DIV_FILE)).result(binding)
        div_node = Nokogiri::XML::CDATA.new(html, div)
        html.css("body").first.add_child(div_node)
      end

      # Links to a web page for people who can't otherwise view the message
      #
      # Tag format:
      # => <webview>Link text for the forward</webview>
      #
      def add_web_view_link
  
      end

      # Links to a form that allows people to forward this campaign to
      # other people.
      #
      # Tag format:
      # => <forward>Link text for the forward</forward>
      #
      def add_forward_link
  
      end

      # Links to a form that allows people to unsubscribe.
      #
      # Tag format:
      # => <unscubscribe>Link text for unsubscribing</forward>
      #
      def add_unsubscribe_link  
  
      end

      # Basically it's string interpolation using public
      # methods from #record substituted into the template
      # using a field format of [field]
      #def merge_record_into_template(template, record)
        # TODO Implement in Base class
      #end

      def parse_document(source)
        ::Nokogiri::HTML(fix_entities(source)) do |config|
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

      # Convert an anchor to a redirect (so we can track it).  Create
      # a redirect in the database if not already existing.  Copy any
      # URL parameters across (they're not stored as part of the redirect)
      def make_anchor_into_redirect(link, url, parsed_url)          
        query_string = parsed_url.query
        url = url.sub("?#{query_string}", '') unless query_string.blank?

        redirect = Redirect.find_or_create_from_link(base_url, url, link.content)
        new_href = redirector_url(redirect.redirect_url)
        parameters = [query_string, view_parameters].compact.join('&')
        new_href += "?#{parameters}" unless parameters.blank?
        link['href'] = new_href if new_href
      end
      
      # Add base_url to a relative url, ignoring
      # links that are already absolute (have a scheme and host)
      # and links that aren't relevant (like mailto:)
      def make_link_absolute(link)
        attributes_from(link.name).each do |attribute|
          next unless url = link_attribute?(link, attribute)
          begin
            parsed_url = URI.parse(url)
            next if parsed_url.absolute? || unhosted_url?(parsed_url)
            link[attribute] = [base_url, url].compress.join('/')
          rescue URI::InvalidURIError => e
            Rails.logger.error "[Translinker] Make Link Absolute: Invalid URL: '#{url}'"
            errors << I18n.t('translinker.bad_uri', :url => url)
          end
        end
      end 
      
      def attributes_from(name)
        attributes = TAG_URL_ATTRIBUTES[name]
        attributes = [attributes] unless attributes.is_a?(Array)
        attributes
      end
      
      # Return the requested attribute of a URL if it exists
      # We encode the URL so that the URI.parse doesn't barf on
      # characters that are technically invalid but are commonly
      # accepted by browsers.
      def link_attribute?(link, attribute)
        if url = link[attribute].try(:strip)
          url = URI.encode(url, UNSAFE_CHARS)
          link[attribute] = url if url != link[attribute]
        end
        url.blank? ? nil : url
      end
      
      # URL's that should not be made absolute because they 
      # can't be (like mailto:), or because they are document
      # relative (start with #)
      def unhosted_url?(url)
        url.scheme =~ MAILTO_SCHEME || url.to_s =~ DOCUMENT_PATH
      end
      
      # Return all the CSS links in the document
      def css_file_links
        html.search("link[rel=stylesheet]")
      end 
      
      # Move one CSS file inline
      def move_css_file_inline(link)
        css = open(link['href']) {|f| f.read }
        style_tag = Nokogiri::XML::Node.new('style', html)
        style_tag.content = css
        find_or_create_head.add_child(style_tag)
      end
      
      # Delete a CSS file link after we've moved the contents
      # inline
      def remove_css_file_link(link) 
        link.remove
      end
      
      def find_or_create_head
        if (head = html.css("head")).empty?
          head_tag = Nokogiri::XML::Node.new('head', html)
          html_doc = css("html").first
          return html_doc.children.empty? ? html_doc.add_child(head_tag) : 
                                            html_doc.children.first.add_previous_sibling(head_tag)
        else
          return head.first
        end
      end

      # Return the container if it exists, otherwise create it
      def get_or_create_container(cf, account, options = {})
        container_name = account.name.gsub(' ','_')
        if cf.container_exists?(container_name) 
          container = cf.container(container_name)
        else
          container = cf.create_container(container_name)
          container.make_public if options[:make_public]
        end
        container
      end

      # Copy one image to the container and return its
      # public URL
      def copy_image_to_container(container, image_source)
        cloud_object = container.create_object(cloud_object_name_from(image_source))
        cloud_object.load_from_filename(image_source)
        cloud_object.public_url
      end

      # Create and object name from a URI.  We're storing all images for an
      # account in one container so we want to:
      # 1.  Not have name clashes on images that might be same name on different paths
      # 2.  Have names be indempotent so an updated image updates the same object
      def cloud_object_name_from(image_source)
        uri = URI.parse(image_source)
        "#{uri.host}#{uri.path.gsub('/','_')}"
      end      
    end
  end
end

