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
require 'test_helper'

module Barion
  class PaymentTransactionTest < ActiveSupport::TestCase
    setup do
      Barion.poskey = 'test'
      @transaction = build(:barion_payment_transaction)
      @transaction.payment = build(:barion_payment)
    end

    test 'comment is not mandatory' do
      @transaction.comment = nil
      assert_valid @transaction
    end

    test 'currency not mandatory and takes it from payment' do
      @transaction.currency = nil
      assert_valid @transaction
      assert_equal @transaction.payment.currency, @transaction.currency
      @transaction.payment.currency = :HUF
      @transaction.currency = :EUR
      assert_valid @transaction
      refute_equal @transaction.payment.currency, @transaction.currency
    end

    test 'payee is mandatory' do
      @transaction.payee = nil
      refute_valid @transaction
    end

    test 'status is mandatory' do
      assert_equal 'Prepared', @transaction.status
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
      @transaction.total = 10
      assert_equal 10, @transaction.total
      @transaction.total = nil
      assert_equal 147, @transaction.total
      assert_valid @transaction
    end

    test 'transaction_time is not mandatory' do
      @transaction.transaction_time = nil
      assert_valid @transaction
    end

    test 'pos_transaction_id is mandatory' do
      @transaction.pos_transaction_id = nil
      refute_valid @transaction
    end
  end
end
