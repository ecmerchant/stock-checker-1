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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180503065123) do

  create_table "accounts", force: :cascade do |t|
    t.string   "user"
    t.string   "seller_id"
    t.string   "aws_token"
    t.boolean  "relist_only"
    t.integer  "sku_limit"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "cw_api_token"
    t.string   "cw_room_id"
    t.datetime "upload_date"
    t.string   "report_id"
    t.integer  "leadtime"
    t.string   "sku_header"
    t.boolean  "delete_sku"
  end

  create_table "stocks", force: :cascade do |t|
    t.string   "email"
    t.string   "sku"
    t.string   "title"
    t.integer  "current_price"
    t.integer  "fixed_price"
    t.integer  "quantity"
    t.datetime "access_date"
    t.boolean  "validity"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "expired"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "admin_flg"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
