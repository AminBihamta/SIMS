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

ActiveRecord::Schema[8.0].define(version: 2025_01_11_081817) do
  create_schema "auth"
  create_schema "extensions"
  create_schema "graphql"
  create_schema "graphql_public"
  create_schema "pgbouncer"
  create_schema "pgsodium"
  create_schema "pgsodium_masks"
  create_schema "realtime"
  create_schema "storage"
  create_schema "vault"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.pgjwt"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgsodium.pgsodium"
  enable_extension "vault.supabase_vault"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "borrowing_status", ["borrowed", "returned", "overdue"]

  create_table "borrowings", force: :cascade do |t|
    t.integer "equipment_id", null: false
    t.integer "club_id", null: false
    t.uuid "pic_id"
    t.datetime "borrow_date", null: false
    t.datetime "due_date", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "status", default: "borrowed", null: false, enum_type: "borrowing_status"
  end

  create_table "clubs", primary_key: "Club_ID", id: :bigint, default: nil, force: :cascade do |t|
    t.boolean "Is_Super_Club", null: false
    t.timestamptz "Created_At", default: -> { "now()" }, null: false
    t.datetime "Updated_At", precision: nil
    t.string "Club_Name", null: false
    t.bigint "Parent_Club"
    t.decimal "Budget", default: "0.0", null: false

    t.unique_constraint ["Club_ID"], name: "Club_Club_ID_key"
  end

  create_table "equipments", primary_key: "Equipment_ID", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "Vendor_ID", null: false
    t.bigint "Club_ID"
    t.bigint "Financial_Record_Id"
    t.timestamptz "Created_At", default: -> { "now()" }, null: false
    t.datetime "Edited_At", precision: nil
    t.string "Equipment_Name", null: false
    t.integer "stock"
    t.string "Status", default: "Available"

    t.unique_constraint ["Equipment_ID"], name: "Equipment_Equipment_ID_key"
  end

  create_table "financial_records", primary_key: "Financial_Record_ID", id: :bigint, default: nil, force: :cascade do |t|
    t.string "Title", null: false
    t.decimal "Amount", null: false
    t.bigint "Vendor_ID"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.datetime "Edited_At", precision: nil
    t.integer "Quantity", default: 1, null: false
    t.bigint "Club_ID"

    t.unique_constraint ["Financial_Record_ID"], name: "Financial_Record_Financial_Record_ID_key"
  end

  create_table "notification_histories", force: :cascade do |t|
    t.bigint "notification_id", null: false
    t.string "delivery_status", null: false
    t.string "delivery_method", null: false
    t.datetime "delivered_at", precision: nil
    t.text "failure_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "message"
    t.index ["notification_id"], name: "index_notification_histories_on_notification_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "notification_type", null: false
    t.text "message", null: false
    t.datetime "triggered_at", precision: nil, null: false
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "borrowing_id"
  end

  create_table "user_data", id: :uuid, default: nil, force: :cascade do |t|
    t.boolean "is_supervisor", default: false, null: false
    t.bigint "club_id"
  end

  create_table "vendors", primary_key: "Vendor_ID", id: :bigint, default: nil, force: :cascade do |t|
    t.string "Name", null: false
    t.string "Address", null: false
    t.string "Phone_Number", null: false
    t.timestamptz "Created_At", default: -> { "now()" }, null: false
    t.datetime "Edited_At", precision: nil
    t.uuid "PIC"

    t.unique_constraint ["Vendor_ID"], name: "Vendor_Vendor_ID_key"
  end

  add_foreign_key "borrowings", "clubs", primary_key: "Club_ID", name: "borrowings_club_id_fk"
  add_foreign_key "borrowings", "equipments", primary_key: "Equipment_ID", name: "borrowings_equipment_id_fk"
  add_foreign_key "borrowings", "user_data", column: "pic_id", name: "borrowings_pic_id_fk"
  add_foreign_key "clubs", "clubs", column: "Parent_Club", primary_key: "Club_ID", name: "clubs_Parent_Club_fkey"
  add_foreign_key "equipments", "clubs", column: "Club_ID", primary_key: "Club_ID", name: "Equipment_Club_ID_fkey"
  add_foreign_key "equipments", "financial_records", column: "Financial_Record_Id", primary_key: "Financial_Record_ID", name: "Equipment_Transaction_ID_fkey"
  add_foreign_key "equipments", "vendors", column: "Vendor_ID", primary_key: "Vendor_ID", name: "Equipment_Vendor_ID_fkey"
  add_foreign_key "financial_records", "clubs", column: "Club_ID", primary_key: "Club_ID", name: "financial_records_Club_ID_fkey"
  add_foreign_key "financial_records", "vendors", column: "Vendor_ID", primary_key: "Vendor_ID", name: "Financial_Record_Vendor_ID_fkey"
  add_foreign_key "notification_histories", "notifications"
  add_foreign_key "notifications", "borrowings", name: "notifications_borrowing_id_fkey"
  add_foreign_key "user_data", "auth.users", column: "id", name: "user_data_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_data", "clubs", primary_key: "Club_ID", name: "user_data_club_id_fkey1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "vendors", "auth.users", column: "PIC", name: "vendors_PIC_fkey"
  add_foreign_key "notifications", "borrowings", column: "borrowing", name: "notifications_borrowing_fkey"
  add_foreign_key "user_data", "auth.users", column: "id", name: "user_data_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_data", "clubs", primary_key: "Club_ID", name: "user_data_club_id_fkey1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "vendors", "auth.users", column: "PIC", name: "vendors_PIC_fkey"
end
