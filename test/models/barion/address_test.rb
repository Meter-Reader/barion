# forzen_string_literal: true

require 'test_helper'

module Barion
  class AddressTest < ActiveSupport::TestCase
    setup do
      Barion.configure
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
      assert_raises ArgumentError do
        @address.country = "#{rnd_str(2, 1)}a"
      end
      @address.country = rnd_str(2, 1)
      assert_equal 2, @address.country.length, msg: @address.country
    end

    test 'city can be set' do
      assert_nil @address.city
      @address.city = 'Test'
      assert_equal 'Test', @address.city
    end

    test 'city max length 50chars' do
      assert_raises ArgumentError do
        @address.city = "#{rnd_str(10, 5)}a"
      end
      @address.city = rnd_str(10, 5)
      assert_equal 50, @address.city.length, msg: @address.city
    end

    test 'zip can be set' do
      assert_nil @address.zip
      @address.zip = 1000
      assert_equal '1000', @address.zip
    end

    test 'zip max length 16chars' do
      assert_raises ArgumentError do
        @address.zip = "#{rnd_str(2, 8)}a"
      end
      @address.zip = rnd_str(2, 8)
      assert_equal 16, @address.zip.length, msg: @address.zip
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
      assert_raises ArgumentError do
        @address.region = "#{rnd_str(2, 1)}a"
      end
      @address.region = rnd_str(2, 1)
      assert_equal 2, @address.region.length, msg: @address.region
    end

    test 'street can be set' do
      assert_nil @address.street
      @address.street = 'Test'
      assert_equal 'Test', @address.street
    end

    test 'street max length 50chars' do
      assert_raises ArgumentError do
        @address.street = "#{rnd_str(10, 5)}a"
      end
      @address.street = rnd_str(10, 5)
      assert_equal 50, @address.street.length, msg: @address.street
    end

    test 'street2 can be set' do
      assert_nil @address.street2
      @address.street2 = 'Test'
      assert_equal 'Test', @address.street2
    end

    test 'street2 max length 50chars' do
      assert_raises ArgumentError do
        @address.street2 = "#{rnd_str(10, 5)}a"
      end
      @address.street2 = rnd_str(10, 5)
      assert_equal 50, @address.street2.length, msg: @address.street2
    end

    test 'street3 can be set' do
      assert_nil @address.street3
      @address.street3 = 'Test'
      assert_equal 'Test', @address.street3
    end

    test 'street3 max length 50chars' do
      assert_raises ArgumentError do
        @address.street3 = "#{rnd_str(10, 5)}a"
      end
      @address.street3 = rnd_str(10, 5)
      assert_equal 50, @address.street3.length, msg: @address.street3
    end

    test 'full name can be set' do
      assert_nil @address.full_name
      @address.full_name = 'Test'
      assert_equal 'Test', @address.full_name
    end

    test 'full name max length 45chars' do
      assert_raises ArgumentError do
        @address.full_name = "#{rnd_str(9, 5)}a"
      end
      @address.full_name = rnd_str(9, 5)
      assert_equal 45, @address.full_name.length, msg: @address.full_name
    end
  end
end
