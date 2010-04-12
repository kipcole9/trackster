module Contacts
  module Csv
    class Import < Contacts::Vcard::Import
      HEADER_CONVERTER = lambda { |header|
        normalized_column = header.gsub(/[ \-_]/,'').downcase
        I18n.t("contact_csv_headings.#{normalized_column}", :default => normalized_column).to_sym
      }
    
      def import_file(csv_file)
        FasterCSV.foreach(csv_file, :headers => true, :header_converters => HEADER_CONVERTER) do |row|
          import_csv_record(row.to_hash)
        end
        error_messages.flatten!.compact!
      end
    
      def import_csv_record(record)
        vcard = vcard_from_hash(record)
        import_vcard(vcard)
      end
    end
  end
end