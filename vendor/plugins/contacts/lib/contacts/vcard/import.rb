module Contacts
  module Vcard
    class Import < ImportExport    
      def import_file(account, card_file)
        cards = Vpim::Vcard.decode(File.open(card_file).read)
        import_vcards(account, cards)
        error_messages.empty? ? cards.size : nil
      end
  
      def import_vcards(account, cards)
        cards.each {|card| import_vcard(account, card) }
        error_messages.flatten!.compact!
      end

      def import_vcard(account, card)
        if contact = find_or_create_by_vcard(account, card)
          contact.import_from_vcard(card)
        else
          puts "Could not import vcard"
          puts card.to_s
        end
        error_messages << contact.error_messages
      end

    protected
      def find_or_create_by_vcard(account, card)
        strip_content!(card)
        contact = find_by_vcard(account, card) || create_from_vcard(account, card)
      end

      def find_by_vcard(account, card)
        find_by_contact_code(account, card) || find_by_emails(account, card) || find_by_names_and_company(account, card)
      end

      def create_from_vcard(account, card)
        conditions = find_by_names_and_company_conditions(card)
        if conditions[:given_name] || conditions[:family_name]
          account.people.new
        elsif conditions[:organization]
          account.organizations.new
        else
          nil
        end
      end
  
      def find_by_contact_code(account, card)
        return nil unless contact_code = card['CONTACT_CODE']
        account.contacts.find_by_contact_code contact_code
      end

      def find_by_emails(account, card)
        return nil if (emails = card.emails.dup.map(&:to_s).uniq).empty?
        contacts = account.contacts.find(:all, :include => :emails, :conditions => {:'emails.address' => emails})
        return nil if contacts.empty?
        if contacts.length > 1
          error_messages << "Don't know how to import a card that spans multiple existing contact email addresses: #{emails.join(', ')}"
          return nil
        else
          contacts.first
        end
      end

      def find_by_names_and_company_conditions(card)
        conditions = {}
        conditions[:given_name]   = card.name.given   unless card.name.given.blank?
        conditions[:family_name]  = card.name.family  unless card.name.family.blank?
        conditions[:role]         = card.title        unless card.title.blank?
        conditions[:organization] = card.org.first    if card.org && card.org.first
        conditions
      end

      # Look up the organization first, if there is one.  If there is then
      # it's either an "organization only" card, or the organization is the
      # scope within which to lookup the name.
      def find_by_names_and_company(account, card)
        conditions = find_by_names_and_company_conditions(card)
        if conditions[:organization]
          return nil unless organization = account.organizations.find_by_name(conditions.delete(:organization))
          find_base = organization.contacts
        else
          find_base = Contact
        end
  
        if conditions[:given_name] || conditions[:family_name]
          find_base.find(:first, :conditions => conditions)
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
    
      def sanitize_sql_for_conditions(conditions)
        ActiveRecord::Base.send(:sanitize_sql_for_conditions, conditions)
      end
      
      
    end
  end
end