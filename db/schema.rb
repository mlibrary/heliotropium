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

ActiveRecord::Schema.define(version: 2019_06_12_121048) do

  create_table "identifiers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_identifiers_on_name"
  end

  create_table "umpebc_kbarts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.integer "year", default: 1970, null: false
    t.date "updated", default: "1970-01-01", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_umpebc_kbarts_on_name", unique: true
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
    t.binary "packed", limit: 16, null: false
    t.string "unpacked", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["packed"], name: "index_uuids_on_packed"
    t.index ["unpacked"], name: "index_uuids_on_unpacked"
  end

  add_foreign_key "uuid_identifiers", "identifiers"
  add_foreign_key "uuid_identifiers", "uuids"
end
