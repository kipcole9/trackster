module Contacts
  class Import
    attr_accessor       :importer, :account, :user
    
    unless self.class == Contacts::Import
      attr_reader       :error_messages
      attr_accessor     :started_at, :ended_at
      attr_accessor     :records, :created, :updated
    end
    
    IMPORTERS = {".csv" => Contacts::Csv::Import, ".vcf" => Contacts::Vcard::Import}
    
    def initialize(account, user = nil)
      reset_counters
      @error_messages   = []
      @account          = account
      @user             = user || User.current_user
      raise ArgumentError, "No user identified, please set User.current_user or provide a user to Import#new" unless user
      User.current_user = user unless User.current_user   # For when we're running in delayed_job and no user is set
    end
   
    def import(file, options = {})
      @importer = importer_from_params(file, options)
      Lockfile.new account_lockfile do 
        reset_counters
        importer.started_at   = Time.now
        importer.import_file(file)
        importer.ended_at     = Time.now
        account.imports.create_from_importer(importer, options)
      end
      importer
    end
    
    # Rollback updates to contacts - either one at a time
    # or back to a particular point in time.  These are done in strict
    # reverse sequence.  Although mostly useful related to an import
    # activity not that this will 'undo' all updates whether through UI,
    # API or import
    def rollback(time = nil)
      Lockfile.new account_lockfile do
        ActiveRecord::Base.record_timestamps = false
        account.history.for_contacts.back_to(time).each {|history| rollback_one_row(history) }
      end
    ensure
      ActiveRecord::Base.record_timestamps = true      
    end
    
    def started_at
      @importer ? @importer.started_at : @started_at 
    end

    def ended_at
      @importer ? @importer.ended_at : @ended_at  
    end

    def errors
      @importer ? @importer.error_messages : @error_messages
    end
    
    def records
      @importer ? @importer.records : @records
    end
    
    def created
      @importer ? @importer.created : @created
    end
        
    def updated
      @importer ? @importer.updated : @updated
    end

    def user
      @importer ? @importer.user : @user
    end
       
    # Create a VCard from a hash
    # Standard import transformation - from a VCard we can import
    # to the database in the Contacts::VCard module
    def vcard_from_hash(record)
      card = Vpim::Vcard::Maker.make2 do |maker|
        
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
    
    #def inspect
    #  if started_at && ended_at
    #    puts "Imported #{records} records in about #{(ended_at - started_at).to_i} seconds with #{errors.size} messages."
    #  else
    #    puts "Importer ready."
    #  end
    #end
    
  private
    def rollback_one_row(history)
      # puts "Processing History##{history.id}"
      case history.attributes['transaction'] 
      when 'delete'
        item = object_from(history)
        item.send "attributes=", history.updates, false
        item.save!
      when 'create'
        if parent_record?(history)
          item = history.historical
          raise "Should have historical #{history.historical_type}:#{history.historical_id} but not found" unless item
          item.destroy
        end
      when 'update'
        item = history.historical
        history.updates.each do |attribute, changes|
          item.send "#{attribute}=", changes.first
        end
        item.save!
      else
        puts "[History] Unknown Transaction type: #{history.attributes['transaction']}"
      end
      history.destroy
    end      
    
    def importer_from_params(file, options)
      raise "File does not exist" unless File.exist?(file)
      extension = File.extname(file).downcase
      importer_class = IMPORTERS[extension]
      raise "Don't know how to import files of type #{File.extname(file)}" unless importer_class
      importer_class.new(account, user)
    end 
    
    def account_lockfile
      "#{Trackster::Config.lockfile_dir}/#{account.name}_contacts.lock"
    end 
    
    def parent_record?(history)
      history.historical_type == history.actionable_type && history.historical_id == history.actionable_id
    end
    
    def object_from(history)
      history.historical_type.constantize.new
    end
    
    def reset_counters
      if importer
        importer.records      = 0
        importer.created      = 0
        importer.updated      = 0
      else
        @records              = 0
        @created              = 0
        @updated              = 0
      end
    end
    
  end
end