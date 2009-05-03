class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.belongs_to        :site               # Required
      t.belongs_to        :campaign           # Only for campaigns
      t.string            :visitor,           :limit => 20
      t.integer           :visit,             :default => 0
      t.string            :session,           :limit => 20
      t.integer           :event_count     
      t.string            :browser,           :limit => 20        
      t.string            :browser_version,   :limit => 10
      t.string            :language,          :limit => 10
      t.string            :screen_size,       :limit => 10
      t.integer           :color_depth,       :limit => 2
      t.string            :charset,           :limit => 10
      t.string            :os_name,           :limit => 20
      t.string            :os_version,        :limit => 10
      t.string            :flash_version,     :limit => 10
      t.string            :campaign_name,     :limit => 50
      t.string            :campaign_source
      t.string            :campaign_medium
      t.string            :campaign_content
      t.string            :ip_address,        :limit => 20
      t.string            :locality
      t.string            :region
      t.string            :country
      t.float             :latitude
      t.float             :longitude
      t.integer           :duration,          :default => 0
      t.datetime          :started_at
      t.datetime          :ended_at
    end
  end

  def self.down
    drop_table :sessions
  end
end
