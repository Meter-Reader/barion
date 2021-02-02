# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_gift_card_purchases
#
#  id          :integer          not null, primary key
#  amount      :decimal(, )      not null
#  count       :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  purchase_id :integer
#
# Indexes
#
#  index_barion_gift_card_purchases_on_purchase_id  (purchase_id)
#
require 'test_helper'

module Barion
  # Represents a Gift card purchase in Barion engine
  class GiftCardPurchaseTest < ActiveSupport::TestCase
    setup do
      @gcp = Barion::GiftCardPurchase.new
      @gcp.purchase = Barion::Purchase.new
      @payment = Barion::Payment.new
      @gcp.purchase.payment = @payment
      @gcp.count = 1
      @gcp.amount = 1
    end

    test 'amount can be set and mandatory' do
      @gcp.amount = nil
      refute_valid @gcp
      @gcp.amount = 1
      assert_valid @gcp
      assert_equal 1, @gcp.amount
    end

    test 'amount bigger then zero' do
      @gcp.amount = 0
      refute_valid @gcp
      @gcp.amount = 1
      assert_valid @gcp
    end

    test 'currency is delegated to payment' do
      assert_equal @gcp.currency, @gcp.purchase.payment.currency
      @payment.currency = :USD
      assert_equal @gcp.currency, @gcp.purchase.payment.currency
    end

    test 'amount precision depends on payment currency' do
      @payment.currency = :EUR
      @gcp.amount = 1.55555555
      assert_equal 1.56, @gcp.amount
      @payment.currency = :HUF
      @gcp.amount = 1.55555555
      assert_equal 2, @gcp.amount
      @payment.currency = :USD
      @gcp.amount = 1.55555555
      assert_equal 1.56, @gcp.amount
    end

    test 'count can be set and mandatory' do
      @gcp.count = nil
      refute_valid @gcp
      @gcp.count = 1
      assert_valid @gcp
      assert_equal 1, @gcp.count
    end

    test 'count valid between 1 and 99' do
      @gcp.count = 0
      refute_valid @gcp
      @gcp.count = 1
      assert_valid @gcp
      @gcp.count = 100
      refute_valid @gcp
      @gcp.count = 1.2
      refute_valid @gcp
      @gcp.count = 99
      assert_valid @gcp
    end
  end
end
