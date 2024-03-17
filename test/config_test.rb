# frozen_string_literal: true

require 'test_helper'
require 'rest_client'

module Barion
  class ConfigTest < ActiveSupport::TestCase
    setup do
      @config = ::Barion.config
    end
    test '::Barion::Config is a class' do
      assert_kind_of Class, ::Barion::Config
    end

    test '::Barion::Config is a Singleton' do
      a = ::Barion.config
      b = ::Barion::Config.instance
      assert_equal a, b
      assert_raises ::NoMethodError do
        ::Barion::Config.new
      end
      assert_raises ::TypeError do
        ::Barion::Config.instance.dup
      end
      assert_raises ::TypeError do
        ::Barion::Config.instance.clone
      end
    end

    test 'poskey can be configured and accept string only' do
      @config.poskey = 'test'
      assert_equal 'test', @config.poskey
      assert_raises(::ArgumentError) { @config.poskey = [] }
    end

    test 'publickey can be configured and accept string only' do
      @config.publickey = 'test'
      assert_equal 'test', @config.publickey
    end

    test 'pixel_id can be configured and accept valid formatted string only' do
      assert_raises(::ArgumentError) { @config.pixel_id = [] }

      @config.pixel_id = 'BP-abcdefgHij-00'
      assert_equal 'BP-abcdefgHij-00', @config.pixel_id

      assert_raises(::ArgumentError) { @config.pixel_id = 'pixel_id' }
      refute_equal 'pixel_id', @config.pixel_id
    end

    test 'acronym can be configured and accept string only' do
      @config.acronym = 'test'
      assert_equal 'test', @config.acronym
    end

    test 'sandbox can be configured and convert to boolean' do
      @config.sandbox = true
      assert @config.sandbox
      assert @config.sandbox?
      @config.sandbox = false
      refute @config.sandbox
      refute @config.sandbox?
    end

    test 'default_payee can be configured and accept string only' do
      @config.default_payee = 'test'
      assert_equal 'test', @config.default_payee
    end

    test 'user class can be configured and accept string only' do
      assert_nil @config.user_class
      assert_raises ::ArgumentError do
        @config.user_class = []
      end
      @config.user_class = 'Object'
      assert_kind_of ::Object, @config.user_class
    end

    test 'item class can be configured and accept string only' do
      assert_nil @config.item_class
      assert_raises ::ArgumentError do
        @config.item_class = []
      end
      @config.item_class = 'Object'
      assert_kind_of ::Object, @config.item_class
    end

    test 'endpoint returns a configured RestClient instance' do
      @config.sandbox = true
      test_endpoint = @config.endpoint
      assert_kind_of ::RestClient::Resource, test_endpoint
      assert_equal ::Barion::BASE_URL[:test], test_endpoint.url
      @config.sandbox = false
      prod_endpoint = @config.endpoint
      assert_kind_of ::RestClient::Resource, prod_endpoint
      assert_equal ::Barion::BASE_URL[:prod], prod_endpoint.url
      refute_equal prod_endpoint.url, test_endpoint.url
    end

    test 'intitalizer style config works' do
      ::Barion.config do |conf|
        conf.sandbox = false
        conf.item_class = 'Object'
        conf.user_class = 'Object'
        conf.acronym = 'test'
      end
      assert_kind_of ::RestClient::Resource, @config.endpoint
      assert_equal ::Barion::BASE_URL[:prod], @config.endpoint.url
      assert_kind_of ::Object, @config.item_class
      assert_kind_of ::Object, @config.user_class
      assert_equal 'test', @config.acronym
    end
  end
end
