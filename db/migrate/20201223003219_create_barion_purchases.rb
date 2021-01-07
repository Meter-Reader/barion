# frozen_string_literal: true

class CreateBarionPurchases < ActiveRecord::Migration[6.0]
  def change
    create_table :barion_purchases do |t|
      t.integer :delivery_timeframe
      t.string :delivery_email_address
      t.datetime :pre_order_date
      t.integer :availability_indicator
      t.integer :re_order_indicator
      t.integer :shipping_address_indicator
      t.datetime :recurring_expiry
      t.integer :recurring_frequency, limit: 4
      t.integer :purchase_type
      t.references :gift_card_purchase
      t.datetime :purchase_date

      t.timestamps
    end
    add_index :barion_purchases, :delivery_timeframe
    add_index :barion_purchases, :delivery_email_address
  end
end
