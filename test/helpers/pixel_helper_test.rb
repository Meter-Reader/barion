# frozen_string_literal: true

require 'test_helper'

module Barion
  class PixelHelperTest < ActionView::TestCase
    include Barion::PixelHelper
    test 'JS contains pixel ID' do
      assert_match(/#{::Barion.pixel_id}/, pixel_basic_js)
    end
  end
end
