class AddGivenNameToUser < ActiveRecord::Migration
  def self.up
    rename_column :users, :name, :given_name
    add_column :users, :family_name, :string, :limit => 100
    add_column :users, :phone_number, :string, :limit => 50
  end

  def self.down
    rename_column :users, :given_name, :name
    remove_column :users, :family_name
    remove_column :users, :phone_number
  end
end
