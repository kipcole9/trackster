class RemoveLandingHtmlFromCampaigns < ActiveRecord::Migration
  def self.up
    remove_column :campaigns, :landing_html
  end

  def self.down
  end
end
