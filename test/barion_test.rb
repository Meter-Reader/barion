# frozen_string_literal: true

require 'test_helper'

# Barion module expectations
class BarionTest < Minitest::Test
  def setup
    Barion.configuration
  end
  def test_that_it_has_a_version_number
    refute_nil ::Barion::VERSION
  end

  def test_module_cannot_be_instantiated
    assert_raises NoMethodError do
      Barion.new
    end
  end

  def test_has_configuration
    assert_instance_of Barion::Config, Barion.configuration
    assert_equal '2', Barion.configuration.version
  end

  def test_cofigurable_with_proc
    Barion.configure do |conf|
      conf.version = '1'
    end
    assert_equal '1', Barion.configuration.version
  end

  def teardown
    Barion.reset
  end
end
