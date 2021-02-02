# frozen_string_literal: true

# Create Barion::GiftCardPurchase record persistency
class CreateBarionGiftCardPurchases < ActiveRecord::Migration[6.1]
  def change
    create_table :barion_gift_card_purchases do |t|
      t.decimal :amount, null: false
      t.integer :count, null: false
      t.belongs_to :purchase

      t.timestamps
    end
  end
end
