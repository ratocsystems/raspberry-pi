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

ActiveRecord::Schema.define(version: 2019_02_08_082210) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ads", force: :cascade do |t|
    t.bigint "gp40_id"
    t.integer "channel"
    t.integer "value"
    t.integer "range"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gp40_id", "channel"], name: "index_ads_on_gp40_id_and_channel", unique: true
    t.index ["gp40_id"], name: "index_ads_on_gp40_id"
  end

  create_table "falls", force: :cascade do |t|
    t.integer "count"
    t.bigint "machine_id"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "beginning"
    t.index ["machine_id"], name: "index_falls_on_machine_id"
  end

  create_table "gp10s", force: :cascade do |t|
    t.integer "di"
    t.bigint "machine_id"
    t.datetime "date"
    t.datetime "beginning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["machine_id"], name: "index_gp10s_on_machine_id"
  end

  create_table "gp40s", force: :cascade do |t|
    t.bigint "machine_id"
    t.datetime "date"
    t.datetime "beginning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["machine_id"], name: "index_gp40s_on_machine_id"
  end

  create_table "machines", force: :cascade do |t|
    t.macaddr "mac"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mac"], name: "index_machines_on_mac", unique: true
  end

  create_table "rotations", force: :cascade do |t|
    t.decimal "rpm"
    t.decimal "angle"
    t.bigint "machine_id"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "beginning"
    t.index ["machine_id"], name: "index_rotations_on_machine_id"
  end

  create_table "slopes", force: :cascade do |t|
    t.integer "x"
    t.integer "y"
    t.integer "z"
    t.bigint "machine_id"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "beginning"
    t.index ["machine_id"], name: "index_slopes_on_machine_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.decimal "distance"
    t.bigint "machine_id"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "beginning"
    t.index ["machine_id"], name: "index_surveys_on_machine_id"
  end

  create_table "wbgts", force: :cascade do |t|
    t.decimal "black"
    t.decimal "dry"
    t.decimal "wet"
    t.decimal "humidity"
    t.decimal "wbgt_data"
    t.bigint "machine_id"
    t.datetime "date"
    t.datetime "beginning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["machine_id"], name: "index_wbgts_on_machine_id"
  end

  add_foreign_key "ads", "gp40s"
  add_foreign_key "falls", "machines"
  add_foreign_key "gp10s", "machines"
  add_foreign_key "gp40s", "machines"
  add_foreign_key "rotations", "machines"
  add_foreign_key "slopes", "machines"
  add_foreign_key "surveys", "machines"
  add_foreign_key "wbgts", "machines"
end
