class AddEmailClientToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :email_client, :string
  end

  def self.down
    remove_column :sessions, :email_client
  end
end
