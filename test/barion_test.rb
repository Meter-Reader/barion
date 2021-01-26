# frozen_string_literal: true

require 'test_helper'

module Barion
  class Test < ActiveSupport::TestCase
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

    test 'module can be configured' do
      Barion.poskey = 1
      assert_equal 1, Barion.poskey
    end
  end
end
