class RemovePropertyIdFromCampaign < ActiveRecord::Migration
  def self.up
    remove_column :campaigns, :property_id
  end

  def self.down
  end
end
