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
#  payment_id                 :integer
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
      ::Barion::Engine.routes.default_url_options[:host] = 'example.com'
      @purchase = ::Barion::Purchase.new
      @purchase.payment = ::Barion::Payment.new
      @json = @purchase.as_json
      @date = '2019-06-27 07:15:51.327'.to_datetime
    end

    test 'availability_indicator has default value' do
      assert_valid @purchase
      assert_equal 'merchandise_available', @purchase.availability_indicator
      assert_equal 0, @json['AvailabilityIndicator']
    end

    test 'availability_indicator can be set' do
      @purchase.availability_indicator = :future_availability
      assert_equal 'future_availability', @purchase.availability_indicator
      assert_equal 10, @purchase.as_json['AvailabilityIndicator']
    end

    test 'availability_indicator allows only valid values' do
      assert_raises ArgumentError do
        @purchase.availability_indicator = 'Test'
      end
    end

    test 'delivery_email_address has no deafult value' do
      assert_valid @purchase
      assert_nil @purchase.delivery_email_address
      refute @json['DeliveryEmailAddress']
    end

    test 'delivery_email_address can be set' do
      assert_valid @purchase
      refute @json['DeliveryEmailAddress']
      @purchase.delivery_email_address = 'Test'
      assert_valid @purchase
      assert_equal 'Test', @purchase.delivery_email_address
      assert_equal 'Test', @purchase.as_json['DeliveryEmailAddress']
    end

    test 'delivery_timeframe has no default value' do
      assert_valid @purchase
      assert_nil @purchase.delivery_timeframe
      refute @json['DeliveryTimeframe']
    end

    test 'delivery_timeframe can be set' do
      assert_valid @purchase
      refute @json['DeliveryTimeframe']
      @purchase.delivery_timeframe = :electronic_delivery
      assert_valid @purchase
      assert_equal 'electronic_delivery', @purchase.delivery_timeframe
      assert @purchase.electronic_delivery?
      assert_equal 0, @purchase.as_json['DeliveryTimeframe']
    end

    test 'delivery_timeframe allows only valid values' do
      assert_raises ArgumentError do
        @purchase.delivery_timeframe = 'Test'
      end
    end

    test 'pre_order_date has no default value' do
      assert_nil @purchase.pre_order_date
      assert_valid @purchase
      refute @json['PrePrderDate']
    end

    test 'pre_order_date can be set' do
      assert_valid @purchase
      refute @json['PreOrderDate']
      @purchase.pre_order_date = @date
      assert_valid @purchase
      assert_equal '2019-06-27T07:15:51.327', @purchase.as_json['PreOrderDate']
    end

    test 'purchase_date has no default value' do
      assert_nil @purchase.purchase_date
      assert_valid @purchase
    end

    test 'purchase_date can be set' do
      assert_valid @purchase
      @purchase.purchase_date = @date
      assert_valid @purchase
      assert_equal '2019-06-27T07:15:51.327', @purchase.as_json['PurchaseDate']
    end

    test 'purchase_type has no default value' do
      assert_valid @purchase
      assert_nil @purchase.purchase_type
      refute @json['PurchaseType']
    end

    test 'purchase_type can be set' do
      assert_valid @purchase
      refute @json['PurchaseType']
      @purchase.purchase_type = :goods_and_service_purchase
      assert_valid @purchase
      assert_equal 'goods_and_service_purchase', @purchase.purchase_type
      assert_equal 0, @purchase.as_json['PurchaseType']
      assert @purchase.goods_and_service_purchase?
    end

    test 'purchase_type allows only valid values' do
      assert_raises ArgumentError do
        @purchase.purchase_type = 'Test'
      end
    end

    test 're_order_indicator has no default value' do
      assert_valid @purchase
      assert_nil @purchase.re_order_indicator
      refute @json['ReOrderIndicator']
    end

    test 're_order_indicator can be set' do
      assert_valid @purchase
      refute @json['ReOrderIndicator']
      @purchase.re_order_indicator = :first_time_ordered
      assert_valid @purchase
      assert_equal 'first_time_ordered', @purchase.re_order_indicator
      assert_equal 'FirstTimeOrdered', @purchase.as_json['ReOrderIndicator']
      assert @purchase.first_time_ordered?
    end

    test 're_order_indicator allows only valid values' do
      assert_raises ArgumentError do
        @purchase.re_order_indicator = 'Test'
      end
    end

    test 'recurring_expiry has no default value' do
      assert_nil @purchase.recurring_expiry
      assert_valid @purchase
      refute @json['RecurringExpiry']
    end

    test 'recurring_expiry can be set' do
      assert_valid @purchase
      @purchase.recurring_expiry = @date
      assert_valid @purchase
      assert_equal @date, @purchase.recurring_expiry
      assert_equal '2019-06-27T07:15:51.327', @purchase.as_json['RecurringExpiry']
    end

    test 'recurring_frequency has no default value' do
      assert_valid @purchase
      assert_nil @purchase.recurring_frequency
      refute @json['RecurringFrequency']
    end

    test 'recurring_frequency can be set' do
      assert_valid @purchase
      refute @json['RecurringFrequency']
      @purchase.recurring_frequency = 60
      assert_valid @purchase
      assert_equal 60, @purchase.recurring_frequency
      assert_equal 60, @purchase.as_json['RecurringFrequency']
    end

    test 'recurring_frequency between 0 and 9999 and only integer' do
      assert_valid @purchase
      refute @json['RecurringFrequency']
      @purchase.recurring_frequency = 0
      assert_valid @purchase
      assert_equal 0, @purchase.as_json['RecurringFrequency']
      @purchase.recurring_frequency = 10_000
      refute_valid @purchase
      @purchase.recurring_frequency = 0
      assert_valid @purchase
      assert_equal 0, @purchase.as_json['RecurringFrequency']
      @purchase.recurring_frequency = -1
      refute_valid @purchase
      @purchase.recurring_frequency = 1
      assert_valid @purchase
      assert_equal 1, @purchase.as_json['RecurringFrequency']
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
      @purchase.recurring_expiry = @date
      assert_valid @purchase
      assert_equal 30, @purchase.as_json['RecurringFrequency']
      assert_equal '2019-06-27T07:15:51.327', @purchase.as_json['RecurringExpiry']
    end

    test 'shipping_address_indicator has no default value' do
      assert_valid @purchase
      assert_nil @purchase.shipping_address_indicator
      refute @json['ShippingAddressIndicator']
    end

    test 'shipping_address_indicator can be set' do
      assert_valid @purchase
      refute @json['ShippingAddressIndicator']
      @purchase.shipping_address_indicator = :ship_to_cardholders_billing_address
      assert_valid @purchase
      assert_equal 'ship_to_cardholders_billing_address', @purchase.shipping_address_indicator
      assert_equal 0, @purchase.as_json['ShippingAddressIndicator']
      assert @purchase.ship_to_cardholders_billing_address?
    end

    test 'shipping_address_indicator allows only valid values' do
      assert_raises ArgumentError do
        @purchase.shipping_address_indicator = 'Test'
      end
    end

    test 'gift_card_purchase has no default value' do
      assert_valid @purchase
      assert_nil @purchase.gift_card_purchase
      refute @json['GiftCardPurchase']
    end

    test 'gift_card_purchase can be set' do
      @purchase.gift_card_purchase = build(:barion_gift_card_purchase, purchase: @purchase)
      assert_valid @purchase
      assert @purchase.as_json['GiftCardPurchase']
    end
  end
end
