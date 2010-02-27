class AddKeysOntoCoreTables < ActiveRecord::Migration
  def self.up
    change_column :accounts, :name, :string, :limit => 20
    change_column :contacts, :type, :string, :limit => 20
    add_index :accounts,    :name, :unique => true
    add_index :properties,  :account_id
    add_index :campaigns,   :account_id
    add_index :contacts,    :family_name
    add_index :accounts,    :agent_id
  end

  def self.down
    remove_index :accounts,   :name
    remove_index :properties, :account_id
    remove_index :campaigns,  :account_id
    remove_index :contacts,   :family_name
    remove_index :accounts,   :agent_id
  end
end
