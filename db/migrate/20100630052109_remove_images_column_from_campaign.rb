class RemoveImagesColumnFromCampaign < ActiveRecord::Migration
  def self.up
    remove_column :campaigns, :image_directory
  end

  def self.down
  end
end
