# frozen_string_literal: true

require 'test_helper'

# Barion module expectations
class BarionTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Barion::VERSION
  end

  def test_module_cannot_be_instantiated
    assert_raises NoMethodError do
      Barion.new
    end
  end

  def test_has_configuration
    assert_equal '2', Barion.config.version
  end

  def test_canofigurable_with_proc
    Barion.config do |conf|
      conf.version = '1'
    end
  end
end
