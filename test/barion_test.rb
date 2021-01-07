# frozen_string_literal: true

require 'test_helper'

module Barion
  class Test < ActiveSupport::TestCase
    setup do
      Barion.configure
    end

    test 'Barion is a module' do
      assert_kind_of Module, Barion
    end

    test 'that it has a version number' do
      refute_nil ::Barion::VERSION
    end

    test 'module cannot be instantiated' do
      assert_raises NoMethodError do
        Barion.new
      end
    end

    test 'has configuration' do
      assert_instance_of Barion::Config, Barion.configuration
      assert_equal '2', Barion.configuration.version
    end

    test 'cofigurable with proc' do
      Barion.configure do |conf|
        conf.version = '1'
      end
      assert_equal '1', Barion.configuration.version
    end

    teardown do
      Barion.reset
    end
  end
end
