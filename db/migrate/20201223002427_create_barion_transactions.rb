class CreateBarionTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :barion_transactions do |t|
      t.string :pos_transaction_id
      t.string :transaction_id
      t.integer :status
      t.string :currency, limit: 3
      t.timestamp :transaction_time
      t.references :payment, references: :barion_payments, foreign_key: { to_table: :barion_payments }

      t.timestamps
    end
    add_index :barion_transactions, :pos_transaction_id
    add_index :barion_transactions, :transaction_id
    add_index :barion_transactions, :status
  end
end
