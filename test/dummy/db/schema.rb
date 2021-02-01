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

ActiveRecord::Schema.define(version: 2021_01_28_220347) do

  create_table "barion_addresses", force: :cascade do |t|
    t.string "country", limit: 2, default: "zz", null: false
    t.string "zip", limit: 16
    t.string "city", limit: 50
    t.string "region", limit: 2
    t.string "street", limit: 50
    t.string "street2", limit: 50
    t.string "street3", limit: 50
    t.string "full_name", limit: 45
    t.bigint "payment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["city"], name: "index_barion_addresses_on_city"
    t.index ["country"], name: "index_barion_addresses_on_country"
    t.index ["full_name"], name: "index_barion_addresses_on_full_name"
    t.index ["payment_id"], name: "index_barion_addresses_on_payment_id"
    t.index ["zip"], name: "index_barion_addresses_on_zip"
  end

  create_table "barion_items", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "description", limit: 500, null: false
    t.string "image_url"
    t.decimal "quantity", null: false
    t.string "unit", limit: 50, null: false
    t.decimal "unit_price", null: false
    t.decimal "item_total", null: false
    t.string "sku", limit: 100
    t.integer "transaction_id"
    t.index ["transaction_id"], name: "index_barion_items_on_transaction_id"
  end

  create_table "barion_payer_accounts", force: :cascade do |t|
    t.string "account_id", limit: 64
    t.datetime "account_created"
    t.integer "account_creation_indicator", limit: 3
    t.datetime "account_last_changed"
    t.integer "account_change_indicator", limit: 3
    t.datetime "password_last_changed"
    t.integer "password_change_indicator", limit: 3
    t.integer "purchases_in_the_last_6_months"
    t.datetime "shipping_address_added"
    t.integer "shipping_address_usage_indicator", limit: 3
    t.integer "provision_attempts"
    t.integer "transactional_activity_per_day"
    t.integer "transactional_activity_per_year"
    t.datetime "payment_method_added"
    t.integer "suspicious_activity_indicator", limit: 1, default: 0
    t.bigint "payment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_barion_payer_accounts_on_account_id"
    t.index ["payment_id"], name: "index_barion_payer_accounts_on_payment_id"
  end

  create_table "barion_payments", force: :cascade do |t|
    t.string "poskey", null: false
    t.integer "payment_type", default: 0, null: false
    t.integer "reservation_period", limit: 8
    t.integer "delayed_capture_period", limit: 6
    t.string "payment_window", limit: 6
    t.boolean "guest_checkout"
    t.boolean "initiate_recurrence"
    t.string "recurrence_id", limit: 100
    t.integer "funding_sources", default: 0
    t.string "payment_request_id", limit: 100
    t.string "payer_hint", limit: 256
    t.string "card_holder_name_hint", limit: 45
    t.integer "recurrence_type", default: 0
    t.string "trace_id", limit: 100
    t.string "redirect_url", limit: 2000
    t.string "callback_url", limit: 2000
    t.string "order_number", limit: 100
    t.integer "shipping_address_id"
    t.string "locale", limit: 10, null: false
    t.string "currency", limit: 3, null: false
    t.string "payer_phone_number", limit: 30
    t.string "payer_work_phone_number", limit: 30
    t.string "payer_home_number", limit: 30
    t.integer "billing_address_id"
    t.integer "payer_account_id"
    t.integer "purchase_information_id"
    t.string "challenge_preference"
    t.string "checksum"
    t.string "payment_id"
    t.integer "status", null: false
    t.string "qr_url", limit: 2000
    t.integer "recurrence_result"
    t.string "gateway_url", limit: 2000
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["billing_address_id"], name: "index_barion_payments_on_billing_address_id"
    t.index ["order_number"], name: "index_barion_payments_on_order_number"
    t.index ["payer_account_id"], name: "index_barion_payments_on_payer_account_id"
    t.index ["payment_id"], name: "index_barion_payments_on_payment_id"
    t.index ["payment_request_id"], name: "index_barion_payments_on_payment_request_id"
    t.index ["payment_type"], name: "index_barion_payments_on_payment_type"
    t.index ["poskey"], name: "index_barion_payments_on_poskey"
    t.index ["purchase_information_id"], name: "index_barion_payments_on_purchase_information_id"
    t.index ["recurrence_id"], name: "index_barion_payments_on_recurrence_id"
    t.index ["shipping_address_id"], name: "index_barion_payments_on_shipping_address_id"
    t.index ["status"], name: "index_barion_payments_on_status"
  end

  create_table "barion_purchases", force: :cascade do |t|
    t.integer "delivery_timeframe"
    t.string "delivery_email_address"
    t.datetime "pre_order_date"
    t.integer "availability_indicator"
    t.integer "re_order_indicator"
    t.integer "shipping_address_indicator"
    t.datetime "recurring_expiry"
    t.integer "recurring_frequency", limit: 4
    t.integer "purchase_type"
    t.bigint "gift_card_purchase_id"
    t.datetime "purchase_date"
    t.bigint "payment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["delivery_email_address"], name: "index_barion_purchases_on_delivery_email_address"
    t.index ["delivery_timeframe"], name: "index_barion_purchases_on_delivery_timeframe"
    t.index ["gift_card_purchase_id"], name: "index_barion_purchases_on_gift_card_purchase_id"
    t.index ["payment_id"], name: "index_barion_purchases_on_payment_id"
  end

  create_table "barion_transactions", force: :cascade do |t|
    t.string "pos_transaction_id", null: false
    t.string "payee", null: false
    t.decimal "total", null: false
    t.string "comment"
    t.bigint "payee_transactions_id"
    t.bigint "payment_id"
    t.integer "status", default: 0, null: false
    t.string "transaction_id"
    t.string "currency", limit: 3
    t.datetime "transaction_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payee"], name: "index_barion_transactions_on_payee"
    t.index ["payee_transactions_id"], name: "index_barion_transactions_on_payee_transactions_id"
    t.index ["payment_id"], name: "index_barion_transactions_on_payment_id"
    t.index ["pos_transaction_id"], name: "index_barion_transactions_on_pos_transaction_id"
    t.index ["status"], name: "index_barion_transactions_on_status"
    t.index ["transaction_id"], name: "index_barion_transactions_on_transaction_id"
  end

  add_foreign_key "barion_items", "barion_transactions", column: "transaction_id"
  add_foreign_key "barion_payments", "barion_addresses", column: "billing_address_id"
  add_foreign_key "barion_payments", "barion_addresses", column: "shipping_address_id"
  add_foreign_key "barion_payments", "barion_payer_accounts", column: "payer_account_id"
  add_foreign_key "barion_payments", "barion_purchases", column: "purchase_information_id"
  add_foreign_key "barion_transactions", "barion_payments", column: "payment_id"
  add_foreign_key "barion_transactions", "barion_transactions", column: "payee_transactions_id"
end
