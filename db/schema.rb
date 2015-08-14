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

ActiveRecord::Schema.define(version: 20150813122807) do

  create_table "group_users", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_users", ["group_id"], name: "index_group_users_on_group_id", using: :btree
  add_index "group_users", ["user_id"], name: "index_group_users_on_user_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.string   "description"
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
    t.integer  "role",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
