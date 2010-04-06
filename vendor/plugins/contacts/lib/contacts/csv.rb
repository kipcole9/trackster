module Contacts
  class Csv < Contacts::ImportExport
    HEADER_CONVERTER = lambda { |header|
      normalized_column = header.gsub(/[ \-_]/,'').downcase
      I18n.t("contact_csv_headings.#{normalized_column}", :default => normalized_column).to_sym
    }
    
    def import_file(account, csv_file)
      FasterCSV.foreach(csv_file, :headers => true, :header_converters => HEADER_CONVERTER) do |row|
        import_csv_record(account, row.to_hash)
      end
    end
    
    def import_csv_record(account, record)
      vcard = vcard_from_csv_hash(record)
      import_vcard(account, vcard)
    end
    
    private
    def vcard_from_csv_hash(record)
      card = card = Vpim::Vcard::Maker.make2 do |maker|
        
        # Name
        maker.add_name do |name|
          [:prefix, :given, :additional, :family, :suffix].each do |part|
            name.send("#{part}=", record[part]) if record[part]
          end           
        end
        
        # Addresses
        ['work','home','other'].each do |type|
          pobox, street, locality, region, country, postalcode = address_from_hash(record, type)
          next unless (pobox || street || locality || region || country || postalcode)  
          maker.add_addr do |addr|              
            addr.location   = type
            addr.pobox      = poxbox      if pobox
            addr.street     = street      if street
            addr.locality   = locality    if locality
            addr.region     = region      if region
            addr.country    = country     if country
            addr.postalcode = postalcode  if postalcode
          end  
        end

        # Phone numbers
        ['work', 'work_fax', 'home', 'home_fax', 'other', 'other_fax', 'car', 'cell', 'company'].each do |type|
          number = record.fetch("#{type}_phone".to_sym, nil)
          next unless number
          maker.add_tel(number) do |phone|
             phone.location = type.split('_');
          end
        end
        
        # Email addresses
        ['work','home','other'].each do |type|
          [1,2,3].each do |number|
            email_address = record.fetch("#{type}_email_#{number}".to_sym, nil)
            maker.add_email(email_address) {|email| email.location = type} unless email_address.blank?
          end
        end
        
        # Birthday
        begin
          maker.birthday = Date.parse(record[:birthday]) if record[:birthday]
        rescue ArgumentError
          nil
        end
        
        # Anniversary
        begin
          anniversary =  Date.parse(record[:anniversary]) if record[:birthday]
          maker.add_field(Vpim::DirectoryInfo::Field.create('ANNIVERSARY', anniversary)) if anniversary
        rescue ArgumentError
          nil
        end
                  
        # Other items
        [:title, :org, :note].each do |item|
          maker.send("#{item}=", record[item]) unless record[item].blank?
        end
        
        # URL
        maker.add_url(record[:url]) unless record[:url].blank?
        
        # Custom fields
        [:contact_code, :revenue, :currency, :industry, :employees, :job_function, :job_level, :gender].each do |field|
          maker.add_field(Vpim::DirectoryInfo::Field.create(field.to_s.upcase, record[field])) unless record[field].blank?
        end
      end
    end

    def address_from_hash(record, type)
      pobox       = record.fetch("#{type}_pobox".to_sym,      nil)
      street      = street_from_hash(record, type)
      locality    = locality_from_hash(record, type)
      region      = record.fetch("#{type}_region".to_sym,     nil)
      country     = record.fetch("#{type}_country".to_sym,    nil)
      postalcode  = record.fetch("#{type}_postalcode".to_sym, nil)
      return pobox, street, locality, region, country, postalcode      
    end
    
    def street_from_hash(record, type)
      street = [1, 2, 3, 4].inject([]) {|road, i| road << record.fetch("#{type}_street_#{i}".to_sym, nil)}.compact.join(',')
      return nil if street.blank?
      street
    end 
    
    def locality_from_hash(record, type)
      locality = [record.fetch("#{type}_suburb".to_sym, nil), record.fetch("#{type}_locality".to_sym, nil)].compact.join(',')
      return nil if locality.blank?
      locality
    end       
  end
end
