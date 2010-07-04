class RemoveProductionHtmlFromCampaign < ActiveRecord::Migration
  def self.up
    remove_column :campaigns, :email_production_html
    remove_column :campaigns, :preview_available
  end

  def self.down
  end
end
