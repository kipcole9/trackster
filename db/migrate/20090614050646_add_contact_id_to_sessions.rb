class AddContactIdToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :contact_code, :string, :limit => 50
    add_column :events, :contact_code, :string, :limit => 50
  end

  def self.down
    remove_column :sessions, :contact_code
    remove_column :events, :contact_code
  end
end
