# frozen_string_literal: true

require 'test_helper'
require 'rest_client'

module Barion
  class Test < ActiveSupport::TestCase
    test 'Barion is a module' do
      assert_kind_of Module, Barion
    end

    test 'Barion engine has version number' do
      refute_nil ::Barion::VERSION
    end

    test 'module cannot be instantiated' do
      assert_raises NoMethodError do
        ::Barion.new
      end
    end

    test 'module contains base URLs' do
      refute_nil ::Barion::BASE_URL[:test]
      refute_nil ::Barion::BASE_URL[:prod]
    end

    test 'module can be configured' do
      ::Barion.poskey = 'test'
      assert_equal 'test', ::Barion.poskey

      ::Barion.publickey = 'test'
      assert_equal 'test', ::Barion.publickey

      ::Barion.acronym = 'test'
      assert_equal 'test', ::Barion.acronym

      ::Barion.sandbox = true
      assert ::Barion.sandbox
      assert ::Barion.sandbox?
      ::Barion.sandbox = false
      refute ::Barion.sandbox
      refute ::Barion.sandbox?

      assert_equal 'zz', ::Barion.default_country
      ::Barion.default_country = 'HU'
      assert_equal 'HU', ::Barion.default_country
    end

    test 'user class can be configured and accept string only' do
      assert_nil ::Barion.user_class
      assert_raises ::ArgumentError do
        ::Barion.user_class = []
      end
      ::Barion.user_class = 'Object'
      assert_kind_of ::Object, ::Barion.user_class
    end

    test 'item class can be configured and accept string only' do
      assert_nil ::Barion.item_class
      assert_raises ::ArgumentError do
        ::Barion.item_class = []
      end
      ::Barion.item_class = 'Object'
      assert_kind_of ::Object, ::Barion.item_class
    end

    test 'endpoint returns a configured RestClient instance' do
      ::Barion.sandbox = true
      test_endpoint = ::Barion.endpoint
      assert_kind_of ::RestClient::Resource, test_endpoint
      ::Barion.sandbox = false
      prod_endpoint = ::Barion.endpoint
      assert_kind_of ::RestClient::Resource, prod_endpoint
      refute_equal prod_endpoint.url, test_endpoint.url
    end
  end
end
