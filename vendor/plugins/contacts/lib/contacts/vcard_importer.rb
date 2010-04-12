# Instance Methods to be included in the contacts model
module Contacts
  module VcardImporter
    def error_messages
      @error_messages
    end
  
    def import_from_vcard(card, user = nil)
      @error_messages = []
      if self.is_a?(Person)
        self.given_name        = card.name.given      unless card.name.given.blank?
        self.family_name       = card.name.family     unless card.name.family.blank?
        self.nickname          = card.nickname        unless card.nickname.blank?
        self.role              = card.title           unless card.title.blank?
        self.honorific_prefix  = card.name.prefix     unless card.name.prefix.blank?
        self.honorific_suffix  = card.name.suffix     unless card.name.suffix.blank?
        self.birthday          = card.birthday        unless card.birthday.blank?
        self.role_level        = card['JOB_LEVEL']    unless card['JOB_LEVEL'].blank?
        self.role_function     = card['JOB_FUNCTION'] unless card['JOB_FUNCTION'].blank?
        self.contact_code      = card['CONTACT_CODE'] unless card['CONTACT_CODE'].blank?
        self.organization_name = card.org.first.strip if card.org
        import_photo(card.photos.first) if card.photos.first
        set_audit_user(user)
      else
        self.name              = card.org.first.strip if card.org
      end

      Contact.transaction do
        raise self.errors.inspect unless save
        import_emails(card.emails)
        import_websites(card.urls)
        import_addresses(card.addresses)
        import_telephones(card.telephones)
        import_organization_data(card) unless self.is_a?(Organization)
      end
      error_messages
    end

  private
    def strip_content!(card)
      [card.name.given, card.name.family, card.title, card.org].flatten.each do |attrib|
        attrib.strip! if attrib
      end
    end

    def import_emails(emails)
      emails.each do |card_email|
        email_address   = card_email.to_s
        unless email_address =~ /No email address found/
          email           = self.emails.find_by_address(email_address) || self.emails.build
          email.kind      = card_email.location.first
          email.address   = email_address
          email.preferred = card_email.preferred
          @error_messages << email.errors.full_messages unless email.save
        end
      end
    end

    def import_websites(websites)
      websites.each do |card_website|
        website_address = card_website.uri.gsub('\\','')
        website         = self.websites.find_by_url(website_address) || self.websites.build
        website.url     = website_address
        @error_messages << website.errors.full_messages unless website.save
      end
    end

    def import_telephones(phones)
      phones.each do |card_phone|
        number          = card_phone.to_s
        phone           = self.phones.find_by_number(number) || self.phones.build
        #if !phone.new_record? && phone.kind != card_phone.location.first
        #  puts "#{self.full_name}: Number #{number} found with different types: was #{phone.kind} now set to #{card_phone.location.first}"
        #end
        phone.kind      = card_phone.location.first
        phone.number    = number
        phone.preferred = card_phone.preferred
        @error_messages << phone.errors.full_messages unless phone.save
      end
    end

    def import_addresses(addresses)
      addresses.each do |card_address|
        address = self.addresses.find_by_vcard(card_address) || self.addresses.build
        address.kind        = card_address.location.first
        address.street      = card_address.street
        address.locality    = card_address.locality
        address.region      = card_address.region
        address.country     = card_address.country
        address.postalcode  = card_address.postalcode
        address.preferred   = card_address.preferred
        @error_messages << address.errors.full_messages unless address.save
      end
    end
  
    def import_organization_data(card)
      organization = self.organization
      if organization
        organization.revenue    = card['REVENUE']
        organization.employees  = card['EMPLOYEES']
        organization.industry   = card['INDUSTRY']
        @error_messages << organization.errors.full_messages unless organization.save
      end
    end

    def import_photo(photo)
      path = "#{Rails.root}/tmp/#{SecureRandom.base64(10).gsub('/','-')}.jpg"
      File.open(path, "wb") { |disk_file| disk_file << photo.to_io.read }
      File.open(path) { |photo_file| self.photo = photo_file }
      FileUtils.rm path
    end
    
    def set_audit_user(user)
      effective_user = user || User.current_user
      self.created_by = effective_user if self.new_record?
      self.updated_by = effective_user
    end
  end
end