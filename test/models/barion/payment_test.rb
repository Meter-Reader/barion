# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_payments
#
#  id                      :integer          not null, primary key
#  callback_url            :string(2000)
#  card_holder_name_hint   :string(45)
#  challenge_preference    :string
#  checksum                :string
#  currency                :string(3)        not null
#  delayed_capture_period  :integer
#  funding_sources         :integer          default("all")
#  gateway_url             :string(2000)
#  guest_checkout          :boolean
#  initiate_recurrence     :boolean
#  locale                  :string(10)       not null
#  order_number            :string(100)
#  payer_hint              :string(256)
#  payer_home_number       :string(30)
#  payer_phone_number      :string(30)
#  payer_work_phone_number :string(30)
#  payment_type            :integer          default("immediate"), not null
#  payment_window          :string(6)
#  poskey                  :string           not null
#  qr_url                  :string(2000)
#  recurrence_result       :integer
#  recurrence_type         :integer          default(NULL)
#  redirect_url            :string(2000)
#  reservation_period      :integer
#  status                  :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  billing_address_id      :bigint
#  payer_account_id        :bigint
#  payment_id              :string
#  payment_request_id      :string(100)
#  purchase_information_id :bigint
#  recurrence_id           :string(100)
#  shipping_address_id     :bigint
#  trace_id                :string(100)
#
# Indexes
#
#  index_barion_payments_on_billing_address_id       (billing_address_id)
#  index_barion_payments_on_order_number             (order_number)
#  index_barion_payments_on_payer_account_id         (payer_account_id)
#  index_barion_payments_on_payment_id               (payment_id)
#  index_barion_payments_on_payment_request_id       (payment_request_id)
#  index_barion_payments_on_payment_type             (payment_type)
#  index_barion_payments_on_poskey                   (poskey)
#  index_barion_payments_on_purchase_information_id  (purchase_information_id)
#  index_barion_payments_on_recurrence_id            (recurrence_id)
#  index_barion_payments_on_shipping_address_id      (shipping_address_id)
#  index_barion_payments_on_status                   (status)
#
# Foreign Keys
#
#  billing_address_id       (billing_address_id => barion_addresses.id)
#  payer_account_id         (payer_account_id => barion_payer_accounts.id)
#  purchase_information_id  (purchase_information_id => barion_purchases.id)
#  shipping_address_id      (shipping_address_id => barion_addresses.id)
#
require 'test_helper'

