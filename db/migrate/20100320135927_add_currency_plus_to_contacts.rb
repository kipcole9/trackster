class AddCurrencyPlusToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :currency_code, :string, :limit => 3
    add_column :contacts, :industry, :string, :limit => 100
    add_column :contacts, :industry_code, :string, :limit => 5
    add_column :contacts, :birthday, :date
  end

  def self.down
    remove_column :contacts, :birthday
    remove_column :contacts, :industry_code
    remove_column :contacts, :industry
    remove_column :contacts, :currency_code
  end
end
