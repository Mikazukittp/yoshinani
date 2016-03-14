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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160314135411) do

  create_table "admin_users", force: true do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree

  create_table "group_users", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",       default: "member",   null: false
    t.string   "status",     default: "inviting", null: false
  end

  add_index "group_users", ["user_id", "group_id"], name: "index_group_users_on_user_id_and_group_id", unique: true, using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_registrations", force: true do |t|
    t.integer  "user_id",        null: false
    t.integer  "oauth_id",       null: false
    t.string   "third_party_id", null: false
    t.date     "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_registrations", ["user_id"], name: "index_oauth_registrations_on_user_id", using: :btree

  create_table "oauths", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", force: true do |t|
    t.integer  "payment_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participants", ["payment_id"], name: "index_participants_on_payment_id", using: :btree
  add_index "participants", ["user_id"], name: "index_participants_on_user_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "amount"
    t.string   "event"
    t.string   "description"
    t.date     "date"
    t.integer  "paid_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.boolean  "is_repayment", default: false
    t.date     "deleted_at"
  end

  add_index "payments", ["group_id"], name: "index_payments_on_group_id", using: :btree
  add_index "payments", ["paid_user_id"], name: "index_payments_on_paid_user_id", using: :btree

  create_table "totals", force: true do |t|
    t.decimal  "paid",       precision: 11, scale: 2, default: 0.0
    t.decimal  "to_pay",     precision: 11, scale: 2, default: 0.0
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "totals", ["group_id"], name: "index_totals_on_group_id", using: :btree
  add_index "totals", ["user_id"], name: "index_totals_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "account"
    t.string   "username"
    t.string   "email"
    t.string   "password"
    t.string   "token"
    t.integer  "role",                 default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salt"
    t.text     "reset_password_token"
    t.datetime "reset_password_at"
    t.text     "device_token"
  end

end
