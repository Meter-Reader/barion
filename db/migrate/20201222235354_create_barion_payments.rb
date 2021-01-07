# frozen_string_literal: true

class CreateBarionPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :barion_payments do |t|
      t.string :type, index:true
      t.integer :reservation_period, limit: 8
      t.integer :delayed_capture_period, limit: 6
      t.string :payment_window, limit: 6
      t.boolean :guest_checkout
      t.boolean :initiate_recurrence
      t.string :recurrence_id, limit: 100, index: true
      t.string :recurrence_type
      t.string :funding_sources
      t.string :payer_hint, limit: 256, index: true
      t.string :card_holder_name_hint, limit: 45
      t.string :trace_id, limit: 100
      t.string :redirect_url, limit: 2000
      t.string :callback_url, limit: 2000
      t.string :order_number, limmit: 100, index: true
      t.references :shipping_address, references: :addresses, foreign_key: { to_table: :addresses }
      t.references :billing_address, references: :addresses, foreign_key: { to_table: :addresses }
      t.string :locale
      t.string :currency
      t.references :payer, foreign_key: true
      t.string :payment_request_id
      t.references :payer_account, references: :accounts, foreign_key: { to_table: :accounts }
      t.references :purchase_information, references: :purchases, foreign_key: { to_table: :purchases }
      t.string :challenge_preference

      t.timestamps
    end
  end
end
