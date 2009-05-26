class ChangeCodeToStringInCampaigns < ActiveRecord::Migration
  def self.up
    change_column :campaigns, :code, :string, :limit => 10
  end

  def self.down
  end
end
