# frozen_string_literal: true

require 'test_helper'

module Barion
  class PaymentTest < ActiveSupport::TestCase
    setup do
      @poskey = 'test_poskey'
      Barion.configure do |conf|
        conf.poskey = @poskey
      end
      @payment = Barion::Payment.new
    end

    test 'poskey comes from configuration' do
      assert_equal @poskey, @payment.poskey
    end

    test 'payment type has default value' do
      assert_equal :immediate, @payment.payment_type
    end

    test 'payment type can be set' do
      @payment.payment_type = :reservation
      assert_equal :reservation, @payment.payment_type
    end

    test 'payment type allows only valid values' do
      assert_raises 'ArgumentError' do
        @payment.payment_type = 'Test'
      end
    end

    test 'reservation period nil by default' do
      assert_nil @payment.reservation_period
    end

    test 'reservation period required only if payment type is reservation' do
      assert_nil @payment.reservation_period
      assert_raises 'ArgumentError' do
        @payment.reservation_period = 1
      end

      @payment.payment_type = :reservation
      @payment.reservation_period = 60
    end

    test 'reservation period default value is 30min if payment type is reservation' do
      @payment.payment_type = :reservation
      assert_equal 1_800, @payment.reservation_period
    end

    test 'reservation period min value is 1min' do
      @payment.payment_type = :reservation
      assert_raises 'ArgumentError' do
        @payment.reservation_period = 59
      end
    end

    test 'reservation period max value is 1year' do
      @payment.payment_type = :reservation
      assert_raises 'ArgumentError' do
        @payment.reservation_period = 31_536_001
      end
    end

    test 'delayed capture period required only if payment type is delayed capture' do
      assert_nil @payment.delayed_capture_period
      assert_raises 'ArgumentError' do
        @payment.delayed_capture_period = 60
      end

      @payment.payment_type = :delayed_capture
      @payment.delayed_capture_period = 60
    end

    test 'delayed capture period default value is 7days if payment type is delayed capture' do
      @payment.payment_type = :delayed_capture
      assert_equal 604_800, @payment.delayed_capture_period
    end

    test 'delayed capture period min value is 1min' do
      @payment.payment_type = :delayed_capture
      assert_raises 'ArgumentError' do
        @payment.delayed_capture_period = 59
      end
    end

    test 'delayed capture period max value is 7days' do
      @payment.payment_type = :delayed_capture
      assert_raises 'ArgumentError' do
        @payment.delayed_capture_period = 604_801
      end
    end

    test 'payment window default value is 30mins' do
      assert_equal 1_800, @payment.payment_window
    end

    test 'payment window min value is 1min' do
      assert_raises 'ArgumentError' do
        @payment.payment_window = 59
      end
    end

    test 'payment window max value is 7days' do
      assert_raises 'ArgumentError' do
        @payment.delayed_capture_period = 604_801
      end
    end

    test 'guest checkout is bool' do
      @payment.guest_checkout = 'test'
      assert_equal true, @payment.guest_checkout
      @payment.guest_checkout = nil
      assert_equal false, @payment.guest_checkout
      @payment.guest_checkout = true
      assert_equal true, @payment.guest_checkout
      @payment.guest_checkout = false
      assert_equal false, @payment.guest_checkout
    end

    test 'guest checkout default true' do
      assert_equal true, @payment.guest_checkout
    end

    test 'initiate recurrence is bool' do
      @payment.initiate_recurrence = 'test'
      assert_equal true, @payment.initiate_recurrence
      @payment.initiate_recurrence = nil
      assert_equal false, @payment.initiate_recurrence
      @payment.initiate_recurrence = true
      assert_equal true, @payment.initiate_recurrence
      @payment.initiate_recurrence = false
      assert_equal false, @payment.initiate_recurrence
    end

    test 'initiate recurrence default false' do
      assert_equal false, @payment.initiate_recurrence
    end

    test 'recurrence id max 100chars' do
      assert_raises 'ArgumentError' do
        @payment.recurrence_id = "#{rnd_str(10, 10)}a"
      end
      @payment.recurrence_id = rnd_str(10, 10)
      assert_equal 100, @payment.recurrence_id.length, msg: @payment.recurrence_id
    end

    test 'funding sources default value is all' do
      assert_equal :all, @payment.funding_sources
    end

    test 'funding sources can be set' do
      @payment.funding_sources = :balance
      assert_equal :balance, @payment.funding_sources
    end

    test 'funding sources allows only valid values' do
      assert_raises 'ArgumentError' do
        @payment.funding_sources = :none
      end
    end

    test 'payment request id unique' do
      ids = []
      1000.times do
        obj = Barion::Payment.new
        refute ids.include?(obj.payment_request_id), msg: obj.payment_request_id
        ids << obj.payment_request_id
      end
    end

    test 'payment request id contains shop acronym' do
      assert_match(/\d+/, @payment.payment_request_id)
      Barion.configure do |conf|
        conf.shop_acronym = 'SHOP'
      end
      @payment = Barion::Payment.new
      assert_match(/^SHOP\d+/, @payment.payment_request_id)
    end

    test 'payment request id max lenght 100chars' do
      Barion.configure do |conf|
        conf.shop_acronym = rnd_str(10, 10)
      end
      @payment = Barion::Payment.new
      assert_equal 100, @payment.payment_request_id.length, msg: @payment.payment_request_id
    end

    test 'payer hint max length 256chars' do
      assert_nil @payment.payer_hint
      @payment.payer_hint = rnd_str(8, 33)
      assert_equal 256, @payment.payer_hint.length, msg: @payment.payer_hint
    end

    test 'card holder name hint between 2 to 45chars' do
      assert_nil @payment.card_holder_name_hint
      assert_raises 'ArgumentError' do
        @payment.card_holder_name_hint = 'a'
      end
      @payment.card_holder_name_hint = "#{rnd_str(9, 5)}a"
      assert_equal 45, @payment.card_holder_name_hint.length, msg: @payment.card_holder_name_hint
    end

    test 'recurrence type default nil' do
      assert_nil @payment.recurrence_type
    end

    test 'recurrence type can be set' do
      assert_nil @payment.recurrence_type
      @payment.recurrence_type = :recurring
      assert_equal :recurring, @payment.recurrence_type
    end

    test 'recurrence type allows only valid values' do
      assert_raises 'ArgumentError' do
        @payment.recurrence_type = :none
      end
    end

    test 'trace id max length 100chars' do
      assert_nil @payment.trace_id
      assert_raises 'ArgumentError' do
        @payment.trace_id = "#{rnd_str(10, 10)}a"
      end
      @payment.trace_id = rnd_str(10, 10)
      assert_equal 100, @payment.trace_id.length, msg: @payment.trace_id
    end

    test 'redirect url max length 2000chars' do
      assert_nil @payment.redirect_url
      assert_raises 'ArgumentError' do
        @payment.redirect_url = "#{rnd_str(10, 200)}a"
      end
      @payment.redirect_url = rnd_str(10, 200)
      assert_equal 2_000, @payment.redirect_url.length, msg: @payment.redirect_url
    end

    test 'callback url max length 2000chars' do
      assert_nil @payment.callback_url
      assert_raises 'ArgumentError' do
        @payment.callback_url = "#{rnd_str(10, 200)}a"
      end
      @payment.callback_url = rnd_str(10, 200)
      assert_equal 2_000, @payment.callback_url.length, msg: @payment.callback_url
    end

    test 'transactions has at least one element' do
      assert_equal 1, @payment.transactions.size
      assert_instance_of Barion::Transaction, @payment.transactions[0]
    end

    test 'order number max length 100chars' do
      assert_nil @payment.order_number
      assert_raises 'ArgumentError' do
        @payment.order_number = "#{rnd_str(10, 10)}a"
      end
      @payment.order_number = rnd_str(10, 10)
      assert_equal 100, @payment.order_number.length, msg: @payment.order_number
    end

    test 'shipping address is address or nil' do
      assert_nil @payment.shipping_address
      assert_raises 'ArgumentError' do
        @payment.shipping_address = []
      end
      @payment.shipping_address = Barion::Address.new
      assert_instance_of Barion::Address, @payment.shipping_address
    end

    test 'locale has default value' do
      assert_equal 'hu-HU', @payment.locale
    end

    test 'locale can be set' do
      @payment.locale = 'de-DE'
      assert_equal 'de-DE', @payment.locale
    end

    test 'locale allows only valid values' do
      assert_raises 'ArgumentError' do
        @payment.locale = 'Test'
      end
    end

    test 'currency has default value' do
      assert_equal :HUF, @payment.currency
    end

    test 'currency can be set' do
      @payment.currency = :CZK
      assert_equal :CZK, @payment.currency
    end

    test 'currency allows only valid values' do
      assert_raises 'ArgumentError' do
        @payment.currency = 'Test'
      end
    end

    test 'payer phone number defaults to nil' do
      assert_nil @payment.payer_phone_number
    end

    test 'payer phone number formats number' do
      @payment.payer_phone_number = '+36201234567'
      assert_equal '36201234567', @payment.payer_phone_number
      @payment.payer_phone_number = '0036201234567'
      assert_equal '36201234567', @payment.payer_phone_number
      @payment.payer_phone_number = '06201234567'
      assert_equal '06201234567', @payment.payer_phone_number
    end

    test 'payer phone number max 30chars' do
      assert_raises 'ArgumentError' do
        @payment.payer_phone_number = '+3620123456789123456789123456789'
      end
    end

    test 'payer work phone number formats number' do
      @payment.payer_work_phone_number = '+36201234567'
      assert_equal '36201234567', @payment.payer_phone_number
      @payment.payer_work_phone_number = '0036201234567'
      assert_equal '36201234567', @payment.payer_phone_number
      @payment.payer_work_phone_number = '06201234567'
      assert_equal '06201234567', @payment.payer_phone_number
    end

    test 'payer work phone number max 30chars' do
      assert_raises 'ArgumentError' do
        @payment.payer_work_phone_number = '+3620123456789123456789123456789'
      end
    end

    test 'payer home phone number formats number' do
      @payment.payer_home_phone_number = '+36201234567'
      assert_equal '36201234567', @payment.payer_phone_number
      @payment.payer_home_phone_number = '0036201234567'
      assert_equal '36201234567', @payment.payer_phone_number
      @payment.payer_home_phone_number = '06201234567'
      assert_equal '06201234567', @payment.payer_phone_number
    end

    test 'payer home phone number max 30chars' do
      assert_raises 'ArgumentError' do
        @payment.payer_home_phone_number = '+3620123456789123456789123456789'
      end
    end

    test 'billing address is address or nil' do
      assert_nil @payment.billing_address
      assert_raises 'ArgumentError' do
        @payment.billing_address = []
      end
      @payment.billing_address = Barion::Address.new
      assert_instance_of Barion::Address, @payment.billing_address
    end

    test 'payer account' do
      skip
    end

    test 'purchase information' do
      skip
    end

    test 'challenge preference' do
      skip
    end
  end
end
