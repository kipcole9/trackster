class ReduceSomeEventsColumnSizes < ActiveRecord::Migration
  def self.up
    change_column :events, :category, :string, :limit => 20
    change_column :events, :action, :string, :limit => 20
    change_column :events, :label, :string, :limit => 50
    change_column :events, :internal_search_terms, :string, :limit => 100
    
    change_column :sessions, :campaign_source, :string, :limit => 50
    change_column :sessions, :campaign_medium, :string, :limit => 50
    change_column :sessions, :campaign_content, :string, :limit => 50
    
    change_column :sessions, :locality, :string, :limit => 50
    change_column :sessions, :region, :string, :limit => 30
    change_column :sessions, :country, :string, :limit => 30
    
    change_column :sessions, :email_client, :string, :limit => 20
    change_column :sessions, :search_terms, :string, :limit => 100
  end

  def self.down
  end
end
