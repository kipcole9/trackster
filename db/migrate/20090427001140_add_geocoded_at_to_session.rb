class AddGeocodedAtToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :geocoded_at, :datetime
  end

  def self.down
    remove_column :sessions, :geocoded_at
  end
end
