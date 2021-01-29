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
#
# Indexes
#
#  index_barion_addresses_on_city       (city)
#  index_barion_addresses_on_country    (country)
#  index_barion_addresses_on_full_name  (full_name)
#  index_barion_addresses_on_zip        (zip)
#

require 'test_helper'

module Barion
  class AddressTest < ActiveSupport::TestCase
    setup do
      @address = Barion::Address.new
    end

    test 'country has default value' do
      assert_equal 'zz', @address.country
    end

    test 'country can be set' do
      assert_equal 'zz', @address.country
      @address.country = 'HU'
      assert_equal 'HU', @address.country
    end

    test 'country length 2chars' do
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
      @address.country = Faker::String.random(length: 3)
      refute @address.valid?
      @address.country = 'hu'
      assert_equal 2, @address.country.length, msg: @address.country
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
    end

    test 'city can be set' do
      assert_nil @address.city
      @address.city = 'Test'
      assert_equal 'Test', @address.city
    end

    test 'city max length 50chars' do
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
      @address.city = Faker::String.random(length: 51)
      refute @address.valid?
      @address.city = Faker::String.random(length: 50)
      assert_equal 50, @address.city.length, msg: @address.city
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
    end

    test 'zip can be set' do
      assert_nil @address.zip
      @address.zip = 1000
      assert_equal '1000', @address.zip
    end

    test 'zip max length 16chars' do
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
      @address.zip = Faker::String.random(length: 17)
      refute @address.valid?
      @address.zip = Faker::String.random(length: 16)
      assert_equal 16, @address.zip.length, msg: @address.zip
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
    end

    test 'region has default nil' do
      assert_nil @address.region
    end

    test 'region can be set' do
      assert_nil @address.region
      @address.region = 'ER'
      assert_equal 'ER', @address.region
    end

    test 'region length 2chars' do
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
      @address.region = Faker::String.random(length:3)
      refute @address.valid?
      @address.region = Faker::String.random(length: 2)
      assert_equal 2, @address.region.length, msg: @address.region
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
    end

    test 'street can be set' do
      assert_nil @address.street
      @address.street = 'Test'
      assert_equal 'Test', @address.street
    end

    test 'street max length 50chars' do
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
      @address.street = Faker::String.random(length: 51)
      refute @address.valid?
      @address.street = Faker::String.random(length: 50)
      assert_equal 50, @address.street.length, msg: @address.street
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
    end

    test 'street2 can be set' do
      assert_nil @address.street2
      @address.street2 = 'Test'
      assert_equal 'Test', @address.street2
    end

    test 'street2 max length 50chars' do
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
      @address.street2 = Faker::String.random(length: 51)
      refute @address.valid?
      @address.street2 = Faker::String.random(length: 50)
      assert_equal 50, @address.street2.length, msg: @address.street2
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
    end

    test 'street3 can be set' do
      assert_nil @address.street3
      @address.street3 = 'Test'
      assert_equal 'Test', @address.street3
    end

    test 'street3 max length 50chars' do
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
      @address.street3 = Faker::String.random(length: 51)
      refute @address.valid?
      @address.street3 = Faker::String.random(length: 50)
      assert_equal 50, @address.street3.length, msg: @address.street3
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
    end

    test 'full name can be set' do
      assert_nil @address.full_name
      @address.full_name = 'Test'
      assert_equal 'Test', @address.full_name
    end

    test 'full_name max length 45chars' do
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
      @address.full_name = Faker::String.random(length: 46)
      refute @address.valid?
      @address.full_name = Faker::String.random(length: 45)
      assert_equal 45, @address.full_name.length, msg: @address.full_name
      assert @address.valid?, @address.errors.objects.first.try(:full_message)
    end
  end
end
