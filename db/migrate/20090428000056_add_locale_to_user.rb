class AddLocaleToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :locale, :string
    add_column :users, :timezone, :string
  end

  def self.down
    remove_column :users, :timezone
    remove_column :users, :locale
  end
end
