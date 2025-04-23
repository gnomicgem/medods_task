# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_22_044422) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "refresh_tokens", force: :cascade do |t|
    t.string "user_guid", null: false
    t.string "token_digest", null: false
    t.string "ip", null: false
    t.string "jti", null: false
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_guid", "jti"], name: "index_refresh_tokens_on_user_guid_and_jti", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "guid", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["guid"], name: "index_users_on_guid", unique: true
  end

  add_foreign_key "refresh_tokens", "users", column: "user_guid", primary_key: "guid", on_delete: :cascade
end
