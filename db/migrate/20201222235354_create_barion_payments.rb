# frozen_string_literal: true

class CreateBarionPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :barion_payments do |t|
      t.string :poskey, index: true, null: false
      t.integer :payment_type, index: true, default: 0, null: false
      t.integer :reservation_period, limit: 8
      t.integer :delayed_capture_period, limit: 6
      t.string :payment_window, limit: 6
      t.boolean :guest_checkout
      t.boolean :initiate_recurrence
      t.string :recurrence_id, limit: 100, index: true
      t.integer :funding_sources, default: 0
      t.string :payment_request_id, limit: 100, index: true
      t.string :payer_hint, limit: 256
      t.string :card_holder_name_hint, limit: 45
      t.integer :recurrence_type, default: 0
      t.string :trace_id, limit: 100
      t.string :redirect_url, limit: 2000
      t.string :callback_url, limit: 2000

      t.string :order_number, limit: 100, index: true
      t.references :shipping_address, references: :barion_addresses, foreign_key: { to_table: :barion_addresses }
      t.string :locale, limit: 10, null: false
      t.string :currency, limit: 3, null: false
      t.string :payer_phone_number, limit: 30
      t.string :payer_work_phone_number, limit: 30
      t.string :payer_home_number, limit: 30
      t.references :billing_address, references: :barion_addresses, foreign_key: { to_table: :barion_addresses }
      t.references :payer_account, references: :barion_payer_accounts, foreign_key: { to_table: :barion_payer_accounts }
      t.references :purchase_information, references: :barion_purchases, foreign_key: { to_table: :barion_purchases }
      t.string :challenge_preference
      t.string :checksum

      t.string :payment_id, index: true
      t.integer :status, index: true, null: false
      t.string :qr_url, limit: 2000
      t.integer :recurrence_result
      t.string :gateway_url, limit: 2000

      t.timestamps
    end
  end
end
