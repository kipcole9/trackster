class Import < ActiveRecord::Base
  belongs_to      :account
  serialize       :messages
  
  validates_presence_of      :account_id
  validates_associated       :account

  def self.create_from_importer(importer, options)
    create!(:description => options[:description], 
         :records => importer.records, :created => importer.created, :updated => importer.updated,
         :started_at => importer.started_at, :ended_at => importer.ended_at, 
         :messages => importer.errors, 
         :original_file => options[:original_file],
         :created_by => importer.user)
  end
end
