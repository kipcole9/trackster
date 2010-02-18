class AddContactCodeToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :contact_code, :string, :limit => 50
    add_index :contacts, [:account_id, :contact_code], :unique => true
  end

  def self.down
    remove_column :contacts, :contact_code
  end
end
