class AddCustomDomainToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :custom_domain, :string, :limit => 100
    add_index :accounts, :custom_domain
  end

  def self.down
    remove_column :accounts, :custom_domain
  end
end
