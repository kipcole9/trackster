class AddTimezoneToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :timezone, :string, :limit => 20
    add_column :accounts, :salutation, :string, :limit => 100
    add_column :accounts, :currency_code, :string, :limit => 3
  end

  def self.down
  end
end
