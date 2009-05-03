class CreateRedirects < ActiveRecord::Migration
  def self.up
    create_table :redirects do |t|
      t.belongs_to        :account
      t.string            :name
      t.string            :url
      t.string            :event_category, :default => 'page'
      t.string            :event_action, :default => 'view'
      t.string            :event_label
      t.string            :event_value, :default => 0
      t.string            :redirect_url
      t.timestamps
    end
  end

  def self.down
    drop_table :redirects
  end
end
