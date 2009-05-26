class RemoveSummaryColumnsFromCampaign < ActiveRecord::Migration
  def self.up
    remove_column :campaigns, :impressions
    remove_column :campaigns, :clicks_through
    remove_column :campaigns, :results_at
  end

  def self.down
  end
end
