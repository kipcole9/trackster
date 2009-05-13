class AddRedirectIdToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :redirect_id, :integer
  end

  def self.down
    remove_column :events, :redirect_id
  end
end
