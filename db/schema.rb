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

ActiveRecord::Schema[7.1].define(version: 2025_11_29_173724) do
  create_table "chat_messages", force: :cascade do |t|
    t.text "content"
    t.string "role"
    t.integer "user_id", null: false
    t.integer "routine_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["routine_id"], name: "index_chat_messages_on_routine_id"
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "routines", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "steps"
    t.string "visibility"
    t.integer "user_id", null: false
    t.text "shared_with_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_routines_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "role", default: "family", null: false
    t.string "subscription_plan", default: "basic", null: false
    t.datetime "subscription_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "chat_messages", "routines"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "routines", "users"
end
