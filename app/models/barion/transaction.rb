# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_transactions
#
#  id                    :integer          not null, primary key
#  comment               :string
#  currency              :string(3)
#  payee                 :string           not null
#  status                :integer          default("Prepared"), not null
#  total                 :decimal(, )      not null
#  transaction_time      :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  payee_transactions_id :bigint
#  payment_id            :bigint
#  pos_transaction_id    :string           not null
#  transaction_id        :string
#
# Indexes
#
#  index_barion_transactions_on_payee                  (payee)
#  index_barion_transactions_on_payee_transactions_id  (payee_transactions_id)
#  index_barion_transactions_on_payment_id             (payment_id)
#  index_barion_transactions_on_pos_transaction_id     (pos_transaction_id)
#  index_barion_transactions_on_status                 (status)
#  index_barion_transactions_on_transaction_id         (transaction_id)
#
# Foreign Keys
#
#  payee_transactions_id  (payee_transactions_id => barion_transactions.id)
#  payment_id             (payment_id => barion_payments.id)
#
module Barion
  class Transaction < ApplicationRecord
    enum status: {
      Prepared: 0,                            # The transaction is prepared, and is ready to be completed.
      Started: 1,                             # The transaction has been started. This is used at reservation payments.
      Succeeded: 2,                           # The transaction was successfully completed.
      Timeout: 3,                             # The transaction has timed out.
      ShopIsDeleted: 4,                       # The shop that created the transaction has been deleted in the meantime.
      ShopIsClosed: 5,                        # The shop that created the transaction has been closed in the meantime.
      Rejected: 6,                            # The user rejected the transaction.
      RejectedByShop: 12,                     # The transaction was cancelled by the shop.
      Storno: 13,                             # Storno amount for a previous transaction.
      Reserved: 14,                           # The transaction amount has been reserved.
      Deleted: 15,                            # The transaction was deleted.
      Expired: 16,                            # The transaction has expired.
      Authorized: 17,                         # The card payment transaction is authorized but not captured yet.
      Reversed: 18,                           # The authorization was reversed.
      InvalidPaymentRecord: 210,              # A payment to the given transaction does not exists.
      PaymentTimeOut: 211,                    # The payment of the transaction has timed out.
      InvalidPaymentStatus: 212,              # The payment of the transaction is in an invalid status.
      PaymentSenderOrRecipientIsInvalid: 213, # The sender or recipient user was not found in the Barion system.
      Unknown: 255                            # The transaction is in an unknown state.
    }, _default: 'Prepared'

    belongs_to :payment, inverse_of: :transactions
  end
end
