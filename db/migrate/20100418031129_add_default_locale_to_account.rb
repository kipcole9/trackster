class AddDefaultLocaleToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :default_locale, :string, :limit => 10
  end

  def self.down
    remove_column :accounts, :default_locale
  end
end
