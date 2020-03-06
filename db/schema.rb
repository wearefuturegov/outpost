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

ActiveRecord::Schema.define(version: 2020_02_26_172537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "email"
    t.string "url"
    t.string "old_external_id"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "organisation_id"
    t.string "name"
    t.text "description"
    t.string "email"
    t.string "url"
    t.index ["organisation_id"], name: "index_services_on_organisation_id"
  end

end
