class AddWebsites < ActiveRecord::Migration
  def self.up
    create_table "websites", :force => true do |t|
      t.integer  "contact_id"
      t.string   "kind",       :limit => 10
      t.string   "url"
      t.boolean  "preferred",                :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "websites", ["contact_id"], :name => "index_websites_on_contact_id"
  end

  def self.down
  end
end
