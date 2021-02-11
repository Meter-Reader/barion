# frozen_string_literal: true

# Creates Barion::Transaction record persistency
class CreateBarionPaymentTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :barion_payment_transactions do |t|
      t.string :pos_transaction_id, null: false, index: true
      t.string :payee, null: false, index: true
      t.decimal :total, null: false
      t.string :comment
      t.references :payee_transactions,
                   references: :barion_payment_transactions,
                   foreign_key: { to_table: :barion_payment_transactions }
      t.references :payment,
                   references: :barion_payments,
                   foreign_key: { to_table: :barion_payments }
      t.integer :status, default: 0, null: false, index: true
      t.string :transaction_id, index: true
      t.string :currency, limit: 3
      t.timestamp :transaction_time

      t.timestamps
    end
  end
end
