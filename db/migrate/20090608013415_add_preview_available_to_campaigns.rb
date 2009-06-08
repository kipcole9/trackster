class AddPreviewAvailableToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :preview_available, :boolean
  end

  def self.down
    remove_column :campaigns, :preview_available
  end
end
