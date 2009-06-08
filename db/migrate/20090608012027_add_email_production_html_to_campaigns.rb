class AddEmailProductionHtmlToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :email_production_html, :text
  end

  def self.down
    remove_column :campaigns, :email_production_html
  end
end
