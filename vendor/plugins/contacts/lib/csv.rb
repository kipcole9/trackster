module Csv
  module Import
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
    
    module ClassMethods

      HEADER_CONVERTER = lambda { |header|
        normalized_column = header.gsub(/[ \-_]/,'').downcase
        I18n.t("contact_csv_headings.#{normalized_column}", :default => normalized_column).to_sym
      }
      
      def import_csv_file(csv_file)
        FasterCSV.foreach(csv_file, :headers => true, :header_converters => HEADER_CONVERTER) do |row|
          import_csv_record(row.to_hash)
        end
      end
      
      def import_csv_record(record)
        vcard = vcard_from_csv_hash(record)
        puts vcard.to_s
        #import_vcard(vcard)
      end
      
      def vcard_from_csv_hash(record)
        card = card = Vpim::Vcard::Maker.make2 do |maker|
          maker.add_name do |name|
            name.prefix = record[:name_prefix]        if record[:name_prefix]
            name.given  = record[:given_name]         if record[:given_name]
            name.family = record[:family_name]        if record[:family_name]
          end
          maker.add_addr do |addr|
            addr.preferred = true
            addr.location = 'work'
            addr.street = '12 Last Row, 13th Section'
            addr.locality = 'City of Lost Children'
            addr.country = 'Cinema'
          end
          maker.org     = record[:organization_name]  if record[:organization_name]
        end
      end
      
      
    end
    
    module InstanceMethods
      
    end
  end  
end