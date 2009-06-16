class AddThemeToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :theme, :string
  end

  def self.down
    remove_column :accounts, :theme
  end
end
