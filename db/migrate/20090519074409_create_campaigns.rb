class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      t.belongs_to      :property     # The web site this campaign relates to 
      t.belongs_to      :account      # The account that owns the campaign
      t.string          :name         # Campaign name 
      t.text            :description  # and description
      
      # HTML from the designer, then with link tagging
      t.text            :design_html      # From the designer
      t.text            :production_html  # After link tagging
      
      # Metrics manually entered from original sources
      t.integer         :cost             # Customer cost of campaign
      t.integer         :distribution     # How many sent
      t.integer         :bounces          # How many bounced
      t.integer         :unsubscribes     # How many unsubscribed
      
      # Generated - for use in email tagging
      t.integer         :code             # For the utac in the url
      
      # Results - cached results
      t.integer         :impressions      # How many opens
      t.integer         :clicks_through   # Clicks through
      t.datetime        :results_at       # When this data was last updated
      
      # Ownership
      t.integer         :created_by       # Who created the campaign
      t.integer         :updated_by       # and who updated it
      
      t.timestamps
    end
  end

  def self.down
    drop_table :campaigns
  end
end
