class AddSourceToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :source, :string
    add_column :campaigns, :content, :string
  end

  def self.down
    remove_column :campaigns, :content
    remove_column :campaigns, :source
  end
end
