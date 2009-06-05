class AddEffectiveAtToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :effective_at, :datetime
  end

  def self.down
    remove_column :campaigns, :effective_at
  end
end
