# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_payments
#
#  id                      :integer          not null, primary key
#  callback_url            :string(2000)
#  card_holder_name_hint   :string(45)
#  challenge_preference    :integer          default("no_preference")
#  checksum                :string           not null
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
#  payment_id              :string
#  payment_request_id      :string(100)
#  recurrence_id           :string(100)
#  trace_id                :string(100)
#
# Indexes
#
#  index_barion_payments_on_order_number        (order_number)
#  index_barion_payments_on_payment_id          (payment_id)
#  index_barion_payments_on_payment_request_id  (payment_request_id)
#  index_barion_payments_on_payment_type        (payment_type)
#  index_barion_payments_on_poskey              (poskey)
#  index_barion_payments_on_recurrence_id       (recurrence_id)
#  index_barion_payments_on_status              (status)
#
require 'test_helper'

module Barion
  # Test cases for Barion::Payment model
  class PaymentTest < ActiveSupport::TestCase
    setup do
      @poskey = 'test_poskey'
      Barion.poskey = @poskey
      @payment = build(:barion_payment)
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

    test 'payment type sets reservation period' do
      assert_nil @payment.reservation_period
      assert_valid @payment
      @payment.payment_type = :reservation
      assert_equal 1_800, @payment.reservation_period
      assert @payment.reservation?
      @payment.payment_type = :immediate
      assert_nil @payment.reservation_period
      refute @payment.reservation?
    end

    test 'reservation period nil by default' do
      assert_nil @payment.reservation_period
    end

    test 'reservation period required only if payment type is reservation' do
      assert_nil @payment.reservation_period
      assert_valid @payment
      @payment.payment_type = :reservation
      assert @payment.reservation?
      @payment.reservation_period = 1
      assert_equal 1, @payment.reservation_period
      refute_valid @payment
    end

    test 'reservation period default value is 30min if payment type is reservation' do
      @payment.payment_type = :reservation
      assert_equal 1_800, @payment.reservation_period
    end

    test 'reservation period min value is 1min' do
      @payment.payment_type = :reservation
      assert_valid @payment
      @payment.reservation_period = 59
      refute_valid @payment
    end

    test 'reservation period max value is 1year' do
      @payment.payment_type = :reservation
      assert_valid @payment
      @payment.reservation_period = 31_556_953
      refute_valid @payment
    end

    test 'delayed capture period required only if payment type is delayed capture' do
      assert_nil @payment.delayed_capture_period
      assert_valid @payment
      @payment.delayed_capture_period = 60
      refute_valid @payment
      @payment.payment_type = :delayed_capture
      @payment.delayed_capture_period = 60
      assert_valid @payment
    end

    test 'delayed capture period default value is 7days if payment type is delayed capture' do
      @payment.payment_type = :delayed_capture
      assert_equal 604_800, @payment.delayed_capture_period
    end

    test 'delayed capture period min value is 1min' do
      @payment.payment_type = :delayed_capture
      assert_valid @payment
      @payment.delayed_capture_period = 59
      refute_valid @payment
    end

    test 'delayed capture period max value is 7days' do
      @payment.payment_type = :delayed_capture
      assert_valid @payment
      @payment.delayed_capture_period = 604_801
      refute_valid @payment
    end

    test 'payment window default value is 30mins' do
      assert_equal 1_800, @payment.payment_window
    end

    test 'payment window min value is 1min' do
      assert_valid @payment
      @payment.payment_window = 59
      refute_valid @payment
    end

    test 'payment window max value is 7days' do
      assert_valid @payment
      @payment.payment_window = 604_801
      refute_valid @payment
    end

    test 'guest checkout is bool' do
      @payment.guest_check_out = true
      assert @payment.guest_check_out
      @payment.guest_check_out = false
      refute @payment.guest_check_out
      @payment.guest_check_out = 'test'
      assert @payment.guest_check_out
      @payment.guest_check_out = nil
      refute @payment.guest_check_out
    end

    test 'guest checkout default true' do
      assert_equal true, @payment.guest_check_out
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
      assert_valid @payment
      @payment.recurrence_id = Faker::String.random(length: 101)
      refute_valid @payment
      @payment.recurrence_id = Faker::String.random(length: 100)
      assert_valid @payment
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
        obj = build(:barion_payment)
        obj.valid?
        refute ids.include?(obj.payment_request_id), msg: obj.payment_request_id
        ids << obj.payment_request_id
      end
    end

    test 'payment request id contains shop acronym' do
      @payment.valid?
      assert_match(/\d+/, @payment.payment_request_id)
      Barion.acronym = 'SHOP'
      @payment = build(:barion_payment)
      @payment.valid?
      assert_match(/^SHOP\d+/, @payment.payment_request_id)
    end

    test 'card holder name hint between 2 and 45chars' do
      assert_nil @payment.card_holder_name_hint
      assert_valid @payment
      @payment.card_holder_name_hint = 'a'
      refute_valid @payment
      @payment.card_holder_name_hint = Faker::String.random(length: 46)
      refute_valid @payment
    end

    test 'recurrence type default nil' do
      assert_nil @payment.recurrence_type
    end

    test 'recurrence type can be set' do
      assert_nil @payment.recurrence_type, @payment.recurrence_type
      @payment.recurrence_type = :recurring
      assert_valid @payment
      assert_equal 'recurring', @payment.recurrence_type
      @payment.recurrence_type = :one_click
      assert_valid @payment
      @payment.recurrence_type = :merchant_initiated
      assert_valid @payment
    end

    test 'recurrence type allows only valid values' do
      assert_raises ArgumentError do
        @payment.recurrence_type = :none
      end
    end

    test 'trace id max length 100chars' do
      assert_nil @payment.trace_id
      assert_valid @payment
      @payment.trace_id = Faker::String.random(length: 101)
      refute_valid @payment
      @payment.trace_id = Faker::String.random(length: 100)
      assert_equal 100, @payment.trace_id.length, msg: @payment.trace_id
    end

    test 'redirect url max length 2000chars' do
      @payment.redirect_url = Faker::String.random(length: 2001)
      refute_valid @payment
      @payment.redirect_url = Faker::String.random(length: 2000)
      assert_equal 2_000, @payment.redirect_url.length, msg: @payment.redirect_url
    end

    test 'callback url max length 2000chars' do
      @payment.callback_url = Faker::String.random(length: 2001)
      refute_valid @payment
      @payment.callback_url = Faker::String.random(length: 2000)
      assert_equal 2_000, @payment.callback_url.length, msg: @payment.callback_url
    end

    test 'gateway url max length 2000chars' do
      @payment.gateway_url = Faker::String.random(length: 2001)
      refute_valid @payment
      @payment.gateway_url = Faker::String.random(length: 2000)
      assert_equal 2_000, @payment.gateway_url.length, msg: @payment.gateway_url
    end

    test 'qr url max length 2000chars' do
      @payment.qr_url = Faker::String.random(length: 2001)
      refute_valid @payment
      @payment.qr_url = Faker::String.random(length: 2000)
      assert_equal 2_000, @payment.qr_url.length, msg: @payment.qr_url
    end
    test 'transactions has at least one element' do
      assert @payment.payment_transactions.size.positive?
      assert_instance_of ::Barion::PaymentTransaction, @payment.payment_transactions[0]
    end

    test 'order number max length 100chars' do
      assert_nil @payment.order_number
      assert_valid @payment
      @payment.order_number = ::Faker::String.random(length: 101)
      refute_valid @payment
      @payment.order_number = ::Faker::String.random(length: 100)
      assert_valid @payment
      assert_equal 100, @payment.order_number.length, msg: @payment.order_number
    end

    test 'payer hint has no default value' do
      assert_nil @payment.payer_hint
      assert_valid @payment
    end

    test 'payer hint can be set' do
      assert_nil @payment.payer_hint
      assert_valid @payment
      @payment.payer_hint = 'test'
      assert_valid @payment
    end

    test 'payer hint max length 256chars' do
      assert_nil @payment.payer_hint
      assert_valid @payment
      @payment.payer_hint = ::Faker::String.random(length: 257)
      refute_valid @payment
      @payment.payer_hint = ::Faker::String.random(length: 256)
      assert_valid @payment
      assert_equal 256, @payment.payer_hint.length, msg: @payment.payer_hint
    end

    test 'shipping address is address or nil' do
      assert_raise ::ActiveRecord::AssociationTypeMismatch do
        @payment.shipping_address = []
      end
      @payment.shipping_address = build(:barion_address)
      assert_instance_of ::Barion::Address, @payment.shipping_address
    end

    test 'locale has default value' do
      assert_equal 'hu-HU', @payment.locale
    end

    test 'locale can be set' do
      @payment.locale = 'de-DE'
      assert_equal 'de-DE', @payment.locale
    end

    test 'locale allows only valid values' do
      assert_raises ArgumentError do
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
      assert_raises ArgumentError do
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
      assert_valid @payment
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
      assert_valid @payment
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
      assert_valid @payment
      @payment.payer_home_number = '+3620123456789123456789123456789'
      assert_equal '362012345678912345678912345678', @payment.payer_home_number
    end

    test 'billing address is address or nil' do
      assert_nil @payment.billing_address
      assert_valid @payment
      @payment.billing_address = build(:barion_address, payment: @payment)
      assert_instance_of ::Barion::Address, @payment.billing_address
    end

    test 'status has a default value' do
      assert_equal 'initial', @payment.status
    end

    test 'status can be set' do
      assert_equal 'initial', @payment.status
      assert_valid @payment
      @payment.status = :prepared
      assert_equal 'prepared', @payment.status
      assert_valid @payment
    end

    test 'status allows only valid values' do
      assert_raises ArgumentError do
        @payment.status = 'Test'
      end
    end

    test 'payer account default nil' do
      assert_nil @payment.payer_account
      assert_valid @payment
    end

    test 'payer account can be set' do
      assert_nil @payment.payer_account
      assert_valid @payment
      @payment.payer_account = build(:barion_payer_account)
      assert_valid @payment
    end

    test 'purchase information default nil' do
      assert_nil @payment.purchase_information
      assert_valid @payment
    end

    test 'purchase information can be set' do
      assert_nil @payment.purchase_information
      assert_valid @payment
      @payment.purchase_information = build(:barion_purchase)
      assert_valid @payment
    end

    test 'challenge preference default NoPreference' do
      assert_equal 'no_preference', @payment.challenge_preference
      assert_valid @payment
    end

    test 'challenge preference can be set' do
      assert_valid @payment
      @payment.challenge_preference = :challenge_required
      assert_valid @payment
      assert_equal 'challenge_required', @payment.challenge_preference
    end

    test 'challenge preference only allows valid values' do
      assert_valid @payment
      assert_raises ArgumentError do
        @payment.challenge_preference = 'Test'
      end
    end

    test 'recurrence_result has no default' do
      assert_nil @payment.recurrence_result
      assert_valid @payment
    end

    test 'recurrence_result can be set' do
      assert_valid @payment
      @payment.recurrence_result = :none
      assert_valid @payment
      assert_equal 'none', @payment.recurrence_result
      @payment.recurrence_result = :successful
      assert_valid @payment
      assert_equal 'successful', @payment.recurrence_result
      @payment.recurrence_result = :failed
      assert_valid @payment
      assert_equal 'failed', @payment.recurrence_result
      @payment.recurrence_result = :not_found
      assert_valid @payment
      assert_equal 'not_found', @payment.recurrence_result
    end

    test 'recurrence_result only allows valid values' do
      assert_valid @payment
      assert_raises ArgumentError do
        @payment.recurrence_result = 'Test'
      end
    end

    test 'payment is readonly if not in initalization status' do
      assert_valid @payment
      assert @payment.initial?
      refute @payment.readonly?
      @payment.status = :prepared
      refute @payment.initial?
      assert @payment.readonly?
      assert_raises ::ActiveRecord::ReadOnlyRecord do
        @payment.save
      end
    end

    test 'checksum relates to the current state of the payment' do
      sum = @payment.checksum
      @payment.status = :prepared
      @payment.valid?
      refute_equal sum, @payment.checksum
    end

    test 'checksum is readonly' do
      assert_raises NoMethodError do
        @payment.checksum = 'test'
      end
      refute_equal 'test', @payment.checksum
    end

    test 'checksum is persisted on save' do
      @payment = create(:barion_payment)
      sum = @payment.checksum
      table = ::Arel::Table.new(:barion_payments)
      sql = table.project('checksum').where(table[:id].eq(@payment.id)).take(1).to_sql
      result = ::ActiveRecord::Base.connection.execute sql
      assert_equal sum, result.first['checksum']
    end

    test 'checksum is checked when loading from db' do
      @payment = create(:barion_payment)
      # simulate external data tampering by skipping callback
      @payment.update_column(:status, ::Barion::Payment.statuses[:succeeded])

      assert_raises ::Barion::TamperedData do
        payment = ::Barion::Payment.find(@payment.id) # data change detected, raise exception
        refute_equal @payment.as_json, payment.as_json
        refute_equal @payment.sum, payment.checksum
      end
    end

    test 'payment as json have the correct format' do
      @payment.valid?
      json = @payment.as_json
      assert json, json
      assert json['POSKey'], json.to_s
      assert json['PaymentType'], json.to_s
      # assert json['ReservationPeriod']
      # assert json['DelayedCapturePeriod']
      # assert json['PaymentWindow']
      assert json['GuestCheckOut'], json.to_s
      # assert json['InitiateRecurrence']
      # assert json['RecurrenceId']
      assert json['FundingSources'], json.to_s
      assert json['PaymentRequestId'], json.to_s
      # assert json['PayerHint']
      # assert json['CardHolderNameHint']
      # assert json['RecurrenceType']
      # assert json['TraceId']
      assert json['RedirectUrl'], json.to_s
      assert json['CallbackUrl'], json.to_s
      assert json['Transactions'], json.to_s
      # assert json['OrderNumber']
      # assert json['ShippingAddress']
      assert json['Locale'], json.to_s
      assert json['Currency'], json.to_s
      # assert json['PayerPhoneNumber']
      # assert json['PayerWorkPhoneNumber']
      # assert json['PayerHomeNumber']
      # assert json['BillingAddress']
      # assert json['PayerAccount']
      # assert json['PurchaseInformation']
      # assert json['ChallengePreference']
      refute json['PaymentId'], json.to_s
      refute json['Status'], json.to_s
      refute json['QRUrl'], json.to_s
      refute json['RecurrenceResult'], json.to_s
      refute json['GatewayUrl'], json.to_s
    end

    test 'payment can only be executed if valid' do
      @payment.payment_type = :reservation
      @payment.reservation_period = 59
      refute @payment.valid?
      refute @payment.execute
      @payment.payment_type = :immediate
      assert @payment.valid?
      assert_raise Barion::Error do
        result = @payment.execute
        refute_equal false, result
      end
    end
  end
end
