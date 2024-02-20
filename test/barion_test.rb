# frozen_string_literal: true

require 'test_helper'
require 'rest_client'

module Barion
  class Test < ActiveSupport::TestCase
    test 'Barion is a module' do
      assert_kind_of Module, Barion
    end

    test 'Barion is a Rails engine' do
      assert_includes Barion::Engine.ancestors, Rails::Engine
      assert_equal Barion::Engine.engine_name, 'barion'
    end

    test 'Barion engine has version number' do
      refute_nil ::Barion::VERSION
      assert_match(/(\d+\.){2}\d+\w*/, ::Barion::VERSION)
    end

    test 'module cannot be instantiated' do
      assert_raises ::NoMethodError do
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

      ::Barion.default_payee = 'test'
      assert_equal 'test', ::Barion.default_payee
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
      assert_equal ::Barion::BASE_URL[:test], test_endpoint.url
      ::Barion.sandbox = false
      prod_endpoint = ::Barion.endpoint
      assert_kind_of ::RestClient::Resource, prod_endpoint
      assert_equal ::Barion::BASE_URL[:prod], prod_endpoint.url
      refute_equal prod_endpoint.url, test_endpoint.url
    end

    test 'Error can be raised and has attributes' do
      exception = Barion::Error.new(
        { Title: 'ErrorTitle',
          Description: 'Request failed, please check errors',
          HappenedAt: DateTime.now,
          ErrorCode: 404,
          Endpoint: 'https://example.com' }
      )
      assert_equal 'ErrorTitle', exception.title
      assert_equal 'Request failed, please check errors', exception.message
      assert_equal 404, exception.error_code
      assert_equal 'https://example.com', exception.endpoint
      assert_empty exception.all_errors
    end

    test 'Error can be nested' do
      errors = [
        {
          Title: 'NestedError1Title',
          Description: 'Request failed 1',
          HappenedAt: DateTime.now,
          ErrorCode: 404,
          Endpoint: 'https://example.com'
        }, {
          Title: 'NestedError2Title',
          Description: 'Request failed 2',
          HappenedAt: DateTime.now,
          ErrorCode: 404,
          Endpoint: 'https://example.com'
        }
      ]
      exception = Barion::Error.new(
        { Title: 'ErrorTitle',
          Description: 'Request failed, please check errors',
          Errors: errors,
          HappenedAt: DateTime.now,
          ErrorCode: 404,
          Endpoint: 'https://example.com' }
      )
      assert_equal 'NestedError1Title', exception.errors.first.title
      assert_equal 'NestedError2Title', exception.errors.second.title
      assert_equal "Request failed 1\nRequest failed 2", exception.all_errors
    end
  end
end
