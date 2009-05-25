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

ActiveRecord::Schema.define(:version => 20090525053401) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns", :force => true do |t|
    t.integer  "property_id"
    t.integer  "account_id"
    t.string   "name"
    t.text     "description"
    t.text     "design_html"
    t.text     "production_html"
    t.text     "landing_page_html"
    t.integer  "cost"
    t.integer  "distribution"
    t.integer  "bounces"
    t.integer  "unsubscribes"
    t.integer  "code"
    t.integer  "impressions"
    t.integer  "clicks_through"
    t.datetime "results_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cityByCountry", :primary_key => "city", :force => true do |t|
    t.integer "country",                :default => 0,  :null => false
    t.string  "name",    :limit => 200, :default => "", :null => false
    t.float   "lat"
    t.float   "lng"
    t.string  "state",   :limit => 64,  :default => "", :null => false
  end

  add_index "cityByCountry", ["country"], :name => "kCountry"
  add_index "cityByCountry", ["name"], :name => "kName"

  create_table "countries", :force => true do |t|
    t.string "name", :limit => 48, :default => "", :null => false
    t.string "code", :limit => 2,  :default => "", :null => false
  end

  add_index "countries", ["name"], :name => "kCountry"

  create_table "events", :force => true do |t|
    t.integer  "session_id"
    t.integer  "sequence"
    t.string   "url"
    t.string   "page_title"
    t.datetime "tracked_at"
    t.boolean  "entry_page",            :default => true
    t.boolean  "exit_page",             :default => true
    t.datetime "created_at"
    t.string   "category"
    t.string   "action"
    t.string   "label"
    t.float    "value"
    t.string   "internal_search_terms"
    t.integer  "redirect_id"
  end

  create_table "ip4", :id => false, :force => true do |t|
    t.integer   "ip",                   :default => 0, :null => false
    t.integer   "country", :limit => 2, :default => 0, :null => false
    t.integer   "city",    :limit => 2, :default => 0, :null => false
    t.timestamp "cron",                                :null => false
  end

  add_index "ip4", ["city"], :name => "kCity"
  add_index "ip4", ["country"], :name => "kCountry"
  add_index "ip4", ["cron"], :name => "kcron"
  add_index "ip4", ["ip"], :name => "kIP"

  create_table "properties", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.text     "description"
    t.string   "tracker"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "search_parameter"
  end

  create_table "property_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "redirects", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.string   "url"
    t.string   "category",     :default => "page"
    t.string   "action",       :default => "view"
    t.string   "label"
    t.string   "value",        :default => "0"
    t.string   "redirect_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "property_id"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "search_engines", :force => true do |t|
    t.string   "host"
    t.string   "query_param", :limit => 50
    t.string   "country",     :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_engines", ["host"], :name => "index_search_engines_on_host", :unique => true

  create_table "sessions", :force => true do |t|
    t.integer  "property_id"
    t.integer  "campaign_id"
    t.string   "visitor",           :limit => 20
    t.integer  "visit",                            :default => 0
    t.string   "session",           :limit => 20
    t.integer  "event_count"
    t.string   "browser",           :limit => 20
    t.string   "browser_version",   :limit => 10
    t.string   "language",          :limit => 10
    t.string   "screen_size",       :limit => 10
    t.integer  "color_depth",       :limit => 2
    t.string   "charset",           :limit => 10
    t.string   "os_name",           :limit => 20
    t.string   "os_version",        :limit => 10
    t.string   "flash_version",     :limit => 10
    t.string   "campaign_name",     :limit => 50
    t.string   "campaign_source"
    t.string   "campaign_medium"
    t.string   "campaign_content"
    t.string   "ip_address",        :limit => 20
    t.string   "locality"
    t.string   "region"
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "duration",                         :default => 0
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "geocoded_at"
    t.datetime "created_at"
    t.integer  "page_views"
    t.datetime "previous_visit_at"
    t.integer  "count"
    t.integer  "account_id"
    t.boolean  "mobile_device"
    t.string   "referrer"
    t.string   "referrer_host",     :limit => 100
    t.string   "search_terms"
    t.string   "traffic_source",    :limit => 50
    t.date     "date"
    t.integer  "day"
    t.integer  "year"
    t.integer  "month"
    t.integer  "hour"
    t.integer  "week"
    t.integer  "day_of_week",       :limit => 1
    t.integer  "timezone",          :limit => 3
  end

  create_table "tracks", :force => true do |t|
    t.integer  "property_id"
    t.integer  "campaign_id"
    t.string   "visitor",               :limit => 20
    t.integer  "visit",                                :default => 0
    t.string   "session",               :limit => 20
    t.integer  "event_count"
    t.string   "browser",               :limit => 20
    t.string   "browser_version",       :limit => 10
    t.string   "language",              :limit => 10
    t.string   "screen_size",           :limit => 10
    t.integer  "color_depth",           :limit => 2
    t.string   "charset",               :limit => 10
    t.string   "os_name",               :limit => 20
    t.string   "os_version",            :limit => 10
    t.string   "flash_version",         :limit => 10
    t.string   "campaign_name",         :limit => 50
    t.string   "campaign_source"
    t.string   "campaign_medium"
    t.string   "campaign_content"
    t.string   "ip_address",            :limit => 20
    t.string   "locality"
    t.string   "region"
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "duration",                             :default => 0
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "geocoded_at"
    t.integer  "page_views"
    t.datetime "previous_visit_at"
    t.integer  "count"
    t.integer  "account_id"
    t.boolean  "mobile_device"
    t.string   "referrer"
    t.string   "referrer_host",         :limit => 100
    t.string   "search_terms"
    t.string   "traffic_source",        :limit => 50
    t.integer  "session_id"
    t.integer  "sequence"
    t.string   "url"
    t.string   "page_title"
    t.datetime "tracked_at"
    t.boolean  "entry_page",                           :default => true
    t.boolean  "exit_page",                            :default => true
    t.string   "category"
    t.string   "action"
    t.string   "label"
    t.float    "value"
    t.string   "internal_search_terms"
    t.integer  "redirect_id"
  end

  create_table "traffic_sources", :force => true do |t|
    t.integer  "account_id"
    t.string   "host"
    t.string   "source_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "given_name",                :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
    t.string   "locale"
    t.string   "timezone"
    t.integer  "account_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "family_name",               :limit => 100
    t.string   "phone_number",              :limit => 50
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
