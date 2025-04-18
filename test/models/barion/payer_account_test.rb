# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_payer_accounts
#
#  id                               :integer          not null, primary key
#  account_change_indicator         :integer
#  account_created                  :datetime
#  account_creation_indicator       :integer
#  account_last_changed             :datetime
#  password_change_indicator        :integer
#  password_last_changed            :datetime
#  payment_method_added             :datetime
#  provision_attempts               :integer
#  purchases_in_the_last_6_months   :integer
#  shipping_address_added           :datetime
#  shipping_address_usage_indicator :integer
#  suspicious_activity_indicator    :integer          default("no_suspicious_activity_observed")
#  transactional_activity_per_day   :integer
#  transactional_activity_per_year  :integer
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  account_id                       :string(64)
#  payment_id                       :integer
#
# Indexes
#
#  index_barion_payer_accounts_on_account_id  (account_id)
#  index_barion_payer_accounts_on_payment_id  (payment_id)
#
require 'test_helper'

module Barion
  class PayerAccountTest < ActiveSupport::TestCase
    setup do
      ::Barion::Engine.routes.default_url_options[:host] = 'example.com'
      @payer = ::Barion::PayerAccount.new
      @payer.payment = ::Barion::Payment.new
      @json = @payer.as_json
      @date = '2019-06-27 07:15:51.327'.to_datetime
    end

    test 'account id has no default value' do
      assert_nil @payer.account_id
      assert_valid @payer
      refute @json['AccountId']
    end

    test 'account id can be set' do
      assert_nil @payer.account_id
      refute @json['AccountId']
      assert_valid @payer
      @payer.account_id = 'Test'

      assert_equal 'Test', @payer.account_id
      assert_equal 'Test', @payer.as_json['AccountId']
      assert_valid @payer
    end

    test 'account id max 64chars' do
      assert_nil @payer.account_id
      assert_valid @payer
      @payer.account_id = Faker::String.random(length: 65)

      refute_valid @payer
      @payer.account_id = Faker::String.random(length: 64)

      assert_valid @payer
      assert_equal 64, @payer.account_id.length, @payer.account_id
    end

    test 'account change indicator has default value' do
      assert_equal 'changed_during_this_transaction', @payer.account_change_indicator
      assert_equal 0, @json['AccountChangeIndicator']
    end

    test 'account change indicator can be set' do
      @payer.account_change_indicator = :less_than_30_days

      assert_equal 'less_than_30_days', @payer.account_change_indicator
      assert_equal 10, @payer.as_json['AccountChangeIndicator']
    end

    test 'account change indicator allows only valid values' do
      assert_raises ArgumentError do
        @payer.account_change_indicator = 'Test'
      end
    end

    test 'account_created can be set' do
      assert_nil @payer.account_created
      assert_valid @payer
      refute @json['AccountCreated']
      @payer.account_created = @date

      assert_valid @payer
      assert_equal @date, @payer.as_json['AccountCreated']
      assert_equal '2019-06-27T07:15:51.327', @payer.as_json['AccountCreated']
    end

    test 'account creation indicator has default value' do
      assert_equal 'no_account', @payer.account_creation_indicator
      assert_equal 0, @json['AccountCreationIndicator']
    end

    test 'account creation indicator can be set' do
      @payer.account_creation_indicator = :less_than_30_days

      assert_equal 'less_than_30_days', @payer.account_creation_indicator
      assert_equal 20, @payer.as_json['AccountCreationIndicator']
    end

    test 'account creation indicator allows only valid values' do
      assert_raises ArgumentError do
        @payer.account_creation_indicator = 'Test'
      end
    end

    test 'account_last_changed can be set' do
      assert_nil @payer.account_last_changed
      refute @json['AccountLastChanged']
      assert_valid @payer
      @payer.account_last_changed = @date

      assert_equal @date, @payer.account_last_changed
      assert_equal '2019-06-27T07:15:51.327', @payer.as_json['AccountLastChanged']
      assert_valid @payer
    end

    test 'password change indicator has default value' do
      assert_equal 'no_change', @payer.password_change_indicator
      assert_equal 0, @json['PasswordChangeIndicator']
    end

    test 'password change indicator can be set' do
      @payer.password_change_indicator = :less_than_30_days

      assert_equal 'less_than_30_days', @payer.password_change_indicator
      assert_equal 20, @payer.as_json['PasswordChangeIndicator']
    end

    test 'password change indicator allows only valid values' do
      assert_raises ArgumentError do
        @payer.password_change_indicator = 'Test'
      end
    end

    test 'password_last_changed can be set' do
      assert_nil @payer.password_last_changed
      refute @json['PasswordLastChanged']
      assert_valid @payer
      @payer.password_last_changed = @date

      assert_equal @date, @payer.password_last_changed
      assert_equal '2019-06-27T07:15:51.327', @payer.as_json['PasswordLastChanged']
      assert_valid @payer
    end

    test 'payment_method_added can be set' do
      assert_nil @payer.payment_method_added
      refute @json['PaymentMethodAdded']
      assert_valid @payer
      @payer.payment_method_added = true

      assert @payer.payment_method_added
      assert @payer.as_json['PaymentMethodAdded']
      assert_valid @payer
    end

    test 'provision attempts has no default value' do
      assert_nil @payer.provision_attempts
      refute @json['ProvisionAttempts']
      assert_valid @payer
    end

    test 'provision attempts can be set' do
      assert_nil @payer.provision_attempts
      refute @json['ProvisionAttempts']
      assert_valid @payer
      @payer.provision_attempts = 10

      assert_equal 10, @payer.provision_attempts
      assert_equal 10, @payer.as_json['ProvisionAttempts']
      assert_valid @payer
    end

    test 'provision_attempts between 0 and 999 and integer only' do
      assert_nil @payer.provision_attempts
      assert_valid @payer
      @payer.provision_attempts = 1_000

      refute_valid @payer
      @payer.provision_attempts = 999

      assert_equal 999, @payer.as_json['ProvisionAttempts']
      assert_valid @payer
      @payer.provision_attempts = -1

      refute_valid @payer
      @payer.provision_attempts = 0

      assert_equal 0, @payer.as_json['ProvisionAttempts']
      assert_valid @payer
      @payer.provision_attempts = 'Test'

      refute_valid @payer
    end

    test 'purchases_in_the_last_6_months has no default value' do
      assert_nil @payer.purchases_in_the_last_6_months
      refute @json['PurchasesInTheLast6Months']
      assert_valid @payer
    end

    test 'purchases_in_the_last_6_months can be set' do
      assert_nil @payer.purchases_in_the_last_6_months
      refute @json['PurchasesInTheLast6Months']
      assert_valid @payer
      @payer.purchases_in_the_last_6_months = 10

      assert_equal 10, @payer.purchases_in_the_last_6_months
      assert_equal 10, @payer.as_json['PurchasesInTheLast6Months']
      assert_valid @payer
    end

    test 'purchases_in_the_last_6_months between 0 and 9999 and integer only' do
      assert_nil @payer.purchases_in_the_last_6_months
      assert_valid @payer
      refute @json['PurchasesInTheLast6Months']
      @payer.purchases_in_the_last_6_months = 10_000

      refute_valid @payer
      @payer.purchases_in_the_last_6_months = 9_999

      assert_valid @payer
      assert_equal 9_999, @payer.as_json['PurchasesInTheLast6Months']
      @payer.purchases_in_the_last_6_months = -1

      refute_valid @payer
      @payer.purchases_in_the_last_6_months = 0

      assert_valid @payer
      assert_equal 0, @payer.as_json['PurchasesInTheLast6Months']
      @payer.purchases_in_the_last_6_months = 'Test'

      refute_valid @payer
    end

    test 'shipping_address_usage_indicator has default value' do
      assert_equal 'this_transaction', @payer.shipping_address_usage_indicator
      assert_equal 0, @json['ShippingAddressUsageIndicator']
    end

    test 'shipping_address_usage_indicator can be set' do
      @payer.shipping_address_usage_indicator = :less_than_30_days

      assert_equal 'less_than_30_days', @payer.shipping_address_usage_indicator
      assert_equal 10, @payer.as_json['ShippingAddressUsageIndicator']
    end

    test 'shipping_address_usage_indicator allows only valid values' do
      assert_raises ArgumentError do
        @payer.shipping_address_usage_indicator = 'Test'
      end
    end

    test 'suspicious_activity_indicator has default value' do
      assert_equal 'no_suspicious_activity_observed', @payer.suspicious_activity_indicator
      assert_equal 0, @json['SuspiciousActivityIndicator']
    end

    test 'suspicious_activity_indicator can be set' do
      @payer.suspicious_activity_indicator = :suspicious_activity_observed

      assert_equal 'suspicious_activity_observed', @payer.suspicious_activity_indicator
      assert_equal 10, @payer.as_json['SuspiciousActivityIndicator']
    end

    test 'suspicious_activity_indicator allows only valid values' do
      assert_raises ArgumentError do
        @payer.suspicious_activity_indicator = 'Test'
      end
    end

    test 'transactional_activity_per_day has no default value' do
      assert_nil @payer.transactional_activity_per_day
      assert_valid @payer
      refute @json['TransactionalActivityPerDay']
    end

    test 'transactional_activity_per_day can be set' do
      assert_nil @payer.transactional_activity_per_day
      refute @json['TransactionalActivityPerDay']
      assert_valid @payer
      @payer.transactional_activity_per_day = 10

      assert_equal 10, @payer.transactional_activity_per_day
      assert_equal 10, @payer.as_json['TransactionalActivityPerDay']
      assert_valid @payer
    end

    test 'transactional_activity_per_day between 0 and 9999 and integer only' do
      assert_nil @payer.transactional_activity_per_day
      assert_valid @payer
      @payer.transactional_activity_per_day = 1_000

      refute_valid @payer
      @payer.transactional_activity_per_day = 999

      assert_equal 999, @payer.as_json['TransactionalActivityPerDay']
      assert_valid @payer
      @payer.transactional_activity_per_day = -1

      refute_valid @payer
      @payer.transactional_activity_per_day = 0

      assert_equal 0, @payer.as_json['TransactionalActivityPerDay']
      assert_valid @payer
      @payer.transactional_activity_per_day = 'Test'

      refute_valid @payer
    end

    test 'transactional_activity_per_year has no default value' do
      assert_nil @payer.transactional_activity_per_year
      refute @json['TransactionalActivityPerYear']
      assert_valid @payer
    end

    test 'transactional_activity_per_year can be set' do
      assert_nil @payer.transactional_activity_per_year
      assert_valid @payer
      @payer.transactional_activity_per_year = 10

      assert_equal 10, @payer.transactional_activity_per_year
      assert_equal 10, @payer.as_json['TransactionalActivityPerYear']
      assert_valid @payer
    end

    test 'transactional_activity_per_year between 0 and 9999 and integer only' do
      assert_nil @payer.transactional_activity_per_year
      assert_valid @payer
      @payer.transactional_activity_per_year = 1_000

      refute_valid @payer
      @payer.transactional_activity_per_year = 999

      assert_equal 999, @payer.as_json['TransactionalActivityPerYear']
      assert_valid @payer
      @payer.transactional_activity_per_year = -1

      refute_valid @payer
      @payer.transactional_activity_per_year = 0

      assert_equal 0, @payer.as_json['TransactionalActivityPerYear']
      assert_valid @payer
      @payer.transactional_activity_per_year = 'Test'

      refute_valid @payer
    end
  end
end
