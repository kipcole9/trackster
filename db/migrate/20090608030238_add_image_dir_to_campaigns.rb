class AddImageDirToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :image_directory, :string
  end

  def self.down
    remove_column :campaigns, :image_directory
  end
end
