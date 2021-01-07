# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_23_003219) do

  create_table "barion_addresses", force: :cascade do |t|
    t.string "country", limit: 2, default: "zz"
    t.string "zip", limit: 16
    t.string "city", limit: 50
    t.string "region", limit: 2
    t.string "street", limit: 50
    t.string "street2", limit: 50
    t.string "street3", limit: 50
    t.string "full_name", limit: 45
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["full_name"], name: "index_barion_addresses_on_full_name"
  end

  create_table "barion_payments", force: :cascade do |t|
    t.string "type"
    t.integer "reservation_period", limit: 8
    t.integer "delayed_capture_period", limit: 6
    t.string "payment_window", limit: 6
    t.boolean "guest_checkout"
    t.boolean "initiate_recurrence"
    t.string "recurrence_id", limit: 100
    t.string "recurrence_type"
    t.string "funding_sources"
    t.string "payer_hint", limit: 256
    t.string "card_holder_name_hint", limit: 45
    t.string "trace_id", limit: 100
    t.string "redirect_url", limit: 2000
    t.string "callback_url", limit: 2000
    t.string "order_number"
    t.integer "shipping_address_id"
    t.integer "billing_address_id"
    t.string "locale"
    t.string "currency"
    t.integer "payer_id"
    t.string "payment_request_id"
    t.integer "payer_account_id"
    t.integer "purchase_information_id"
    t.string "challenge_preference"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["billing_address_id"], name: "index_barion_payments_on_billing_address_id"
    t.index ["order_number"], name: "index_barion_payments_on_order_number"
    t.index ["payer_account_id"], name: "index_barion_payments_on_payer_account_id"
    t.index ["payer_hint"], name: "index_barion_payments_on_payer_hint"
    t.index ["payer_id"], name: "index_barion_payments_on_payer_id"
    t.index ["purchase_information_id"], name: "index_barion_payments_on_purchase_information_id"
    t.index ["recurrence_id"], name: "index_barion_payments_on_recurrence_id"
    t.index ["shipping_address_id"], name: "index_barion_payments_on_shipping_address_id"
    t.index ["type"], name: "index_barion_payments_on_type"
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
    t.integer "gift_card_purchase_id"
    t.datetime "purchase_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["delivery_email_address"], name: "index_barion_purchases_on_delivery_email_address"
    t.index ["delivery_timeframe"], name: "index_barion_purchases_on_delivery_timeframe"
    t.index ["gift_card_purchase_id"], name: "index_barion_purchases_on_gift_card_purchase_id"
  end

  create_table "barion_transactions", force: :cascade do |t|
    t.string "pos_transaction_id"
    t.string "transaction_id"
    t.integer "status"
    t.string "currency", limit: 3
    t.datetime "transaction_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pos_transaction_id"], name: "index_barion_transactions_on_pos_transaction_id"
    t.index ["status"], name: "index_barion_transactions_on_status"
    t.index ["transaction_id"], name: "index_barion_transactions_on_transaction_id"
  end

  add_foreign_key "barion_payments", "accounts", column: "payer_account_id"
  add_foreign_key "barion_payments", "addresses", column: "billing_address_id"
  add_foreign_key "barion_payments", "addresses", column: "shipping_address_id"
  add_foreign_key "barion_payments", "payers"
  add_foreign_key "barion_payments", "purchases", column: "purchase_information_id"
end
