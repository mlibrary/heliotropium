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

ActiveRecord::Schema.define(version: 2020_06_25_191317) do

  create_table "kbart_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.date "updated", default: "1970-01-01", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false
    t.string "folder", null: false
    t.index ["name"], name: "index_kbart_files_on_name", unique: true
  end

  create_table "kbart_marcs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "doi", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "folder", null: false
    t.string "file"
    t.date "updated"
  end

  create_table "marc_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "folder", null: false
  end

  create_table "marc_records", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "folder", null: false
    t.string "file", null: false
    t.string "doi"
    t.binary "mrc"
    t.date "updated", default: "1970-01-01", null: false
    t.boolean "parsed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.binary "content"
    t.integer "count", default: 0
    t.boolean "selected", default: false, null: false
    t.index ["folder", "file"], name: "index_marc_records_on_folder_and_file", unique: true
  end

end
