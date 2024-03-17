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
require 'test_helper'

module Barion
  # Tests constrains of transactions in Barion
  class PaymentTransactionTest < ActiveSupport::TestCase
    setup do
      ::Barion::Engine.routes.default_url_options[:host] = 'example.com'
      ::Barion.config.poskey = 'test'
      ::Barion.config.default_payee = 'payee@test'
      @transaction = build(:barion_payment_transaction)
      @transaction.payment = build(:barion_payment)
      @transaction.items << build(:barion_item)
      @json = @transaction.as_json
    end

    test 'comment is not mandatory' do
      @transaction.comment = nil
      refute @json['Comment']
      assert_valid @transaction
    end

    test 'currency not mandatory and takes it from payment' do
      @transaction.currency = nil
      assert_valid @transaction
      assert_equal @transaction.payment.currency, @transaction.currency
      assert_equal @transaction.payment.currency, @json['Currency']
      @transaction.payment.currency = :HUF
      @transaction.currency = :EUR
      assert_valid @transaction
      refute_equal @transaction.payment.currency, @transaction.currency
      assert_equal 'EUR', @transaction.as_json['Currency']
    end

    test 'payee is mandatory and has default' do
      assert_equal ::Barion.config.default_payee, @transaction.payee
      assert_valid @transaction
      @transaction.payee = nil
      refute_valid @transaction
    end

    test 'status is mandatory' do
      assert_equal 'prepared', @transaction.status
      refute @json['Status']
      @transaction.status = nil
      refute_valid @transaction
    end

    test 'total is mandatory and calculated if not set' do
      @transaction.items.first.quantity = 3
      @transaction.items.first.unit_price = 33
      @transaction.items << create(
        :barion_item,
        quantity: 4,
        unit_price: 12,
        payment_transaction: @transaction
      )
      assert_equal 147, @transaction.total
      assert_equal '147.0', @transaction.as_json['Total']
      @transaction.total = 10
      assert_equal 10, @transaction.total
      assert_equal '10.0', @transaction.as_json['Total']
      @transaction.total = nil
      assert_equal 147, @transaction.total
      assert_equal '147.0', @transaction.as_json['Total']
      assert_valid @transaction
    end

    test 'transaction_time is not mandatory' do
      @transaction.transaction_time = nil
      refute @json['TransactionTime']
      assert_valid @transaction
    end

    test 'pos_transaction_id is mandatory' do
      assert @json['POSTransactionId']
      @transaction.pos_transaction_id = nil
      refute_valid @transaction
    end

    test 'items are mandatory and has at least one' do
      assert_valid @transaction
      assert_equal 1, @transaction.items.size
      assert_equal 1, @json['Items'].size
      @transaction.items = []
      refute_valid @transaction
    end

    test 'payer can be set, default nil, not serialized' do
      assert_nil @transaction.payer
      refute @json['Payer']
      @transaction.payer = 'Test'
      assert_equal 'Test', @transaction.payer
      refute @json['Payer']
    end

    test 'status can be set, default "prepared", not serialized' do
      assert_equal 'prepared', @transaction.status
      refute @json['Status']

      @transaction.status = :started
      assert_equal 'started', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :succeeded
      assert_equal 'succeeded', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :timeout
      assert_equal 'timeout', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :shop_is_deleted
      assert_equal 'shop_is_deleted', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :shop_is_closed
      assert_equal 'shop_is_closed', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :rejected
      assert_equal 'rejected', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :rejected_by_shop
      assert_equal 'rejected_by_shop', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :storno
      assert_equal 'storno', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :reserved
      assert_equal 'reserved', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :deleted
      assert_equal 'deleted', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :expired
      assert_equal 'expired', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :authorized
      assert_equal 'authorized', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :reversed
      assert_equal 'reversed', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :invalid_payment_record
      assert_equal 'invalid_payment_record', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :payment_time_out
      assert_equal 'payment_time_out', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :invalid_payment_status
      assert_equal 'invalid_payment_status', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :payment_sender_or_recipient_is_invalid
      assert_equal 'payment_sender_or_recipient_is_invalid', @transaction.status
      refute @transaction.as_json['Status']

      @transaction.status = :unknown
      assert_equal 'unknown', @transaction.status
      refute @transaction.as_json['Status']
    end

    test 'transaction_type can be set, default nil, not serialized' do
      assert_nil @transaction.transaction_type
      refute @json['TransactionType']
      @transaction.transaction_type = :shop
      assert_equal 'shop', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :transfer_to_existing_user
      assert_equal 'transfer_to_existing_user', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :transfer_to_technical_account
      assert_equal 'transfer_to_technical_account', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :reserve
      assert_equal 'reserve', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :storno_reserve
      assert_equal 'storno_reserve', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :card_processing_fee
      assert_equal 'card_processing_fee', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :gateway_fee
      assert_equal 'gateway_fee', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :card_processing_fee_storno
      assert_equal 'card_processing_fee_storno', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :unspecified
      assert_equal 'unspecified', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :card_payment
      assert_equal 'card_payment', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :refund
      assert_equal 'refund', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :refund_to_bank_card
      assert_equal 'refund_to_bank_card', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :storno_un_successful_refund_to_bank_card
      assert_equal 'storno_un_successful_refund_to_bank_card', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :under_review
      assert_equal 'under_review', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :release_review
      assert_equal 'release_review', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :bank_transfer_payment
      assert_equal 'bank_transfer_payment', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :refund_to_bank_account
      assert_equal 'refund_to_bank_account', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :storno_un_successful_refund_to_bank_account
      assert_equal 'storno_un_successful_refund_to_bank_account', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']

      @transaction.transaction_type = :bank_transfer_payment_fee
      assert_equal 'bank_transfer_payment_fee', @transaction.transaction_type
      refute @transaction.as_json['TransactionType']
    end

    test 'related_id can be set, default nil, not serialized' do
      assert_nil @transaction.related_id
      refute @json['RelatedId']
      @transaction.related_id = 'Test'
      assert_equal 'Test', @transaction.related_id
      refute @transaction.as_json['RelatedId']
    end
  end
end
