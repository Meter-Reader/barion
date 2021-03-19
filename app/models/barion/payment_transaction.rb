# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_payment_transactions
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
#  index_barion_payment_transactions_on_payee                  (payee)
#  index_barion_payment_transactions_on_payee_transactions_id  (payee_transactions_id)
#  index_barion_payment_transactions_on_payment_id             (payment_id)
#  index_barion_payment_transactions_on_pos_transaction_id     (pos_transaction_id)
#  index_barion_payment_transactions_on_status                 (status)
#  index_barion_payment_transactions_on_transaction_id         (transaction_id)
#
# Foreign Keys
#
#  payee_transactions_id  (payee_transactions_id => barion_payment_transactions.id)
#  payment_id             (payment_id => barion_payments.id)
#
module Barion
  # Barion Transaction implementation
  class PaymentTransaction < ApplicationRecord
    include Barion::Currencies
    include Barion::JsonSerializer

    enum status: {
      prepared: 0,                            # The transaction is prepared, and is ready to be completed.
      started: 1,                             # The transaction has been started. This is used at reservation payments.
      succeeded: 2,                           # The transaction was successfully completed.
      timeout: 3,                             # The transaction has timed out.
      shop_is_deleted: 4,                     # The shop that created the transaction has been deleted in the meantime.
      shop_is_closed: 5,                      # The shop that created the transaction has been closed in the meantime.
      rejected: 6,                            # The user rejected the transaction.
      rejected_by_shop: 12,                   # The transaction was cancelled by the shop.
      storno: 13,                             # Storno amount for a previous transaction.
      reserved: 14,                           # The transaction amount has been reserved.
      deleted: 15,                            # The transaction was deleted.
      expired: 16,                            # The transaction has expired.
      authorized: 17,                         # The card payment transaction is authorized but not captured yet.
      reversed: 18,                           # The authorization was reversed.
      invalid_payment_record: 210,            # A payment to the given transaction does not exists.
      payment_time_out: 211,                  # The payment of the transaction has timed out.
      invalid_payment_status: 212,            # The payment of the transaction is in an invalid status.
      payment_sender_or_recipient_is_invalid: 213, # The sender or recipient user was not found in the Barion system.
      unknown: 255                            # The transaction is in an unknown state.
    }, _default: :prepared

    belongs_to :payment, inverse_of: :payment_transactions
    has_many :items,
             inverse_of: :payment_transaction,
             after_add: :calc_total,
             after_remove: :calc_total
    attribute :total, :decimal, default: 0.0
    attribute :pos_transaction_id, :string

    validates :payee, presence: true
    validates :status, presence: true
    validates :pos_transaction_id, presence: true
    validates :items, presence: true
    validates_associated :items

    after_initialize :set_defaults

    def currency=(val = nil)
      super(val || payment&.currency)
    end

    def set_defaults
      self.currency = payment&.currency if currency.nil?
      self.payee = Barion.default_payee if payee.nil?
    end

    def total=(value)
      value = calc_item_totals if value.nil?
      super(value)
    end

    def serialize_options
      { except: %i[id status created_at updated_at],
        include: %i[items],
        map: {
          keys: {
            _all: :camelize,
            pos_transaction_id: 'POSTransactionId'
          },
          values: {
            _all: proc { |v| v.respond_to?(:camelize) ? v.camelize : v },
            _except: %w[items pos_transaction_id payee comment]
          }
        } }
    end

    def deserialize_options
      {
        map: {
          keys: {
            _all: :underscore,
            POSTransactionId: 'pos_transaction_id'
          },
          values: {
            _all: proc { |v| v.respond_to?(:underscore) ? v.underscore : v },
            _except: %w[Currency]
          }
        }
      }
    end

    protected

    def calc_item_totals
      items.sum(&:item_total)
    end

    private

    def calc_total(_item)
      self.total = calc_item_totals
    end
  end
end
