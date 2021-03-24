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
      ::Barion::Engine.routes.default_url_options[:host] = 'example.com'
      @gcp = build(:barion_gift_card_purchase)
      @gcp.purchase = build(:barion_purchase)
      @gcp.purchase.payment = build(:barion_payment, purchase_information: @gcp.purchase)
      @json = @gcp.as_json
    end

    test 'amount can be set and mandatory' do
      assert @json['Amount']
      @gcp.amount = nil
      refute_valid @gcp
      refute @gcp.as_json['Amount']
      @gcp.amount = 1
      assert_valid @gcp
      assert_equal 1, @gcp.amount
      assert_equal '1', @gcp.as_json['Amount']
    end

    test 'amount bigger then zero' do
      @gcp.amount = 0
      refute_valid @gcp
      @gcp.amount = 1
      assert_valid @gcp
    end

    test 'currency is delegated to payment' do
      assert_equal @gcp.purchase.payment.currency, @gcp.currency
      refute @json['Currency']
      @gcp.purchase.payment.currency = :USD
      assert_equal @gcp.purchase.payment.currency, @gcp.currency
      refute @gcp.as_json['Currency']
    end

    test 'amount precision depends on payment currency' do
      @gcp.purchase.payment.currency = :EUR
      @gcp.amount = 1.55555555
      assert_equal 1.56, @gcp.amount
      assert_equal '1.56', @gcp.as_json['Amount']
      @gcp.purchase.payment.currency = :HUF
      @gcp.amount = 1.55555555
      assert_equal 2, @gcp.amount
      assert_equal '2', @gcp.as_json['Amount']
      @gcp.purchase.payment.currency = :USD
      @gcp.amount = 1.55555555
      assert_equal 1.56, @gcp.amount
      assert_equal '1.56', @gcp.as_json['Amount']
    end

    test 'count can be set and mandatory' do
      @gcp.count = nil
      refute @gcp.as_json['Count']
      refute_valid @gcp
      @gcp.count = 1
      assert_valid @gcp
      assert_equal 1, @gcp.count
      assert_equal 1, @gcp.as_json['Count']
    end

    test 'count valid between 1 and 99' do
      @gcp.count = 0
      refute_valid @gcp
      @gcp.count = 1
      assert_valid @gcp
      assert_equal 1, @gcp.as_json['Count']
      @gcp.count = 100
      refute_valid @gcp
      @gcp.count = 1.2
      refute_valid @gcp
      @gcp.count = 99
      assert_valid @gcp
      assert_equal 99, @gcp.as_json['Count']
    end
  end
end
