# frozen_string_literal: true

require 'test_helper'

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
      assert_nil ::Barion.poskey
      ::Barion.poskey = ::Faker::String.random
      refute_nil ::Barion.poskey

      assert_nil Barion.publickey
      ::Barion.publickey = ::Faker::String.random
      refute_nil ::Barion.publickey

      assert_empty ::Barion.acronym
      ::Barion.acronym = ::Faker::String.random
      refute_nil ::Barion.acronym

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
  end
end
