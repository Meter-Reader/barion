# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_addresses
#
#  id         :integer          not null, primary key
#  city       :string(50)
#  country    :string(2)        default("zz"), not null
#  full_name  :string(45)
#  region     :string(2)
#  street     :string(50)
#  street2    :string(50)
#  street3    :string(50)
#  zip        :string(16)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  payment_id :bigint
#
# Indexes
#
#  index_barion_addresses_on_city        (city)
#  index_barion_addresses_on_country     (country)
#  index_barion_addresses_on_full_name   (full_name)
#  index_barion_addresses_on_payment_id  (payment_id)
#  index_barion_addresses_on_zip         (zip)
#

require 'test_helper'

module Barion
  class AddressTest < ActiveSupport::TestCase
    setup do
      @address = build(:barion_address)
      @address.payment = build(:barion_payment, billing_address: @address)
      @json = @address.as_json
    end

    test 'country has default value' do
      assert_equal 'zz', @address.country
      assert_equal 'zz', @json['Country']
    end

    test 'country can be set' do
      assert_equal 'zz', @address.country
      assert_equal 'zz', @json['Country']
      @address.country = 'HU'
      assert_equal 'HU', @address.country
      assert_equal 'HU', @address.as_json['Country']
    end

    test 'country length 2chars' do
      assert_valid @address
      @address.country = Faker::String.random(length: 3)
      refute_valid @address
      @address.country = 'hu'
      assert_equal 2, @address.country.length, msg: @address.country
      assert_equal 'hu', @address.as_json['Country']
      assert_valid @address
    end

    test 'city can be set' do
      assert_nil @address.city
      refute @json['City']
      @address.city = 'Test'
      assert_equal 'Test', @address.city
      assert_equal 'Test', @address.as_json['City']
    end

    test 'city max length 50chars' do
      assert_valid @address
      @address.city = Faker::String.random(length: 51)
      refute_valid @address
      @address.city = Faker::String.random(length: 50)
      assert_equal 50, @address.city.length, msg: @address.city
      assert_valid @address
    end

    test 'zip can be set' do
      assert_nil @address.zip
      refute @json['Zip']
      @address.zip = 1000
      assert_equal '1000', @address.zip
      assert_equal '1000', @address.as_json['Zip']
    end

    test 'zip max length 16chars' do
      assert_valid @address
      @address.zip = Faker::String.random(length: 17)
      refute_valid @address
      @address.zip = Faker::String.random(length: 16)
      assert_equal 16, @address.zip.length, msg: @address.zip
      assert_valid @address
    end

    test 'region has default nil' do
      assert_nil @address.region
      refute @json['Region']
    end

    test 'region can be set' do
      assert_nil @address.region
      refute @json['Region']
      @address.region = 'ER'
      assert_equal 'ER', @address.region
      assert_equal 'ER', @address.as_json['Region']
    end

    test 'region length 2chars' do
      assert_valid @address
      @address.region = Faker::String.random(length: 3)
      refute_valid @address
      @address.region = Faker::String.random(length: 2)
      assert_equal 2, @address.region.length, msg: @address.region
      assert_valid @address
    end

    test 'street can be set' do
      assert_nil @address.street
      refute @json['Street']
      @address.street = 'Test'
      assert_equal 'Test', @address.street
      assert_equal 'Test', @address.as_json['Street']
    end

    test 'street max length 50chars' do
      assert_valid @address
      @address.street = Faker::String.random(length: 51)
      refute_valid @address
      @address.street = Faker::String.random(length: 50)
      assert_equal 50, @address.street.length, msg: @address.street
      assert_valid @address
    end

    test 'street2 can be set' do
      assert_nil @address.street2
      refute @json['Street2']
      @address.street2 = 'Test'
      assert_equal 'Test', @address.street2
      assert_equal 'Test', @address.as_json['Street2']
    end

    test 'street2 max length 50chars' do
      assert_valid @address
      @address.street2 = Faker::String.random(length: 51)
      refute_valid @address
      @address.street2 = Faker::String.random(length: 50)
      assert_equal 50, @address.street2.length, msg: @address.street2
      assert_valid @address
    end

    test 'street3 can be set' do
      assert_nil @address.street3
      refute @json['Street3']
      @address.street3 = 'Test'
      assert_equal 'Test', @address.street3
      assert_equal 'Test', @address.as_json['Street3']
    end

    test 'street3 max length 50chars' do
      assert_valid @address
      @address.street3 = Faker::String.random(length: 51)
      refute_valid @address
      @address.street3 = Faker::String.random(length: 50)
      assert_equal 50, @address.street3.length, msg: @address.street3
      assert_valid @address
    end

    test 'full name can be set' do
      assert_nil @address.full_name
      refute @json['FullName']
      @address.full_name = 'Test'
      assert_equal 'Test', @address.full_name
      assert_equal 'Test', @address.as_json['FullName']
    end

    test 'full_name max length 45chars' do
      assert_valid @address
      @address.full_name = Faker::String.random(length: 46)
      refute_valid @address
      @address.full_name = Faker::String.random(length: 45)
      assert_equal 45, @address.full_name.length, msg: @address.full_name
      assert_valid @address
    end
  end
end
