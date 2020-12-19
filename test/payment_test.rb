# frozen_string_literal: true

require 'test_helper'
require 'barion/payment'

# Barion payment expected behaviour
class PaymentTest < Minitest::Test
  def setup
    @poskey = 'test_poskey'
    Barion.configure do |conf|
      conf.poskey = @poskey
    end
    @payment = Barion::Payment.new
  end

  def test_poskey_comes_from_configuration
    assert_equal @poskey, @payment.poskey
  end

  def test_payment_type_has_default_value
    assert_equal :immediate, @payment.payment_type
  end

  def test_payment_type_can_be_set
    @payment.payment_type = :reservation
    assert_equal :reservation, @payment.payment_type
  end

  def test_payment_type_allows_only_valid_values
    assert_raises 'ArgumentError' do
      @payment.payment_type = 'Test'
    end
  end

  def test_reservation_period_nil_by_default
    assert_nil @payment.reservation_period
  end

  def test_reservation_period_required_only_if_payment_type_is_reservation
    assert_nil @payment.reservation_period
    assert_raises 'ArgumentError' do
      @payment.reservation_period = 1
    end

    @payment.payment_type = :reservation
    @payment.reservation_period = 60
  end

  def test_reservation_period_default_value_is_30min_if_payment_type_is_reservation
    @payment.payment_type = :reservation
    assert_equal 1_800, @payment.reservation_period
  end

  def test_reservation_period_min_value_is_1min
    @payment.payment_type = :reservation
    assert_raises 'ArgumentError' do
      @payment.reservation_period = 59
    end
  end

  def test_reservation_period_max_value_is_1year
    @payment.payment_type = :reservation
    assert_raises 'ArgumentError' do
      @payment.reservation_period = 31_536_001
    end
  end

  def test_delayed_capture_period_required_only_if_payment_type_is_delayed_capture
    assert_nil @payment.delayed_capture_period
    assert_raises 'ArgumentError' do
      @payment.delayed_capture_period = 60
    end

    @payment.payment_type = :delayed_capture
    @payment.delayed_capture_period = 60
  end

  def test_delayed_capture_period_default_value_is_7days_if_payment_type_is_delayed_capture
    @payment.payment_type = :delayed_capture
    assert_equal 604_800, @payment.delayed_capture_period
  end

  def test_delayed_capture_period_min_value_is_1min
    @payment.payment_type = :delayed_capture
    assert_raises 'ArgumentError' do
      @payment.delayed_capture_period = 59
    end
  end

  def test_delayed_capture_period_max_value_is_7days
    @payment.payment_type = :delayed_capture
    assert_raises 'ArgumentError' do
      @payment.delayed_capture_period = 604_801
    end
  end

  def test_payment_window_default_value_is_30mins
    assert_equal 1_800, @payment.payment_window
  end

  def test_payment_window_min_value_is_1min
    assert_raises 'ArgumentError' do
      @payment.payment_window = 59
    end
  end

  def test_payment_window_max_value_is_7days
    assert_raises 'ArgumentError' do
      @payment.delayed_capture_period = 604_801
    end
  end

  def test_guest_checkout_is_bool
    @payment.guest_checkout = 'test'
    assert_equal true, @payment.guest_checkout
    @payment.guest_checkout = nil
    assert_equal false, @payment.guest_checkout
    @payment.guest_checkout = true
    assert_equal true, @payment.guest_checkout
    @payment.guest_checkout = false
    assert_equal false, @payment.guest_checkout
  end

  def test_guest_checkout_default_true
    assert_equal true, @payment.guest_checkout
  end

  def test_initiate_recurrence_is_bool
    @payment.initiate_recurrence = 'test'
    assert_equal true, @payment.initiate_recurrence
    @payment.initiate_recurrence = nil
    assert_equal false, @payment.initiate_recurrence
    @payment.initiate_recurrence = true
    assert_equal true, @payment.initiate_recurrence
    @payment.initiate_recurrence = false
    assert_equal false, @payment.initiate_recurrence
  end

  def test_initiate_recurrence_default_false
    assert_equal false, @payment.initiate_recurrence
  end

  def test_recurrence_id_max_100chars
    assert_raises 'ArgumentError' do
      @payment.recurrence_id = "#{rnd_str(10, 10)}a"
    end
    @payment.recurrence_id = rnd_str(10, 10)
    assert_equal 100, @payment.recurrence_id.length, msg: @payment.recurrence_id
  end

  def test_funding_sources_default_value_is_all
    assert_equal :all, @payment.funding_sources
  end

  def test_funding_sources_can_be_set
    @payment.funding_sources = :balance
    assert_equal :balance, @payment.funding_sources
  end

  def test_funding_sources_allows_only_valid_values
    assert_raises 'ArgumentError' do
      @payment.funding_sources = :none
    end
  end

  def test_payment_request_id_unique
    ids = []
    1000.times do
      obj = Barion::Payment.new
      refute ids.include?(obj.payment_request_id), msg: obj.payment_request_id
      ids << obj.payment_request_id
    end
  end

  def test_payment_request_id_contains_shop_acronym
    assert_match(/\d+/, @payment.payment_request_id)
    Barion.configure do |conf|
      conf.shop_acronym = 'SHOP'
    end
    @payment = Barion::Payment.new
    assert_match(/^SHOP\d+/, @payment.payment_request_id)
  end

  def test_payment_request_id_max_lenght_100chars
    Barion.configure do |conf|
      conf.shop_acronym = rnd_str(10, 10)
    end
    @payment = Barion::Payment.new
    assert_equal 100, @payment.payment_request_id.length, msg: @payment.payment_request_id
  end

  def test_payer_hint_max_length_256chars
    assert_nil @payment.payer_hint
    @payment.payer_hint = rnd_str(8, 33)
    assert_equal 256, @payment.payer_hint.length, msg: @payment.payer_hint
  end

  def test_card_holder_name_hint_between_2_to_45chars
    assert_nil @payment.card_holder_name_hint
    assert_raises 'ArgumentError' do
      @payment.card_holder_name_hint = 'a'
    end
    @payment.card_holder_name_hint = "#{rnd_str(9, 5)}a"
    assert_equal 45, @payment.card_holder_name_hint.length, msg: @payment.card_holder_name_hint
  end

  def test_recurrence_type_default_nil
    assert_nil @payment.recurrence_type
  end

  def test_recurrence_type_can_be_set
    assert_nil @payment.recurrence_type
    @payment.recurrence_type = :recurring
    assert_equal :recurring, @payment.recurrence_type
  end

  def test_recurrence_type_allows_only_valid_values
    assert_raises 'ArgumentError' do
      @payment.recurrence_type = :none
    end
  end

  def test_trace_id_max_length_100chars
    assert_nil @payment.trace_id
    assert_raises 'ArgumentError' do
      @payment.trace_id = "#{rnd_str(10, 10)}a"
    end
    @payment.trace_id = rnd_str(10, 10)
    assert_equal 100, @payment.trace_id.length, msg: @payment.trace_id
  end

  def test_redirect_url_max_length_2000chars
    assert_nil @payment.redirect_url
    assert_raises 'ArgumentError' do
      @payment.redirect_url = "#{rnd_str(10, 200)}a"
    end
    @payment.redirect_url = rnd_str(10, 200)
    assert_equal 2_000, @payment.redirect_url.length, msg: @payment.redirect_url
  end

  def test_callback_url_max_length_2000chars
    assert_nil @payment.callback_url
    assert_raises 'ArgumentError' do
      @payment.callback_url = "#{rnd_str(10, 200)}a"
    end
    @payment.callback_url = rnd_str(10, 200)
    assert_equal 2_000, @payment.callback_url.length, msg: @payment.callback_url
  end

  def test_transactions
    skip
  end

  def test_order_number_max_length_100chars
    assert_nil @payment.order_number
    assert_raises 'ArgumentError' do
      @payment.order_number = "#{rnd_str(10, 10)}a"
    end
    @payment.order_number = rnd_str(10, 10)
    assert_equal 100, @payment.order_number.length, msg: @payment.order_number
  end

  def test_shipping_address_is_address_or_nil
    assert_nil @payment.shipping_address
    assert_raises 'ArgumentError' do
      @payment.shipping_address = []
    end
    @payment.shipping_address = Barion::Address.new
    assert_instance_of Barion::Address, @payment.shipping_address
  end

  def test_locale_has_default_value
    assert_equal 'hu-HU', @payment.locale
  end

  def test_locale_can_be_set
    @payment.locale = 'de-DE'
    assert_equal 'de-DE', @payment.locale
  end

  def test_locale_allows_only_valid_values
    assert_raises 'ArgumentError' do
      @payment.locale = 'Test'
    end
  end

  def test_currency_has_default_value
    assert_equal :HUF, @payment.currency
  end

  def test_currency_can_be_set
    @payment.currency = :CZK
    assert_equal :CZK, @payment.currency
  end

  def test_currency_allows_only_valid_values
    assert_raises 'ArgumentError' do
      @payment.currency = 'Test'
    end
  end

  def test_payer_phone_number_defaults_to_nil
    assert_nil @payment.payer_phone_number
  end

  def test_payer_phone_number_formats_number
    @payment.payer_phone_number = '+36201234567'
    assert_equal '36201234567', @payment.payer_phone_number
    @payment.payer_phone_number = '0036201234567'
    assert_equal '36201234567', @payment.payer_phone_number
    @payment.payer_phone_number = '06201234567'
    assert_equal '06201234567', @payment.payer_phone_number
  end

  def test_payer_phone_number_max_30chars
    assert_raises 'ArgumentError' do
      @payment.payer_phone_number = '+3620123456789123456789123456789'
    end
  end

  def test_payer_work_phone_number_formats_number
    @payment.payer_work_phone_number = '+36201234567'
    assert_equal '36201234567', @payment.payer_phone_number
    @payment.payer_work_phone_number = '0036201234567'
    assert_equal '36201234567', @payment.payer_phone_number
    @payment.payer_work_phone_number = '06201234567'
    assert_equal '06201234567', @payment.payer_phone_number
  end

  def test_payer_work_phone_number_max_30chars
    assert_raises 'ArgumentError' do
      @payment.payer_work_phone_number = '+3620123456789123456789123456789'
    end
  end

  def test_payer_home_phone_number_formats_number
    @payment.payer_home_phone_number = '+36201234567'
    assert_equal '36201234567', @payment.payer_phone_number
    @payment.payer_home_phone_number = '0036201234567'
    assert_equal '36201234567', @payment.payer_phone_number
    @payment.payer_home_phone_number = '06201234567'
    assert_equal '06201234567', @payment.payer_phone_number
  end

  def test_payer_home_phone_number_max_30chars
    assert_raises 'ArgumentError' do
      @payment.payer_home_phone_number = '+3620123456789123456789123456789'
    end
  end

  def test_billing_address_is_address_or_nil
    assert_nil @payment.billing_address
    assert_raises 'ArgumentError' do
      @payment.billing_address = []
    end
    @payment.billing_address = Barion::Address.new
    assert_instance_of Barion::Address, @payment.billing_address
  end

  def test_payer_account
    skip
  end

  def test_purchase_information
    skip
  end

  def test_challenge_preference
    skip
  end
end
