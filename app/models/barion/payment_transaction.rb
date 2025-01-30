# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_payment_transactions
#
#  id                    :integer          not null, primary key
#  comment               :string
#  currency              :string(3)
#  payee                 :string           not null
#  payer                 :string
#  status                :integer          default("prepared"), not null
#  total                 :decimal(, )      not null
#  transaction_time      :datetime
#  transaction_type      :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  payee_transactions_id :integer
#  payment_id            :integer
#  pos_transaction_id    :string           not null
#  related_id            :string
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
    include ::Barion::Currencies
    include ::Barion::JsonSerializer

    enum status: {
      prepared: 0, started: 1, succeeded: 2, timeout: 3, shop_is_deleted: 4,
      shop_is_closed: 5, rejected: 6, rejected_by_shop: 12, storno: 13, reserved: 14,
      deleted: 15, expired: 16, authorized: 17, reversed: 18, invalid_payment_record: 210,
      payment_time_out: 211, invalid_payment_status: 212,
      payment_sender_or_recipient_is_invalid: 213, unknown: 255
    }, _default: :prepared
    enum transaction_type: {
      shop: 1, transfer_to_existing_user: 2, transfer_to_technical_account: 3,
      reserve: 16, storno_reserve: 17, card_processing_fee: 21, gateway_fee: 22,
      card_processing_fee_storno: 23, unspecified: 100, card_payment: 150,
      refund: 151, refund_to_bank_card: 152, storno_un_successful_refund_to_bank_card: 153,
      under_review: 180, release_review: 190, bank_transfer_payment: 200,
      refund_to_bank_account: 201, storno_un_successful_refund_to_bank_account: 202,
      bank_transfer_payment_fee: 203
    }

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
      self.payee = ::Barion.config.default_payee if payee.nil?
    end

    def total=(value)
      value = calc_item_totals if value.nil?
      super
    end

    def serialize_options
      { except: %i[id status created_at updated_at transaction_type related_id],
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
        except: %i[items],
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
