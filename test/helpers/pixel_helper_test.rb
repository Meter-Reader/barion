# frozen_string_literal: true

require 'test_helper'

module Barion
  class PixelHelperTest < ActionView::TestCase
    include Barion::PixelHelper

    setup do
      ::Barion.pixel_id = 'BP-1234567890-12'
    end

    test 'JS contains pixel ID' do
      assert_match(/#{::Barion.pixel_id}/, pixel_basic_js)
    end

    test 'Noscript contains pixel ID' do
      assert_match(/#{::Barion.pixel_id}/, pixel_basic_noscript)
    end

    test 'all tags contains pixel ID' do
      assert_match(/#{::Barion.pixel_id}/, pixel_basic_tags)
    end
  end
end
