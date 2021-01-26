class CreateBarionPayerAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :barion_payer_accounts do |t|
      t.string :email, limit: 256, null: true, index: true
      t.string :name, limit: 45, null: true, index: true
      t.string :locale, limit: 5, null: true
      t.string :phone_number, limit: 30, null: true
      t.string :work_phone_number, limit: 30, null: true
      t.string :home_number, limit: 30, null: true
      t.integer :creation_indicator, limit: 3
      t.integer :change_indicator, limit: 3, null: true
      t.datetime :password_last_changed, null: true
      t.integer :password_change_indicator, limit: 3, null: true
      t.integer :suspicious, limit: 1, null: true, default: 0
      t.datetime :payment_method_added, null: true
      t.integer :shipping_address_usage_indicator, limit: 3, null: true
      t.references :shipping_address, references: :barion_addresses, foreign_key: { to_table: :barion_addresses }
      t.references :billing_address, references: :barion_addresses, foreign_key: { to_table: :barion_addresses }

      t.timestamps
    end
  end
end
