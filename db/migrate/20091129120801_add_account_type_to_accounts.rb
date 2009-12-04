class AddAccountTypeToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :kind, :string, :limit => 10
  end

  def self.down
    remove_column :accounts, :kind
  end
end
