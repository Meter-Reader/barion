# frozen_string_literal: true

# Barion::PayerAccount migration
class CreateBarionPayerAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :barion_payer_accounts do |t|
      t.string :account_id, limit: 64, null: true, index: true
      t.datetime :account_created, null: true
      t.integer :account_creation_indicator, limit: 3, null: true
      t.datetime :account_last_changed, null: true
      t.integer :account_change_indicator, limit: 3, null: true
      t.datetime :password_last_changed, null: true
      t.integer :password_change_indicator, limit: 3, null: true
      t.integer :purchases_in_the_last_6_months, null: true
      t.datetime :shipping_address_added, null: true
      t.integer :shipping_address_usage_indicator, limit: 3, null: true
      t.integer :provision_attempts, null: true
      t.integer :transactional_activity_per_day, null: true
      t.integer :transactional_activity_per_year, null: true
      t.datetime :payment_method_added, null: true
      t.integer :suspicious_activity_indicator, limit: 1, null: true, default: 0

      t.references :payment

      t.timestamps
    end
  end
end
