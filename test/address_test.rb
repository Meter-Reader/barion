# frozen_string_literal: true

require 'test_helper'
require 'barion/address'

# Barion address expected behaviour
class AddressTest < Minitest::Test
  def setup
    Barion.configure
    @address = Barion::Address.new
  end

  def test_country_has_default_value
    assert_equal 'zz', @address.country
  end

  def test_country_can_be_set
    assert_equal 'zz', @address.country
    @address.country = 'HU'
    assert_equal 'HU', @address.country
  end

  def test_country_length_2chars
    assert_raises ArgumentError do
      @address.country = "#{rnd_str(2, 1)}a"
    end
    @address.country = rnd_str(2, 1)
    assert_equal 2, @address.country.length, msg: @address.country
  end

  def test_city_can_be_set
    assert_nil @address.city
    @address.city = 'Test'
    assert_equal 'Test', @address.city
  end

  def test_city_max_length_50chars
    assert_raises ArgumentError do
      @address.city = "#{rnd_str(10, 5)}a"
    end
    @address.city = rnd_str(10, 5)
    assert_equal 50, @address.city.length, msg: @address.city
  end

  def test_zip_can_be_set
    assert_nil @address.zip
    @address.zip = 1000
    assert_equal '1000', @address.zip
  end

  def test_zip_max_length_16chars
    assert_raises ArgumentError do
      @address.zip = "#{rnd_str(2, 8)}a"
    end
    @address.zip = rnd_str(2, 8)
    assert_equal 16, @address.zip.length, msg: @address.zip
  end

  def test_region_has_default_nil
    assert_nil @address.region
  end

  def test_region_can_be_set
    assert_nil @address.region
    @address.region = 'ER'
    assert_equal 'ER', @address.region
  end

  def test_region_length_2chars
    assert_raises ArgumentError do
      @address.region = "#{rnd_str(2, 1)}a"
    end
    @address.region = rnd_str(2, 1)
    assert_equal 2, @address.region.length, msg: @address.region
  end

  def test_street_can_be_set
    assert_nil @address.street
    @address.street = 'Test'
    assert_equal 'Test', @address.street
  end

  def test_street_max_length_50chars
    assert_raises ArgumentError do
      @address.street = "#{rnd_str(10, 5)}a"
    end
    @address.street = rnd_str(10, 5)
    assert_equal 50, @address.street.length, msg: @address.street
  end

  def test_street2_can_be_set
    assert_nil @address.street2
    @address.street2 = 'Test'
    assert_equal 'Test', @address.street2
  end

  def test_street2_max_length_50chars
    assert_raises ArgumentError do
      @address.street2 = "#{rnd_str(10, 5)}a"
    end
    @address.street2 = rnd_str(10, 5)
    assert_equal 50, @address.street2.length, msg: @address.street2
  end

  def test_street3_can_be_set
    assert_nil @address.street3
    @address.street3 = 'Test'
    assert_equal 'Test', @address.street3
  end

  def test_street3_max_length_50chars
    assert_raises ArgumentError do
      @address.street3 = "#{rnd_str(10, 5)}a"
    end
    @address.street3 = rnd_str(10, 5)
    assert_equal 50, @address.street3.length, msg: @address.street3
  end

  def test_full_name_can_be_set
    assert_nil @address.full_name
    @address.full_name = 'Test'
    assert_equal 'Test', @address.full_name
  end

  def test_full_name_max_length_45chars
    assert_raises ArgumentError do
      @address.full_name = "#{rnd_str(9, 5)}a"
    end
    @address.full_name = rnd_str(9, 5)
    assert_equal 45, @address.full_name.length, msg: @address.full_name
  end
end