module Barion
  class PaymentTest < ActiveSupport::TestCase
    setup do
      @poskey = 'test_poskey'
      Barion.poskey = @poskey
      @payment = Barion::Payment.new
      @payment.transactions.build
      @payment.payer_account = barion_payer_accounts(:one)
    end

    test 'poskey comes from configuration' do
      assert_equal @poskey, @payment.poskey
    end

    test 'poskey can be set on instance' do
      @payment.poskey = 'test2'
      assert_equal 'test2', @payment.poskey
    end

    test 'payment type has default value' do
      assert_equal 'immediate', @payment.payment_type
    end

    test 'payment type can be set' do
      @payment.payment_type = :reservation
      assert_equal 'reservation', @payment.payment_type
    end

    test 'payment type allows only valid values' do
      assert_raises ArgumentError do
        @payment.payment_type = 'Test'
      end
    end

    test 'reservation period nil by default' do
      assert_nil @payment.reservation_period
    end

    test 'reservation period required only if payment type is reservation' do
      assert_nil @payment.reservation_period
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.payment_type = :reservation
      assert @payment.reservation?
      @payment.reservation_period = 1
      assert_equal 1, @payment.reservation_period
      refute @payment.valid?
    end

    test 'reservation period default value is 30min if payment type is reservation' do
      @payment.payment_type = :reservation
      assert_equal 1_800, @payment.reservation_period
    end

    test 'reservation period min value is 1min' do
      @payment.payment_type = :reservation
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.reservation_period = 59
      refute @payment.valid?
    end

    test 'reservation period max value is 1year' do
      @payment.payment_type = :reservation
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.reservation_period = 31_556_953
      refute @payment.valid?
    end

    test 'delayed capture period required only if payment type is delayed capture' do
      assert_nil @payment.delayed_capture_period
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.delayed_capture_period = 60
      refute @payment.valid?
      @payment.payment_type = :delayed_capture
      @payment.delayed_capture_period = 60
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
    end

    test 'delayed capture period default value is 7days if payment type is delayed capture' do
      @payment.payment_type = :delayed_capture
      assert_equal 604_800, @payment.delayed_capture_period
    end

    test 'delayed capture period min value is 1min' do
      @payment.payment_type = :delayed_capture
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.delayed_capture_period = 59
      refute @payment.valid?
    end

    test 'delayed capture period max value is 7days' do
      @payment.payment_type = :delayed_capture
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.delayed_capture_period = 604_801
      refute @payment.valid?
    end

    test 'payment window default value is 30mins' do
      assert_equal 1_800, @payment.payment_window
    end

    test 'payment window min value is 1min' do
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.payment_window = 59
      refute @payment.valid?
    end

    test 'payment window max value is 7days' do
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.payment_window = 604_801
      refute @payment.valid?
    end

    test 'guest checkout is bool' do
      @payment.guest_checkout = true
      assert @payment.guest_checkout
      @payment.guest_checkout = false
      refute @payment.guest_checkout
      @payment.guest_checkout = 'test'
      assert @payment.guest_checkout
      @payment.guest_checkout = nil
      refute @payment.guest_checkout
    end

    test 'guest checkout default true' do
      assert_equal true, @payment.guest_checkout
    end

    test 'initiate recurrence is bool' do
      @payment.initiate_recurrence = 'test'
      assert @payment.initiate_recurrence
      @payment.initiate_recurrence = nil
      refute @payment.initiate_recurrence
      @payment.initiate_recurrence = true
      assert @payment.initiate_recurrence
      @payment.initiate_recurrence = false
      refute @payment.initiate_recurrence
    end

    test 'initiate recurrence default false' do
      refute @payment.initiate_recurrence
    end

    test 'recurrence id max 100chars' do
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.recurrence_id = Faker::String.random(length: 101)
      refute @payment.valid?
      @payment.recurrence_id = Faker::String.random(length: 100)
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      assert_equal 100, @payment.recurrence_id.length, msg: @payment.recurrence_id
    end

    test 'funding sources default value is all' do
      assert_equal 'all', @payment.funding_sources
    end

    test 'funding sources can be set' do
      @payment.funding_sources = :balance
      assert_equal 'balance', @payment.funding_sources
    end

    test 'funding sources allows only valid values' do
      assert_raises ArgumentError do
        @payment.funding_sources = :none
      end
    end

    test 'payment request id unique' do
      ids = []
      1000.times do
        obj = Barion::Payment.new
        obj.valid?
        refute ids.include?(obj.payment_request_id), msg: obj.payment_request_id
        ids << obj.payment_request_id
      end
    end

    test 'payment request id contains shop acronym' do
      @payment.valid?
      assert_match(/\d+/, @payment.payment_request_id)
      Barion.acronym = 'SHOP'
      @payment = Barion::Payment.new
      @payment.valid?
      assert_match(/^SHOP\d+/, @payment.payment_request_id)
    end

    test 'card holder name hint between 2 and 45chars' do
      assert_nil @payment.card_holder_name_hint
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.card_holder_name_hint = 'a'
      refute @payment.valid?
      @payment.card_holder_name_hint = Faker::String.random(length: 46)
      refute @payment.valid?
    end

    test 'recurrence type default nil' do
      assert_nil @payment.recurrence_type
    end

    test 'recurrence type can be set' do
      assert_nil @payment.recurrence_type, @payment.recurrence_type
      @payment.recurrence_type = :recurring
      assert_equal 'recurring', @payment.recurrence_type
    end

    test 'recurrence type allows only valid values' do
      assert_raises 'ArgumentError' do
        @payment.recurrence_type = :none
      end
    end

    test 'trace id max length 100chars' do
      assert_nil @payment.trace_id
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.trace_id = Faker::String.random(length: 101)
      refute @payment.valid?
      @payment.trace_id = Faker::String.random(length: 100)
      assert_equal 100, @payment.trace_id.length, msg: @payment.trace_id
    end

    test 'redirect url max length 2000chars' do
      assert_nil @payment.redirect_url
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.redirect_url = Faker::String.random(length: 2001)
      refute @payment.valid?
      @payment.redirect_url = Faker::String.random(length: 2000)
      assert_equal 2_000, @payment.redirect_url.length, msg: @payment.redirect_url
    end

    test 'callback url max length 2000chars' do
      assert_nil @payment.callback_url
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.callback_url = Faker::String.random(length: 2001)
      refute @payment.valid?
      @payment.callback_url = Faker::String.random(length: 2000)
      assert_equal 2_000, @payment.callback_url.length, msg: @payment.callback_url
    end

    test 'transactions has at least one element' do
      assert_equal 1, @payment.transactions.size
      assert_instance_of Barion::Transaction, @payment.transactions[0]
    end

    test 'order number max length 100chars' do
      assert_nil @payment.order_number
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.order_number = Faker::String.random(length: 101)
      refute @payment.valid?
      @payment.order_number = Faker::String.random(length: 100)
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      assert_equal 100, @payment.order_number.length, msg: @payment.order_number
    end

    test 'shipping address is address or nil' do
      assert_raise ActiveRecord::AssociationTypeMismatch do
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
      assert_equal 'HUF', @payment.currency
    end

    test 'currency can be set' do
      @payment.currency = :CZK
      assert_equal 'CZK', @payment.currency
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
      assert_nil @payment.payer_phone_number
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.payer_phone_number = '+3620123456789123456789123456789'
      assert @payment.valid?
      assert_equal '362012345678912345678912345678', @payment.payer_phone_number
    end

    test 'payer work phone number formats number' do
      @payment.payer_work_phone_number = '+36201234567'
      assert_equal '36201234567', @payment.payer_work_phone_number
      @payment.payer_work_phone_number = '0036201234567'
      assert_equal '36201234567', @payment.payer_work_phone_number
      @payment.payer_work_phone_number = '06201234567'
      assert_equal '06201234567', @payment.payer_work_phone_number
    end

    test 'payer work phone number max 30chars' do
      assert_nil @payment.payer_work_phone_number
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.payer_work_phone_number = '+3620123456789123456789123456789'
      assert_equal '362012345678912345678912345678', @payment.payer_work_phone_number
    end

    test 'payer home number formats number' do
      @payment.payer_home_number = '+36201234567'
      assert_equal '36201234567', @payment.payer_home_number
      @payment.payer_home_number = '0036201234567'
      assert_equal '36201234567', @payment.payer_home_number
      @payment.payer_home_number = '06201234567'
      assert_equal '06201234567', @payment.payer_home_number
    end

    test 'payer home phone number max 30chars' do
      assert_nil @payment.payer_home_number
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
      @payment.payer_home_number = '+3620123456789123456789123456789'
      assert_equal '362012345678912345678912345678', @payment.payer_home_number
    end

    test 'billing address is address or nil' do
      assert_nil @payment.billing_address
      assert @payment.valid?, @payment.errors.objects.first.try(:full_message)
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
