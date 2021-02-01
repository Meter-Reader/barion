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
#  suspicious_activity_indicator    :integer          default(0)
#  transactional_activity_per_day   :integer
#  transactional_activity_per_year  :integer
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  account_id                       :string(64)
#  payment_id                       :bigint
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
      @payer = Barion::PayerAccount.new
      @payer.payment = Barion::Payment.new
    end

    test 'account id has no default value' do
      assert_nil @payer.account_id
      assert_valid @payer
    end

    test 'account id can be set' do
      assert_nil @payer.account_id
      assert_valid @payer
      @payer.account_id = 'Test'
      assert_equal 'Test', @payer.account_id
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
      assert_equal 'ChangedDuringThisTransaction', @payer.account_change_indicator
    end

    test 'account change indicator can be set' do
      @payer.account_change_indicator = :LessThan30Days
      assert_equal 'LessThan30Days', @payer.account_change_indicator
    end

    test 'account change indicator allows only valid values' do
      assert_raises ArgumentError do
        @payer.account_change_indicator = 'Test'
      end
    end

    test 'account_created can be set' do
      assert_nil @payer.account_created
      assert_valid @payer
      @payer.account_created = DateTime.now
      assert_valid @payer
    end

    test 'account creation indicator has default value' do
      assert_equal 'NoAccount', @payer.account_creation_indicator
    end

    test 'account creation indicator can be set' do
      @payer.account_creation_indicator = :LessThan30Days
      assert_equal 'LessThan30Days', @payer.account_creation_indicator
    end

    test 'account creation indicator allows only valid values' do
      assert_raises ArgumentError do
        @payer.account_creation_indicator = 'Test'
      end
    end

    test 'account_last_changed can be set' do
      assert_nil @payer.account_last_changed
      assert_valid @payer
      @payer.account_last_changed = DateTime.now
      assert_valid @payer
    end

    test 'password change indicator has default value' do
      assert_equal 'NoChange', @payer.password_change_indicator
    end

    test 'password change indicator can be set' do
      @payer.password_change_indicator = :LessThan30Days
      assert_equal 'LessThan30Days', @payer.password_change_indicator
    end

    test 'password change indicator allows only valid values' do
      assert_raises ArgumentError do
        @payer.password_change_indicator = 'Test'
      end
    end

    test 'password_last_changed can be set' do
      assert_nil @payer.password_last_changed
      assert_valid @payer
      @payer.password_last_changed = DateTime.now
      assert_valid @payer
    end

    test 'payment_method_added can be set' do
      assert_nil @payer.payment_method_added
      assert_valid @payer
      @payer.payment_method_added = DateTime.now
      assert_valid @payer
    end

    test 'provision attempts has no default value' do
      assert_nil @payer.provision_attempts
      assert_valid @payer
    end

    test 'provision attempts can be set' do
      assert_nil @payer.provision_attempts
      assert_valid @payer
      @payer.provision_attempts = 10
      assert_equal 10, @payer.provision_attempts
      assert_valid @payer
    end

    test 'provision_attempts between 0 and 999 and integer only' do
      assert_nil @payer.provision_attempts
      assert_valid @payer
      @payer.provision_attempts = 1_000
      refute_valid @payer
      @payer.provision_attempts = 999
      assert_valid @payer
      @payer.provision_attempts = -1
      refute_valid @payer
      @payer.provision_attempts = 0
      assert_valid @payer
      @payer.provision_attempts = 'Test'
      refute_valid @payer
    end

    test 'purchases_in_the_last_6_months has no default value' do
      assert_nil @payer.purchases_in_the_last_6_months
      assert_valid @payer
    end

    test 'purchases_in_the_last_6_months can be set' do
      assert_nil @payer.purchases_in_the_last_6_months
      assert_valid @payer
      @payer.purchases_in_the_last_6_months = 10
      assert_equal 10, @payer.purchases_in_the_last_6_months
      assert_valid @payer
    end

    test 'purchases_in_the_last_6_months between 0 and 9999 and integer only' do
      assert_nil @payer.purchases_in_the_last_6_months
      assert_valid @payer
      @payer.purchases_in_the_last_6_months = 10_000
      refute_valid @payer
      @payer.purchases_in_the_last_6_months = 9_999
      assert_valid @payer
      @payer.purchases_in_the_last_6_months = -1
      refute_valid @payer
      @payer.purchases_in_the_last_6_months = 0
      assert_valid @payer
      @payer.purchases_in_the_last_6_months = 'Test'
      refute_valid @payer
    end

    test 'shipping_address_usage_indicator has default value' do
      assert_equal 'ThisTransaction', @payer.shipping_address_usage_indicator
    end

    test 'shipping_address_usage_indicator can be set' do
      @payer.shipping_address_usage_indicator = :LessThan30Days
      assert_equal 'LessThan30Days', @payer.shipping_address_usage_indicator
    end

    test 'shipping_address_usage_indicator allows only valid values' do
      assert_raises ArgumentError do
        @payer.shipping_address_usage_indicator = 'Test'
      end
    end

    test 'suspicious_activity_indicator has default value' do
      assert_equal 'NoSuspiciousActivityObserved', @payer.suspicious_activity_indicator
    end

    test 'suspicious_activity_indicator can be set' do
      @payer.suspicious_activity_indicator = :SuspiciousActivityObserved
      assert_equal 'SuspiciousActivityObserved', @payer.suspicious_activity_indicator
    end

    test 'suspicious_activity_indicator allows only valid values' do
      assert_raises ArgumentError do
        @payer.suspicious_activity_indicator = 'Test'
      end
    end

    test 'transactional_activity_per_day has no default value' do
      assert_nil @payer.transactional_activity_per_day
      assert_valid @payer
    end

    test 'transactional_activity_per_day can be set' do
      assert_nil @payer.transactional_activity_per_day
      assert_valid @payer
      @payer.transactional_activity_per_day = 10
      assert_equal 10, @payer.transactional_activity_per_day
      assert_valid @payer
    end

    test 'transactional_activity_per_day between 0 and 9999 and integer only' do
      assert_nil @payer.transactional_activity_per_day
      assert_valid @payer
      @payer.transactional_activity_per_day = 1_000
      refute_valid @payer
      @payer.transactional_activity_per_day = 999
      assert_valid @payer
      @payer.transactional_activity_per_day = -1
      refute_valid @payer
      @payer.transactional_activity_per_day = 0
      assert_valid @payer
      @payer.transactional_activity_per_day = 'Test'
      refute_valid @payer
    end

    test 'transactional_activity_per_year has no default value' do
      assert_nil @payer.transactional_activity_per_year
      assert_valid @payer
    end

    test 'transactional_activity_per_year can be set' do
      assert_nil @payer.transactional_activity_per_year
      assert_valid @payer
      @payer.transactional_activity_per_year = 10
      assert_equal 10, @payer.transactional_activity_per_year
      assert_valid @payer
    end

    test 'transactional_activity_per_year between 0 and 9999 and integer only' do
      assert_nil @payer.transactional_activity_per_year
      assert_valid @payer
      @payer.transactional_activity_per_year = 1_000
      refute_valid @payer
      @payer.transactional_activity_per_year = 999
      assert_valid @payer
      @payer.transactional_activity_per_year = -1
      refute_valid @payer
      @payer.transactional_activity_per_year = 0
      assert_valid @payer
      @payer.transactional_activity_per_year = 'Test'
      refute_valid @payer
    end
  end
end
