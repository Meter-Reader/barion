# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_purchases
#
#  id                         :integer          not null, primary key
#  availability_indicator     :integer
#  delivery_email_address     :string
#  delivery_timeframe         :integer
#  pre_order_date             :datetime
#  purchase_date              :datetime
#  purchase_type              :integer
#  re_order_indicator         :integer
#  recurring_expiry           :datetime
#  recurring_frequency        :integer
#  shipping_address_indicator :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  payment_id                 :bigint
#
# Indexes
#
#  index_barion_purchases_on_delivery_email_address  (delivery_email_address)
#  index_barion_purchases_on_delivery_timeframe      (delivery_timeframe)
#  index_barion_purchases_on_payment_id              (payment_id)
#
require 'test_helper'

module Barion
  # Test cases for Barion::Purchase
  class PurchaseTest < ActiveSupport::TestCase
    setup do
      @purchase = Barion::Purchase.new
      @purchase.payment = Barion::Payment.new
    end

    test 'availability_indicator has default value' do
      assert_valid @purchase
      @purchase.availability_indicator = 'MerchandiseAvailable'
    end

    test 'availability_indicator can be set' do
      @purchase.availability_indicator = :MerchandiseAvailable
      assert_equal 'MerchandiseAvailable', @purchase.availability_indicator
    end

    test 'availability_indicator allows only valid values' do
      assert_raises ArgumentError do
        @purchase.availability_indicator = 'Test'
      end
    end

    test 'delivery_email_address has no deafult value' do
      assert_valid @purchase
      assert_nil @purchase.delivery_email_address
    end

    test 'delivery_email_address can be set' do
      assert_valid @purchase
      @purchase.delivery_email_address = 'Test'
      assert_valid @purchase
      assert_equal 'Test', @purchase.delivery_email_address
    end

    test 'delivery_timeframe has no default value' do
      assert_valid @purchase
      assert_nil @purchase.delivery_timeframe
    end

    test 'delivery_timeframe can be set' do
      assert_valid @purchase
      @purchase.delivery_timeframe = :ElectronicDelivery
      assert_valid @purchase
      assert_equal 'ElectronicDelivery', @purchase.delivery_timeframe
      assert @purchase.ElectronicDelivery?
    end

    test 'delivery_timeframe allows only valid values' do
      assert_raises ArgumentError do
        @purchase.delivery_timeframe = 'Test'
      end
    end

    test 'pre_order_date has no default value' do
      assert_nil @purchase.pre_order_date
      assert_valid @purchase
    end

    test 'pre_order_date can be set' do
      assert_valid @purchase
      @purchase.pre_order_date = DateTime.now
      assert_valid @purchase
    end

    test 'purchase_date has no default value' do
      assert_nil @purchase.purchase_date
      assert_valid @purchase
    end

    test 'purchase_date can be set' do
      assert_valid @purchase
      @purchase.purchase_date = DateTime.now
      assert_valid @purchase
    end

    test 'purchase_type has no default value' do
      assert_valid @purchase
      assert_nil @purchase.purchase_type
    end

    test 'purchase_type can be set' do
      assert_valid @purchase
      @purchase.purchase_type = :GoodsAndServicePurchase
      assert_valid @purchase
      assert_equal 'GoodsAndServicePurchase', @purchase.purchase_type
      assert @purchase.GoodsAndServicePurchase?
    end

    test 'purchase_type allows only valid values' do
      assert_raises ArgumentError do
        @purchase.purchase_type = 'Test'
      end
    end

    test 're_order_indicator has no default value' do
      assert_valid @purchase
      assert_nil @purchase.re_order_indicator
    end

    test 're_order_indicator can be set' do
      assert_valid @purchase
      @purchase.re_order_indicator = :FirstTimeOrdered
      assert_valid @purchase
      assert_equal 'FirstTimeOrdered', @purchase.re_order_indicator
      assert @purchase.FirstTimeOrdered?
    end

    test 're_order_indicator allows only valid values' do
      assert_raises ArgumentError do
        @purchase.re_order_indicator = 'Test'
      end
    end

    test 'recurring_expiry has no default value' do
      assert_nil @purchase.recurring_expiry
      assert_valid @purchase
    end

    test 'recurring_expiry can be set' do
      assert_valid @purchase
      @purchase.recurring_expiry = DateTime.now
      assert_valid @purchase
    end

    test 'recurring_frequency has no default value' do
      assert_valid @purchase
      assert_nil @purchase.recurring_frequency
    end

    test 'recurring_frequency can be set' do
      assert_valid @purchase
      @purchase.recurring_frequency = 60
      assert_valid @purchase
      assert_equal 60, @purchase.recurring_frequency
    end

    test 'recurring_frequency between 0 and 9999 and only integer' do
      assert_valid @purchase
      @purchase.recurring_frequency = 0
      assert_valid @purchase
      @purchase.recurring_frequency = 10_000
      refute_valid @purchase
      @purchase.recurring_frequency = 0
      assert_valid @purchase
      @purchase.recurring_frequency = -1
      refute_valid @purchase
      @purchase.recurring_frequency = 1
      assert_valid @purchase
      @purchase.recurring_frequency = 1.2
      refute_valid @purchase
    end

    test 'recurring_frequency is mandatory if payment initiat recurrence' do
      assert_valid @purchase
      @purchase.payment.initiate_recurrence = true
      assert_valid @purchase
      @purchase.payment.recurrence_type = :recurring
      refute_valid @purchase
      @purchase.recurring_frequency = 30
      refute_valid @purchase
      @purchase.recurring_expiry = DateTime.now
      assert_valid @purchase
    end

    test 'shipping_address_indicator has no default value' do
      assert_valid @purchase
      assert_nil @purchase.shipping_address_indicator
    end

    test 'shipping_address_indicator can be set' do
      assert_valid @purchase
      @purchase.shipping_address_indicator = :ShipToCardholdersBillingAddress
      assert_valid @purchase
      assert_equal 'ShipToCardholdersBillingAddress', @purchase.shipping_address_indicator
      assert @purchase.ShipToCardholdersBillingAddress?
    end

    test 'shipping_address_indicator allows only valid values' do
      assert_raises ArgumentError do
        @purchase.shipping_address_indicator = 'Test'
      end
    end

    test 'gift_card_purchase has no default value' do
      assert_valid @purchase
      assert_nil @purchase.gift_card_purchase
    end

    test 'gift_card_purchase can be set' do
      @purchase.gift_card_purchase = Barion::GiftCardPurchase.new
      assert_valid @purchase
    end
  end
end
