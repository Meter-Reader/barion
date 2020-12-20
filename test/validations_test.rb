# frozen_string_literal: true

require 'test_helper'
require 'barion/validations'

# Barion validations expected behaviour
class ValidationsTest < Minitest::Test
  include Barion::Validations
  def test_truncate_works
    assert_equal 10, truncate(rnd_str(5, 3), 10).length
  end

  def test_truncate_as_string
    assert_instance_of String, truncate(100_000, 3)
  end

  def test_truncate_dont_work_under_2chars
    assert_equal 3, truncate('abc', 1).length
    assert_equal 2, truncate('abc', 2).length
  end

  def test_size_validation_works
    err = assert_raises ArgumentError do
      validate_size('Argument', 4, min: 5)
    end
    assert_equal '4 is too small for Argument', err.message
    err = assert_raises ArgumentError do
      validate_size('Argument', 4, max: 3)
    end
    assert_equal '4 is too big for Argument', err.message
    assert_equal 4, validate_size('Argument', 4, min: 4, max: 4)
    assert_equal 4, validate_size('Argument', 4)
  end

  def test_size_validation_works_only_for_numbers
    err = assert_raises ArgumentError do
      validate_size('Argument', 'test', min: 4, max: 4)
    end
    assert_equal 'test is not numeric', err.message
  end

  def test_length_validation_works
    err = assert_raises ArgumentError do
      validate_length('Argument', 'test', min: 5)
    end
    assert_equal 'test is too short for Argument', err.message
    err = assert_raises ArgumentError do
      validate_length('Argument', 'test', max: 3)
    end
    assert_equal 'test is too long for Argument', err.message
    assert_equal 'test', validate_length('Argument', 'test', min: 4, max: 4)
    assert_equal 'test', validate_length('Argument', 'test')
  end

  def test_length_validation_works_only_for_string
    err = assert_raises ArgumentError do
      validate_length('Argument', 4, min: 4, max: 4)
    end
    assert_equal '4 is not string', err.message
  end

  def test_phone_number_format_works
    assert_equal '36201234567', format_phone_number('+36201234567')
    assert_equal '36201234567', format_phone_number('0036201234567')
    assert_equal '06201234567', format_phone_number('06201234567')
    err = assert_raises ArgumentError do
      format_phone_number('0123456789012345678901234567891')
    end
    assert_equal '0123456789012345678901234567891 is too long for phone number', err.message
  end
end
