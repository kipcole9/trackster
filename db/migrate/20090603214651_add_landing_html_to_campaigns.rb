class AddLandingHtmlToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :landing_html, :text
    remove_column :campaigns, :production_html
    rename_column :campaigns, :design_html, :email_html
  end

  def self.down
    remove_column :campaigns, :landing_html
  end
end
