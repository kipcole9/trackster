module Contacts
  module Csv
    class Import < Contacts::ImportExport
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
        vcard = vcard_from_hash(record)
        import_vcard(account, vcard)
      end
    end
  end
end