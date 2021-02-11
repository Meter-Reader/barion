# frozen_string_literal: true

# Creates Barion::Item record persistency
class CreateBarionItems < ActiveRecord::Migration[6.1]
  def change
    create_table :barion_items do |t|
      t.string :name, limit: 250, null: false
      t.string :description, limit: 500, null: false
      t.string :image_url
      t.decimal :quantity, null: false
      t.string :unit, limit: 50, null: false
      t.decimal :unit_price, null: false
      t.decimal :item_total, null: false
      t.string :sku, limit: 100

      t.references :payment_transaction,
                   references: :barion_payment_transactions,
                   foreign_key: { to_table: :barion_payment_transactions }
    end
  end
end
