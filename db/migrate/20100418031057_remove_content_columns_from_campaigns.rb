class RemoveContentColumnsFromCampaigns < ActiveRecord::Migration
  def self.up
    remove_column :campaigns, :email_html
    remove_column :campaigns, :landing_page_html
    add_column :campaigns, :content_id, :integer
  end

  def self.down
  end
end
