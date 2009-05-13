class AddPropertyIdToRedirect < ActiveRecord::Migration
  def self.up
    add_column :redirects, :property_id, :integer
  end

  def self.down
    remove_column :redirects, :property_id
  end
end
