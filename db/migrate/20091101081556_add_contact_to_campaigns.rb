class AddContactToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :contact_code, :string
  end

  def self.down
    remove_column :campaigns, :contact_code
  end
end
