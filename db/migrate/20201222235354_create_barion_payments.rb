# frozen_string_literal: true

# Creates Barion::Payment record persistency
class CreateBarionPayments < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Metrics/BlockLength
    create_table :barion_payments do |t|
      t.string :poskey, index: true, null: false
      t.integer :payment_type, index: true, default: 0, null: false
      t.integer :reservation_period, limit: 8
      t.integer :delayed_capture_period, limit: 6
      t.string :payment_window, limit: 6
      t.boolean :guest_check_out
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
      t.string :locale, limit: 10, null: false
      t.string :currency, limit: 3, null: false
      t.string :payer_phone_number, limit: 30
      t.string :payer_work_phone_number, limit: 30
      t.string :payer_home_number, limit: 30
      t.integer :challenge_preference, default: 0
      t.string :checksum, null: false

      t.string :payment_id, index: true
      t.integer :status, index: true, null: false
      t.string :qr_url, limit: 2000
      t.integer :recurrence_result
      t.string :gateway_url, limit: 2000

      t.string :pos_id
      t.string :pos_name
      t.string :pos_owner_email
      t.string :pos_owner_country
      t.integer :funding_source
      t.datetime :created_at_barion
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :valid_until
      t.datetime :reserved_until
      t.datetime :delayed_capture_until
      t.decimal :total
      t.string :suggested_local
      t.integer :fraud_risk_score

      t.timestamps
    end
    # rubocop:enable Metrics/BlockLength
  end
end
