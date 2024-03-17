# frozen_string_literal: true

require 'test_helper'
require 'rest_client'

module Barion
  class Test < ActiveSupport::TestCase
    setup do
      Singleton.__init__(::Barion::Config)
      @config = ::Barion.config
      ::Barion.deprecator.behavior = :raise
    end

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

    test 'module has a Config function' do
      refute_nil ::Barion.config
      assert_kind_of ::Barion::Config, ::Barion.config
    end

    test 'module contains base URLs' do
      refute_nil ::Barion::BASE_URL[:test]
      refute_nil ::Barion::BASE_URL[:prod]
    end

    test 'sandbox raises deprecated' do
      assert_raises ActiveSupport::DeprecationException do
        assert ::Barion.sandbox
      end
      assert_raises ActiveSupport::DeprecationException do
        ::Barion.sandbox = true
      end
      assert @config.sandbox
      assert @config.sandbox?
      assert_raises ActiveSupport::DeprecationException do
        ::Barion.sandbox = false
      end
      refute @config.sandbox
      refute @config.sandbox?
    end

    test 'publickey raises deprecated' do
      assert_raises ActiveSupport::DeprecationException do
        assert ::Barion.publickey
      end
      assert_raises ActiveSupport::DeprecationException do
        ::Barion.publickey = 'test'
      end
      assert @config.publickey
    end

    test 'acronym raises deprecated' do
      assert_raises ActiveSupport::DeprecationException do
        assert ::Barion.acronym
      end
      assert_raises ActiveSupport::DeprecationException do
        ::Barion.acronym = 'test'
      end
      assert @config.acronym
    end

    test 'default_payee raises deprecated' do
      assert_raises ActiveSupport::DeprecationException do
        assert ::Barion.default_payee
      end
      assert_raises ActiveSupport::DeprecationException do
        ::Barion.default_payee = 'test'
      end
      assert @config.default_payee
    end

    test 'item_class raises deprecated' do
      assert_raises ActiveSupport::DeprecationException do
        assert ::Barion.item_class
      end
      assert_raises ActiveSupport::DeprecationException do
        ::Barion.item_class = 'Object'
      end
      assert @config.item_class
    end

    test 'user_class raises deprecated' do
      assert_raises ActiveSupport::DeprecationException do
        assert ::Barion.user_class
      end
      assert_raises ActiveSupport::DeprecationException do
        ::Barion.user_class = 'Object'
      end
      assert @config.user_class
    end

    test 'pixel_id raises deprecated' do
      assert_raises ActiveSupport::DeprecationException do
        assert ::Barion.pixel_id
      end
      assert_raises ActiveSupport::DeprecationException do
        ::Barion.pixel_id = 'BP-abcdefgHij-00'
      end
      assert @config.pixel_id
    end

    test 'poskey raises deprecated' do
      assert_raises ActiveSupport::DeprecationException do
        assert ::Barion.poskey
      end
      assert_raises ActiveSupport::DeprecationException do
        ::Barion.poskey = 'test'
      end
      assert @config.poskey
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
