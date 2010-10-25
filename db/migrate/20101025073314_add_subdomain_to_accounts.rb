class AddSubdomainToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :subdomain, :string, :limit => 20
    add_column :accounts, :default_campaign_days, :integer, :default => 30
    add_index :accounts, :subdomain, :unique => true
    
    add_column :campaigns, :concludes_at, :datetime
    
    Account.all.each do |account|
      account.subdomain = account.name
      account.save!
    end
    
  end

  def self.down
    remove_column :accounts, :default_campaign_days
    remove_column :accounts, :subdomain
    
    remove_column :campaigns, :concludes_at
  end
end
