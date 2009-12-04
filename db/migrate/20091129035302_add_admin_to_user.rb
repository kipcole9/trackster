class AddAdminToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :administrator, :boolean
  end

  def self.down
    remove_column :users, :administrator
  end
end
