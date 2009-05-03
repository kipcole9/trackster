class RenameTrackColumns < ActiveRecord::Migration
  def self.up
    rename_column :tracks, :site_id, :property_id
    rename_column :tracks, :site_code, :property_code
    rename_column :sessions, :site_id, :property_id
  end

  def self.down
  end
end
