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

ActiveRecord::Schema.define(:version => 20090613051548) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", :force => true do |t|
    t.integer  "contact_id"
    t.string   "street"
    t.string   "locality"
    t.string   "country"
    t.string   "postalcode", :limit => 10
    t.string   "kind",       :limit => 10
    t.string   "region"
    t.boolean  "preferred",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["contact_id"], :name => "index_addresses_on_contact_id"

  create_table "affiliations", :force => true do |t|
    t.integer "contact_id"
    t.string  "type",         :limit => 10
    t.integer "affiliate_id"
  end

  add_index "affiliations", ["affiliate_id"], :name => "index_affiliations_on_affiliate_id"
  add_index "affiliations", ["contact_id"], :name => "index_affiliations_on_contact_id"

  create_table "campaigns", :force => true do |t|
    t.integer  "property_id"
    t.integer  "account_id"
    t.string   "name"
    t.text     "description"
    t.text     "email_html"
    t.text     "landing_page_html"
    t.integer  "cost"
    t.integer  "distribution"
    t.integer  "bounces"
    t.integer  "unsubscribes"
    t.string   "code",                  :limit => 10
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "effective_at"
    t.text     "email_production_html"
    t.boolean  "preview_available"
    t.string   "image_directory"
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

  create_table "comments", :force => true do |t|
    t.string   "title",            :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contacts", :force => true do |t|
    t.string   "given_name"
    t.string   "family_name"
    t.string   "salutation",         :limit => 30
    t.string   "nickname",           :limit => 20
    t.string   "name",               :limit => 100
    t.string   "locale",             :limit => 50
    t.string   "timezone",           :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.string   "role"
    t.string   "profile"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
    t.string   "gender",             :limit => 10,  :default => "unknown"
    t.string   "role_function",      :limit => 50
    t.string   "role_level",         :limit => 50
    t.string   "name_order",         :limit => 2
    t.string   "honorific_prefix",   :limit => 50
    t.string   "honorific_suffix",   :limit => 50
    t.string   "type"
    t.integer  "employees"
    t.integer  "revenue"
  end

  add_index "contacts", ["family_name"], :name => "index_contacts_on_family_name"
  add_index "contacts", ["given_name"], :name => "index_contacts_on_given_name"
  add_index "contacts", ["name"], :name => "index_contacts_on_name"

  create_table "countries", :force => true do |t|
    t.string "name", :limit => 48, :default => "", :null => false
    t.string "code", :limit => 2,  :default => "", :null => false
  end

  add_index "countries", ["name"], :name => "kCountry"

  create_table "emails", :force => true do |t|
    t.integer  "contact_id"
    t.string   "address"
    t.string   "kind",       :limit => 10
    t.boolean  "preferred",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["contact_id"], :name => "index_emails_on_contact_id"

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
    t.integer  "duration"
  end

  create_table "files", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_members", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "histories", :force => true do |t|
    t.text     "updates"
    t.integer  "created_by"
    t.string   "historical_type"
    t.integer  "historical_id"
    t.string   "transaction"
    t.datetime "created_at"
    t.string   "actionable_type", :limit => 20
    t.integer  "actionable_id"
  end

  create_table "instant_messengers", :force => true do |t|
    t.integer "contact_id"
    t.string  "type",       :limit => 10
    t.string  "address"
    t.boolean "preferred",                :default => false
  end

  add_index "instant_messengers", ["contact_id"], :name => "index_instant_messengers_on_contact_id"

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

  create_table "logged_exceptions", :force => true do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.datetime "created_at"
  end

  create_table "notes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "note"
    t.string   "notable_type", :limit => 20
    t.integer  "notable_id"
    t.integer  "updated_by"
    t.integer  "created_by"
    t.date     "related_date"
  end

  create_table "phones", :force => true do |t|
    t.integer  "contact_id"
    t.string   "kind",       :limit => 10
    t.string   "number",     :limit => 50
    t.boolean  "preferred",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phones", ["contact_id"], :name => "index_phones_on_contact_id"

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

  create_table "recipients", :force => true do |t|
    t.string   "salutation"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
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
    t.string   "user_agent"
    t.integer  "local_hour",        :limit => 2
    t.boolean  "lon_local_time",                   :default => false
    t.string   "device",            :limit => 50
    t.string   "device_vendor",     :limit => 50
    t.string   "referrer_category", :limit => 50
    t.integer  "impressions"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "team_members", :force => true do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.text     "description"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "parent_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
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
