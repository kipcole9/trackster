class AddCreatedAtToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :created_at, :datetime
  end

  def self.down
  end
end
