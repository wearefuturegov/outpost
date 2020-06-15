# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_15_135522) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accessibilities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "accessibilities_locations", id: false, force: :cascade do |t|
    t.bigint "location_id", null: false
    t.bigint "accessibility_id", null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "service_id"
    t.string "name"
    t.string "title"
    t.boolean "visible", default: true
    t.string "email"
    t.index ["service_id"], name: "index_contacts_on_service_id"
  end

  create_table "cost_options", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.string "option"
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_cost_options_on_service_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "topic"
    t.index ["service_id"], name: "index_feedbacks_on_service_id"
  end

  create_table "local_offers", force: :cascade do |t|
    t.text "description"
    t.bigint "service_id", null: false
    t.string "link"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_local_offers_on_service_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "address_1"
    t.string "city"
    t.string "state_province"
    t.string "postal_code"
    t.string "country"
    t.string "google_place_id"
    t.boolean "visible", default: true
    t.boolean "mask_exact_address"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.text "body"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_notes_on_service_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "ofsted_items", force: :cascade do |t|
    t.string "provider_name"
    t.string "setting_name"
    t.integer "reference_number"
    t.string "provision_type"
    t.string "secondary_provision_type"
    t.string "registration_status"
    t.string "special_consideration"
    t.date "registration_date"
    t.date "last_change_date"
    t.string "link_to_ofsted_report"
    t.string "setting_address_1"
    t.string "setting_address_2"
    t.string "setting_villagetown"
    t.string "setting_town"
    t.string "setting_county"
    t.string "setting_postcode"
    t.string "setting_telephone"
    t.string "setting_fax"
    t.string "setting_email"
    t.string "location_ward"
    t.string "location_planning"
    t.string "prov_address_1"
    t.string "prov_address_2"
    t.string "prov_villagetown"
    t.string "prov_town"
    t.string "prov_county"
    t.string "prov_postcode"
    t.string "prov_telephone"
    t.string "prov_mobile"
    t.string "prov_work_telephone"
    t.string "prov_fax"
    t.string "prov_email"
    t.string "prov_consent_withheld"
    t.string "rp_reference_number"
    t.string "related_rpps"
    t.string "registration_status_history"
    t.string "child_services_register"
    t.string "certificate_condition"
    t.text "childcare_period", array: true
    t.string "childcare_age"
    t.string "inspection"
    t.string "notice_history"
    t.string "welfare_notice_history"
    t.string "linked_registration"
    t.datetime "lastupdated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "email"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "old_external_id"
    t.integer "users_count", default: 0, null: false
    t.integer "services_count", default: 0, null: false
  end

  create_table "phones", force: :cascade do |t|
    t.bigint "contact_id"
    t.string "number"
    t.index ["contact_id"], name: "index_phones_on_contact_id"
  end

  create_table "regular_schedules", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.time "opens_at"
    t.time "closes_at"
    t.integer "weekday"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_regular_schedules_on_service_id"
  end

  create_table "report_postcodes", force: :cascade do |t|
    t.string "postcode"
    t.string "ward"
    t.string "childrens_centre"
  end

  create_table "service_at_locations", force: :cascade do |t|
    t.integer "service_id", null: false
    t.integer "location_id", null: false
  end

  create_table "service_taxonomies", force: :cascade do |t|
    t.bigint "taxonomy_id"
    t.bigint "service_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_service_taxonomies_on_service_id"
    t.index ["taxonomy_id"], name: "index_service_taxonomies_on_taxonomy_id"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "organisation_id"
    t.string "name"
    t.text "description"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.boolean "approved", default: true
    t.string "type"
    t.date "visible_from"
    t.date "visible_to"
    t.integer "notes_count", default: 0, null: false
    t.integer "ofsted_reference_number"
    t.string "old_ofsted_external_id"
    t.boolean "visible", default: true
    t.boolean "needs_referral"
    t.string "twitter_url"
    t.string "facebook_url"
    t.string "youtube_url"
    t.string "linkedin_url"
    t.string "instagram_url"
    t.string "referral_url"
    t.string "bccn_membership_number"
    t.boolean "current_vacancies"
    t.boolean "pick_up_drop_off_service"
    t.index ["discarded_at"], name: "index_services_on_discarded_at"
    t.index ["organisation_id"], name: "index_services_on_organisation_id"
  end

  create_table "snapshots", force: :cascade do |t|
    t.json "object"
    t.string "action"
    t.integer "user_id"
    t.bigint "service_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "object_changes"
    t.index ["service_id"], name: "index_snapshots_on_service_id"
    t.index ["user_id"], name: "index_snapshots_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "taxonomies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "parent_id"
    t.boolean "locked"
    t.integer "sort_order"
    t.index ["parent_id"], name: "index_taxonomies_on_parent_id"
  end

  create_table "taxonomy_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "taxonomy_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "taxonomy_desc_idx"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "organisation_id"
    t.boolean "admin"
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_seen"
    t.datetime "discarded_at"
    t.string "old_external_id"
    t.boolean "admin_users"
    t.boolean "admin_ofsted"
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "watches", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "service_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_watches_on_service_id"
    t.index ["user_id"], name: "index_watches_on_user_id"
  end

  add_foreign_key "cost_options", "services"
  add_foreign_key "feedbacks", "services"
  add_foreign_key "local_offers", "services"
  add_foreign_key "notes", "services"
  add_foreign_key "notes", "users"
  add_foreign_key "regular_schedules", "services"
  add_foreign_key "snapshots", "services"
  add_foreign_key "snapshots", "users"
  add_foreign_key "taggings", "tags"
end
