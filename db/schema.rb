# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130221135909) do

  create_table "accounts", :force => true do |t|
    t.integer  "key_id"
    t.datetime "paid_until"
    t.datetime "create_date"
    t.integer  "logon_count"
    t.integer  "logon_minutes"
    t.integer  "user_id"
    t.datetime "cached_until"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["key_id"], :name => "index_accounts_on_key_id"
  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "activities", :primary_key => "activity_id", :force => true do |t|
    t.string  "name"
    t.integer "icon_no"
    t.string  "description"
    t.boolean "published"
  end

  create_table "alliances", :primary_key => "alliance_id", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.integer  "executor_corp_id"
    t.integer  "member_count"
    t.datetime "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alliances", ["name"], :name => "index_alliances_on_name"
  add_index "alliances", ["short_name"], :name => "index_alliances_on_short_name"

  create_table "api_keys", :force => true do |t|
    t.integer  "key_id"
    t.string   "vcode"
    t.integer  "access_mask"
    t.integer  "user_id"
    t.string   "key_type"
    t.datetime "expires"
    t.datetime "cached_until"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["key_id"], :name => "index_api_keys_on_key_id", :unique => true
  add_index "api_keys", ["user_id"], :name => "index_api_keys_on_user_id"

  create_table "api_logs", :force => true do |t|
    t.string   "resource_name"
    t.integer  "resource_id"
    t.integer  "key_id"
    t.datetime "ts"
    t.string   "status"
    t.datetime "cached_until"
  end

  create_table "attribute_categories", :primary_key => "category_id", :force => true do |t|
    t.string "name",        :limit => 50
    t.string "description", :limit => 200
  end

  create_table "attribute_types", :primary_key => "attribute_id", :force => true do |t|
    t.string  "name",          :limit => 100
    t.string  "description",   :limit => 1000
    t.integer "icon_id"
    t.float   "default_value"
    t.boolean "published"
    t.string  "display_name",  :limit => 100
    t.integer "unit_id"
    t.boolean "stackable"
    t.boolean "high_is_good"
    t.integer "category_id"
  end

  add_index "attribute_types", ["category_id"], :name => "index_attribute_types_on_category_id"
  add_index "attribute_types", ["unit_id"], :name => "index_attribute_types_on_unit_id"

  create_table "blueprint_types", :primary_key => "type_id", :force => true do |t|
    t.integer "product_type_id"
    t.integer "production_time"
    t.integer "tech_level"
    t.integer "research_productivity_time"
    t.integer "research_material_time"
    t.integer "research_copy_time"
    t.integer "research_tech_time"
    t.integer "productivity_modifier"
    t.integer "material_modifier"
    t.integer "waste_factor"
    t.integer "max_production_limit"
  end

  add_index "blueprint_types", ["product_type_id"], :name => "index_blueprint_types_on_product_type_id"

  create_table "categories", :primary_key => "category_id", :force => true do |t|
    t.string  "name",        :limit => 100
    t.string  "description", :limit => 3000
    t.integer "icon_id"
    t.boolean "published"
  end

  create_table "character_assets", :id => false, :force => true do |t|
    t.integer  "character_id"
    t.integer  "item_id",         :limit => 8, :null => false
    t.integer  "solar_system_id"
    t.integer  "station_id"
    t.integer  "type_id"
    t.integer  "quantity"
    t.integer  "flag"
    t.boolean  "singleton"
    t.integer  "raw_quantity"
    t.integer  "parent_id",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "character_assets", ["character_id"], :name => "index_character_assets_on_character_id"
  add_index "character_assets", ["parent_id"], :name => "index_character_assets_on_parent_id"
  add_index "character_assets", ["solar_system_id"], :name => "index_character_assets_on_solar_system_id"
  add_index "character_assets", ["station_id"], :name => "index_character_assets_on_station_id"
  add_index "character_assets", ["type_id"], :name => "index_character_assets_on_type_id"

  create_table "character_skills", :force => true do |t|
    t.integer "character_id"
    t.integer "type_id"
    t.integer "skill_points"
    t.integer "level"
    t.boolean "published",    :default => true
  end

  add_index "character_skills", ["character_id"], :name => "index_character_skills_on_character_id"
  add_index "character_skills", ["type_id"], :name => "index_character_skills_on_type_id"

  create_table "characters", :primary_key => "character_id", :force => true do |t|
    t.integer  "key_id"
    t.string   "name"
    t.datetime "dob"
    t.string   "race"
    t.string   "bloodline"
    t.string   "ancestry"
    t.string   "gender"
    t.integer  "corporation_id"
    t.integer  "alliance_id"
    t.string   "clone_name"
    t.integer  "clone_sp"
    t.integer  "balance",        :limit => 8
    t.boolean  "hidden",                      :default => false
    t.integer  "intelligence"
    t.integer  "memory"
    t.integer  "charisma"
    t.integer  "perception"
    t.integer  "willpower"
    t.datetime "cached_until"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "characters", ["alliance_id"], :name => "index_characters_on_alliance_id"
  add_index "characters", ["corporation_id"], :name => "index_characters_on_corporation_id"

  create_table "constellations", :primary_key => "constellation_id", :force => true do |t|
    t.string  "name",       :limit => 100
    t.integer "region_id"
    t.integer "faction_id"
  end

  add_index "constellations", ["faction_id"], :name => "index_constellations_on_faction_id"
  add_index "constellations", ["name"], :name => "index_constellations_on_name"
  add_index "constellations", ["region_id"], :name => "index_constellations_on_region_id"

  create_table "corporations", :primary_key => "corporation_id", :force => true do |t|
    t.string   "name"
    t.string   "ticker",       :limit => 5
    t.string   "description",  :limit => 4000
    t.string   "url"
    t.integer  "ceo_id"
    t.string   "ceo_name"
    t.integer  "member_count"
    t.integer  "member_limit"
    t.integer  "shares",       :limit => 8
    t.float    "tax_rate"
    t.integer  "graphic_id"
    t.integer  "station_id"
    t.integer  "alliance_id"
    t.datetime "cached_until"
    t.datetime "updated_at"
    t.boolean  "npc",                          :default => false
  end

  add_index "corporations", ["alliance_id"], :name => "index_corporations_on_alliance_id"
  add_index "corporations", ["name"], :name => "index_corporations_on_name"
  add_index "corporations", ["station_id"], :name => "index_corporations_on_station_id"
  add_index "corporations", ["ticker"], :name => "index_corporations_on_ticker"

  create_table "eve_central_imports", :force => true do |t|
    t.string   "filename"
    t.datetime "start"
    t.datetime "stop"
    t.integer  "rows"
    t.string   "status"
    t.string   "error"
  end

  add_index "eve_central_imports", ["filename"], :name => "index_eve_central_imports_on_filename"
  add_index "eve_central_imports", ["start"], :name => "index_eve_central_imports_on_start"
  add_index "eve_central_imports", ["status"], :name => "index_eve_central_imports_on_status"
  add_index "eve_central_imports", ["stop"], :name => "index_eve_central_imports_on_stop"

  create_table "factions", :primary_key => "faction_id", :force => true do |t|
    t.string  "name",                   :limit => 100
    t.string  "description",            :limit => 1000
    t.integer "solar_system_id"
    t.integer "corporation_id"
    t.integer "station_count"
    t.integer "station_system_count"
    t.integer "militia_corporation_id"
    t.integer "icon_id"
  end

  add_index "factions", ["corporation_id"], :name => "index_factions_on_corporation_id"
  add_index "factions", ["militia_corporation_id"], :name => "index_factions_on_militia_corporation_id"
  add_index "factions", ["name"], :name => "index_factions_on_name", :unique => true
  add_index "factions", ["solar_system_id"], :name => "index_factions_on_solar_system_id"

  create_table "flags", :primary_key => "flag_id", :force => true do |t|
    t.string "name", :limit => 200
    t.string "text", :limit => 100
  end

  create_table "groups", :primary_key => "group_id", :force => true do |t|
    t.integer "category_id"
    t.string  "name",                   :limit => 100
    t.string  "description",            :limit => 3000
    t.integer "icon_id"
    t.boolean "use_base_price"
    t.boolean "allow_manufacture"
    t.boolean "allow_recycler"
    t.boolean "anchored"
    t.boolean "anchorable"
    t.boolean "fittable_non_singleton"
    t.boolean "published"
  end

  add_index "groups", ["category_id"], :name => "index_groups_on_category_id"

  create_table "market_groups", :primary_key => "market_group_id", :force => true do |t|
    t.integer "parent_group_id"
    t.string  "name",            :limit => 100
    t.string  "description",     :limit => 3000
    t.integer "icon_id"
    t.boolean "has_types"
  end

  create_table "meta_groups", :primary_key => "meta_group_id", :force => true do |t|
    t.string  "name",        :limit => 100
    t.string  "description", :limit => 3000
    t.integer "icon_id"
  end

  create_table "meta_types", :primary_key => "type_id", :force => true do |t|
    t.integer "parent_type_id"
    t.integer "meta_group_id"
  end

  add_index "meta_types", ["meta_group_id"], :name => "index_meta_types_on_meta_group_id"

  create_table "mining_log", :force => true do |t|
    t.integer  "character_id"
    t.datetime "start_ts"
    t.datetime "stop_ts"
    t.string   "name"
    t.string   "comments"
  end

  add_index "mining_log", ["character_id"], :name => "index_mining_log_on_character_id"

  create_table "order_histories", :force => true do |t|
    t.integer  "type_id"
    t.integer  "region_id"
    t.integer  "orders"
    t.integer  "quantity",    :limit => 8
    t.float    "low"
    t.float    "high"
    t.float    "average"
    t.datetime "ts"
    t.string   "gen_name"
    t.string   "gen_version"
    t.boolean  "outlier",                  :default => false
  end

  add_index "order_histories", ["type_id", "region_id", "ts"], :name => "index_order_histories_on_type_id_and_region_id_and_ts", :unique => true

  create_table "order_logs", :force => true do |t|
    t.integer  "order_id",    :limit => 8
    t.decimal  "price"
    t.integer  "vol_remain"
    t.datetime "reported_ts"
    t.string   "gen_name"
    t.string   "gen_version"
  end

  add_index "order_logs", ["order_id", "reported_ts"], :name => "index_order_logs_on_order_id_and_reported_ts", :unique => true

  create_table "order_stats", :force => true do |t|
    t.integer  "type_id"
    t.integer  "region_id"
    t.float    "median"
    t.float    "max_buy"
    t.float    "min_sell"
    t.float    "mid_buy_sell"
    t.integer  "buy_vol",      :limit => 8
    t.integer  "sell_vol",     :limit => 8
    t.float    "sim_buy"
    t.float    "sim_sell"
    t.datetime "ts"
    t.float    "weighted_avg"
  end

  add_index "order_stats", ["region_id"], :name => "index_order_stats_on_region_id"
  add_index "order_stats", ["type_id", "region_id", "ts"], :name => "index_order_stats_on_type_id_and_region_id_and_ts"
  add_index "order_stats", ["type_id"], :name => "index_order_stats_on_type_id"

  create_table "orders", :id => false, :force => true do |t|
    t.integer  "order_id",        :limit => 8,                    :null => false
    t.integer  "type_id"
    t.boolean  "bid"
    t.integer  "region_id"
    t.integer  "solar_system_id"
    t.integer  "station_id"
    t.decimal  "price"
    t.integer  "min_vol"
    t.integer  "vol_remain"
    t.integer  "vol_enter"
    t.integer  "range"
    t.integer  "duration"
    t.datetime "issued"
    t.datetime "expires"
    t.datetime "reported_ts"
    t.string   "gen_name"
    t.string   "gen_version"
    t.boolean  "outlier",                      :default => false
  end

  add_index "orders", ["price", "bid", "type_id", "expires", "reported_ts"], :name => "index_orders_on_bid_and_type_and_expires_and_reported"
  add_index "orders", ["solar_system_id"], :name => "index_orders_on_solar_system_id"
  add_index "orders", ["type_id", "expires", "reported_ts"], :name => "index_orders_on_type_and_and_expires_and_reported"
  add_index "orders", ["type_id", "region_id", "expires", "reported_ts"], :name => "index_orders_on_type_and_region_and_expires_and_reported"

  create_table "regions", :primary_key => "region_id", :force => true do |t|
    t.string  "name",       :limit => 100
    t.integer "faction_id"
    t.boolean "has_hub",                   :default => false
  end

  add_index "regions", ["faction_id"], :name => "index_regions_on_faction_id"
  add_index "regions", ["name"], :name => "index_regions_on_name"

  create_table "skill_in_training", :force => true do |t|
    t.integer  "character_id"
    t.integer  "type_id"
    t.integer  "start_sp"
    t.integer  "destination_sp"
    t.integer  "to_level"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "reported_ts"
  end

  add_index "skill_in_training", ["character_id"], :name => "index_skill_in_training_on_character_id"

  create_table "solar_system_stats", :force => true do |t|
    t.integer  "solar_system_id"
    t.integer  "ship_kills",      :default => 0
    t.integer  "pod_kills",       :default => 0
    t.integer  "faction_kills",   :default => 0
    t.integer  "ship_jumps",      :default => 0
    t.datetime "ts"
  end

  add_index "solar_system_stats", ["solar_system_id"], :name => "index_solar_system_stats_on_solar_system_id"
  add_index "solar_system_stats", ["ts", "solar_system_id"], :name => "index_solar_system_stats_on_ts_and_solar_system_id", :unique => true

  create_table "solar_systems", :primary_key => "solar_system_id", :force => true do |t|
    t.string  "name",             :limit => 100
    t.integer "region_id"
    t.integer "constellation_id"
    t.integer "faction_id"
    t.float   "security"
    t.string  "security_class"
    t.boolean "border"
    t.boolean "fringe"
    t.boolean "corridor"
    t.boolean "hub"
    t.boolean "international"
    t.boolean "regional"
    t.boolean "constellational"
  end

  add_index "solar_systems", ["constellation_id"], :name => "index_solar_systems_on_constellation_id"
  add_index "solar_systems", ["faction_id"], :name => "index_solar_systems_on_faction_id"
  add_index "solar_systems", ["name"], :name => "index_solar_systems_on_name"
  add_index "solar_systems", ["region_id"], :name => "index_solar_systems_on_region_id"

  create_table "sovereignties", :primary_key => "solar_system_id", :force => true do |t|
    t.integer  "alliance_id"
    t.integer  "corporation_id"
    t.integer  "faction_id"
    t.datetime "data_time"
  end

  add_index "sovereignties", ["alliance_id"], :name => "index_sovereignties_on_alliance_id"
  add_index "sovereignties", ["corporation_id"], :name => "index_sovereignties_on_corporation_id"
  add_index "sovereignties", ["faction_id"], :name => "index_sovereignties_on_faction_id"

  create_table "sovereignty_histories", :force => true do |t|
    t.integer  "solar_system_id"
    t.integer  "alliance_id"
    t.integer  "corporation_id"
    t.integer  "faction_id"
    t.datetime "data_time"
  end

  add_index "sovereignty_histories", ["alliance_id"], :name => "index_sovereignty_histories_on_alliance_id"
  add_index "sovereignty_histories", ["corporation_id"], :name => "index_sovereignty_histories_on_corporation_id"
  add_index "sovereignty_histories", ["faction_id"], :name => "index_sovereignty_histories_on_faction_id"
  add_index "sovereignty_histories", ["solar_system_id", "data_time"], :name => "index_sovereignty_histories_on_solar_system_id_and_data_time", :unique => true
  add_index "sovereignty_histories", ["solar_system_id"], :name => "index_sovereignty_histories_on_solar_system_id"

  create_table "station_types", :primary_key => "station_type_id", :force => true do |t|
    t.integer "dock_entry_x"
    t.integer "dock_entry_y"
    t.integer "dock_entry_z"
    t.integer "dock_orientation_x"
    t.integer "dock_orientation_y"
    t.integer "dock_orientation_z"
    t.integer "operation_id"
    t.integer "office_slots"
    t.integer "reprocessing_efficiency"
    t.boolean "conquerable"
  end

  create_table "stations", :primary_key => "station_id", :force => true do |t|
    t.string   "name",             :limit => 100
    t.integer  "solar_system_id"
    t.integer  "constellation_id"
    t.integer  "region_id"
    t.integer  "corporation_id"
    t.integer  "station_type_id"
    t.float    "reprocess_eff"
    t.float    "reprocess_take"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stations", ["constellation_id"], :name => "index_stations_on_constellation_id"
  add_index "stations", ["corporation_id"], :name => "index_stations_on_corporation_id"
  add_index "stations", ["name"], :name => "index_stations_on_name"
  add_index "stations", ["region_id"], :name => "index_stations_on_region_id"
  add_index "stations", ["solar_system_id"], :name => "index_stations_on_solar_system_id"
  add_index "stations", ["station_type_id"], :name => "index_stations_on_station_type_id"

  create_table "type_attributes", :id => false, :force => true do |t|
    t.integer "type_id",      :null => false
    t.integer "attribute_id", :null => false
    t.integer "value_int"
    t.float   "value_float"
  end

  add_index "type_attributes", ["type_id"], :name => "index_type_attributes_on_type_id"

  create_table "type_materials", :id => false, :force => true do |t|
    t.integer "type_id",          :null => false
    t.integer "material_type_id", :null => false
    t.integer "quantity"
  end

  add_index "type_materials", ["type_id"], :name => "index_type_materials_on_type_id"

  create_table "type_requirements", :id => false, :force => true do |t|
    t.integer "type_id",          :null => false
    t.integer "activity_id",      :null => false
    t.integer "required_type_id", :null => false
    t.integer "quantity"
    t.float   "damage_per_job"
    t.boolean "recycle"
  end

  create_table "type_values", :force => true do |t|
    t.datetime "ts"
    t.integer  "type_id"
    t.integer  "region_id"
    t.string   "stat"
    t.float    "value"
    t.float    "mat_value"
  end

  add_index "type_values", ["type_id", "region_id", "stat", "id"], :name => "index_type_values_on_type_id_and_region_id_and_stat_and_id"

  create_table "types", :primary_key => "type_id", :force => true do |t|
    t.string  "name",                  :limit => 100
    t.integer "group_id"
    t.string  "description",           :limit => 3000
    t.float   "mass"
    t.float   "volume"
    t.float   "capacity"
    t.integer "portion_size"
    t.integer "race_id"
    t.decimal "base_price",                            :precision => 19, :scale => 4
    t.boolean "published"
    t.integer "market_group_id"
    t.float   "chance_of_duplicating"
    t.integer "icon_id"
    t.integer "tech_level"
    t.integer "meta_level"
  end

  add_index "types", ["group_id"], :name => "index_types_on_group_id"
  add_index "types", ["market_group_id"], :name => "index_types_on_market_group_id"

  create_table "units", :primary_key => "unit_id", :force => true do |t|
    t.string "name",         :limit => 100
    t.string "display_name", :limit => 50
    t.string "description",  :limit => 1000
  end

  create_table "user_profiles", :force => true do |t|
    t.integer "user_id"
    t.integer "default_region", :default => 10000002
    t.string  "default_stat",   :default => "median"
    t.string  "timezone",       :default => "UTC"
  end

  add_index "user_profiles", ["user_id"], :name => "index_user_profiles_on_user_id"

  create_table "users", :force => true do |t|
    t.boolean  "admin",                  :default => false
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
