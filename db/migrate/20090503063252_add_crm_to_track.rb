class AddCrmToTrack < ActiveRecord::Migration
  def self.up
    add_column :tracks, :crm_contact, :string
  end

  def self.down
    remove_column :tracks, :crm_contact
  end
end
