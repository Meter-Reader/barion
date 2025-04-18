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
#  completed_at            :datetime
#  created_at_barion       :datetime
#  currency                :string(3)        not null
#  delayed_capture_period  :integer
#  delayed_capture_until   :datetime
#  fraud_risk_score        :integer
#  funding_source          :integer
#  funding_sources         :integer          default("all")
#  gateway_url             :string(2000)
#  guest_check_out         :boolean
#  initiate_recurrence     :boolean
#  locale                  :string(10)       not null
#  order_number            :string(100)
#  payer_hint              :string(256)
#  payer_home_number       :string(30)
#  payer_phone_number      :string(30)
#  payer_work_phone_number :string(30)
#  payment_type            :integer          default("immediate"), not null
#  payment_window          :string(6)
#  pos_name                :string
#  pos_owner_country       :string
#  pos_owner_email         :string
#  poskey                  :string           not null
#  qr_url                  :string(2000)
#  recurrence_result       :integer
#  recurrence_type         :integer          default(NULL)
#  redirect_url            :string(2000)
#  reservation_period      :integer
#  reserved_until          :datetime
#  started_at              :datetime
#  status                  :integer          not null
#  suggested_local         :string
#  total                   :decimal(, )
#  valid_until             :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  payment_id              :string
#  payment_request_id      :string(100)
#  pos_id                  :string
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
  class PaymentApiTest < ActiveSupport::TestCase
    setup do
      ::Barion::Engine.routes.default_url_options[:host] = 'example.com'
      ::Barion.config.sandbox = true
      @payment = build(:fix_barion_payment)
      tr = build(:fix_barion_payment_transaction)
      tr.items << build(:fix_barion_item)
      @payment.payment_transactions << tr
      @payment.save
    end

    test 'valid payment processing' do
      assert_valid @payment
      ::VCR.use_cassette('payment_start') do
        begin
          assert_nil @payment.gateway_url
          assert_nil @payment.qr_url
          assert @payment.execute
          refute_nil @payment.gateway_url
          refute_nil @payment.qr_url
        rescue ::Barion::Error
          refute $ERROR_INFO, $ERROR_INFO.all_errors
        end

        assert_equal 'prepared', @payment.status
      end
    end

    test 'proxy method exists for requesting payment state' do
      ::VCR.use_cassette('payment_start') do
        @payment.execute
      end
      ::VCR.use_cassette('payment_status') do
        @payment.refresh_state

        assert_equal 'hu-HU', @payment.locale
        assert_equal 'HUF', @payment.currency
        refute_nil @payment.pos_id
        refute_nil @payment.pos_owner_country
        refute_nil @payment.pos_owner_email
      rescue ::Barion::Error
        refute $ERROR_INFO, $ERROR_INFO.all_errors
      end
    end
  end
end
