module Contacts
  class ImportExport
    attr_reader       :error_messages
    attr_reader       :importer
    
    IMPORTERS = {".csv" => Contacts::Csv, ".vcf" => Contacts::Vcard}
    
    def initialize
      # Only do this in the concrete subclasses
      @error_messages = [] unless self.class == ImportExport
    end
    
    def self.import(account, file)
      new.import(account, file)
      importer
    end
   
    def import(account, file)
      raise "Must provide account and file" unless account && !file.blank?
      raise "File does not exist" unless File.exist?(file)
      
      extension = File.extname(file)
      importer_class = IMPORTERS[extension]
      raise "Don't know how to import files of type #{File.extname(file)}" unless importer_class

      @importer = importer_class.new
      importer.import_file(account, file) if importer
    end
    
    def errors
      importer ? @importer.error_messages : error_messages
    end
  end
end