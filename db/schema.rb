# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090421224844) do

  create_table "tracks", :force => true do |t|
    t.integer  "site_id"
    t.string   "site_code",        :limit => 20
    t.string   "visitor",          :limit => 20
    t.string   "session",          :limit => 20
    t.string   "page_title"
    t.string   "screen_size",      :limit => 10
    t.string   "color_depth",      :limit => 5
    t.string   "language",         :limit => 10
    t.string   "charset",          :limit => 10
    t.string   "flash_version",    :limit => 10
    t.string   "unique_request",   :limit => 20
    t.string   "campaign_name"
    t.string   "campaign_source"
    t.string   "campaign_medium"
    t.string   "campaign_content"
    t.string   "url"
    t.string   "ip_address",       :limit => 20
    t.string   "referrer"
    t.string   "user_agent"
    t.string   "browser"
    t.string   "browser_version"
    t.string   "country",          :limit => 20
    t.string   "region",           :limit => 20
    t.string   "locality",         :limit => 20
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "tracked_at"
    t.datetime "geocoded_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count"
    t.integer  "duration"
    t.boolean  "outbound",                       :default => false
    t.integer  "visit"
    t.integer  "view"
    t.datetime "previous_session"
  end

end
