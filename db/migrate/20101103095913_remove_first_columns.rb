class RemoveFirstColumns < ActiveRecord::Migration
  def self.up
    remove_column :sessions, :first_impression
    remove_column :sessions, :first_click
  end

  def self.down
  end
end
