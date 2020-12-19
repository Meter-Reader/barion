# frozen_string_literal: true

require 'test_helper'

# Barion configuration expected behaviour
class ConfigTest < Minitest::Test
  def setup
    @config = Barion::Config.new
  end

  def test_poskey_configurable
    @config.poskey = 'test'
    assert_equal 'test', @config.poskey
  end

  def test_publickey_configurable
    @config.poskey = 'test'
    assert_equal 'test', @config.poskey
  end

  def test_version_configurable
    @config.publickey = 'test'
    assert_equal 'test', @config.publickey
  end

  def test_version_cannot_be_nil
    @config.version = nil
    assert_equal '2', @config.version
  end

  def test_sandbox_configurable
    @config.sandbox = false
    refute @config.sandbox
    refute @config.sandbox?
  end

  def test_sandbox_is_bool_and_non_nillable
    @config.sandbox = 'test'
    assert @config.sandbox?
    @config.sandbox = nil
    refute @config.sandbox?
  end

  def test_shop_acronym_configurable
    assert_nil @config.shop_acronym
    @config.shop_acronym = 'test'
    assert @config.shop_acronym = 'test'
  end

  def test_config_has_default_values
    assert_equal '2', @config.version
    assert @config.sandbox?
    assert_nil @config.poskey
    assert_nil @config.publickey
    assert_equal 'zz', @config.default_country
  end

  def test_it_can_be_configured
    @config.version = '1'
    assert_equal '1', @config.version
  end

  def test_non_existent_config_raise_error
    assert_raises NoMethodError do
      @config.test = 1
    end
  end

  def test_country_configurable
    @config.default_country = 'HU'
    assert_equal 'HU', @config.default_country
  end
end
