class CreateViews < ActiveRecord::Migration
  def self.up
    create_table :views do |t|
      t.belongs_to      :session
      t.belongs_to      :track
      t.integer         :view_sequence
      t.string          :url
      t.string          :page_title
      t.string          :referrer
      t.datetime        :viewed_at      
      t.integer         :duration,      :default => 0
      t.boolean         :entry_page,    :default => 1
      t.boolean         :exit_page,     :default => 1
    end
  end

  def self.down
    drop_table :views
  end
end
