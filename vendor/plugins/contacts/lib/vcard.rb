module Vcard
  module Import
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def import(vcard)
        self.import_vcards()
      end

      def import_vcards(card_file)
        @cards = Vpim::Vcard.decode(File.open(card_file).read)
        @cards.each {|card| self.import_vcard(account, card) }
        @cards
      end

      def import_vcard(card)
        if contact = user.find_or_create_by_vcard(card)
          contact.import_vcard(card)
        else
          logger.debug "Could not import vcard"
          logger.debug card.inspect
        end
        contact
      end

      def find_or_create_by_vcard(card)
        strip_content!(card)
        contact = find_by_vcard(card) || create_from_vcard(card)
      end

      def find_by_vcard(card)
        find_by_emails(card) || find_by_names_and_company(card)
      end

      def create_from_vcard(card)
        conditions = find_by_names_and_company_conditions(card)
        if conditions[:given_name] || conditions[:last_name]
          Person.new
        elsif conditions[:organization]
          Organization.new
        else
          nil
        end
      end
  
      def find_by_emails(card)
        return nil if (emails = card.emails.dup.map(&:to_s).uniq).empty?
        contact_email_addresses = Email.find(:all, :select => "DISTINCT contact_id", :conditions => {:address => emails})
        return nil if contact_email_addresses.empty?
  
        if contact_email_addresses.length > 1
          raise "Don't know how to import a card that spans multiple existing contact email addresses: #{emails.join(', ')}"
        end
        contact_email_addresses.first.contact
      end
  
      def find_by_names_and_company_conditions(card)
        conditions = {}
        conditions[:given_name]   = card.name.given unless card.name.given.blank?
        conditions[:family_name]  = card.name.family unless card.name.family.blank?
        conditions[:role]         = card.title unless card.title.blank?
        conditions[:organization] = card.org.first if card.org && card.org.first
        conditions
      end
  
      # Look up the organization first, if there is one.  If there is then
      # it's either an "organization only" card, or the organization is the
      # scope within which to lookup the name.
      def find_by_names_and_company(card)
        conditions = find_by_names_and_company_conditions(card)
        if conditions[:organization]
          return nil unless organization = Organization.find_by_name(conditions.delete(:organization))
          find_base = organization.contacts
        else
          find_base = self
        end
      
        if conditions[:given_name] || conditions[:family_name]
          find_base.find(:first, :conditions => sanitize_sql_for_conditions(conditions))
        else
          organization
        end
      end
      
      private
        def strip_content!(card)
          [card.name.given, card.name.family, card.title, card.org].flatten.each do |attrib|
            attrib.strip! if attrib
          end
        end
    end

    def import_vcard(card)
      if self.is_a?(Person)
        self.given_name = card.name.given unless card.name.given.blank?
        self.family_name = card.name.family unless card.name.family.blank?
        self.role = card.title unless card.title.blank?
        self.organization_name = card.org.first.strip if card.org
      else
        self.name = card.org.first.strip if card.org
      end

      Contact.transaction do
        puts self.errors.inspect unless self.save
        import_emails(card.emails)
        import_websites(card.urls)
        import_addresses(card.addresses)
        import_telephones(card.telephones)
      end
    end
    
  private
    def strip_content!(card)
      [card.name.given, card.name.family, card.title, card.org].flatten.each do |attrib|
        attrib.strip! if attrib
      end
    end

    def import_emails(emails)
      emails.each do |card_email|
        email_address = card_email.to_s
        email = self.emails.find_by_address(email_address) || self.emails.build
        email.kind = card_email.location.first
        email.address = email_address
        email.preferred = card_email.preferred
        logger.debug email.errors.inspect unless email.save
      end
    end

    def import_websites(websites)
      websites.each do |card_website|
        website_address = card_website.uri.gsub('\\','')
        website = self.websites.find_by_url(website_address) || self.websites.build
        website.url = website_address
        logger.debug website.errors.inspect unless website.save
      end
    end

    def import_telephones(phones)
      phones.each do |card_phone|
        number = card_phone.to_s
        phone = self.phones.find_by_number(number) || self.phones.build
        phone.kind = card_phone.location.first
        phone.number = number
        phone.preferred = card_phone.preferred
        logger.debug  phone.errors.inspect unless phone.save
      end
    end

    def import_addresses(addresses)
      addresses.each do |card_address|
        address = self.addresses.find_by_vcard(card_address) || self.addresses.build
        address.kind = card_address.location.first
        address.street = card_address.street
        address.locality = card_address.locality
        address.region = card_address.region
        address.country = card_address.country
        address.postalcode = card_address.postalcode
        address.preferred = card_address.preferred
        logger.debug  address.errors.inspect unless address.save
      end
    end  
  end
end