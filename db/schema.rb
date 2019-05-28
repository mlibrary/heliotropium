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

ActiveRecord::Schema.define(version: 2019_05_28_165428) do

  create_table "identifiers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_identifiers_on_name"
  end

  create_table "uuid_identifiers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "uuid_id"
    t.bigint "identifier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier_id"], name: "index_uuid_identifiers_on_identifier_id"
    t.index ["uuid_id", "identifier_id"], name: "index_uuid_identifiers_on_uuid_id_and_identifier_id", unique: true
    t.index ["uuid_id"], name: "index_uuid_identifiers_on_uuid_id"
  end

  create_table "uuids", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.binary "packed"
    t.string "unpacked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "uuid_identifiers", "identifiers"
  add_foreign_key "uuid_identifiers", "uuids"
end
