class AddCreatedAtToView < ActiveRecord::Migration
  def self.up
    add_column :views, :created_at, :datetime
  end

  def self.down
    remove_column :views, :created_at
  end
end
