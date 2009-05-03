class AddBrowserToTrack < ActiveRecord::Migration
  def self.up
    add_column :tracks, :os_name, :string, :limit => 10
  end

  def self.down
    remove_column :tracks, :os_name
  end
end
