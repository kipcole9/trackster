class AddMediumToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :medium, :string
  end

  def self.down
    remove_column :campaigns, :medium
  end
end
