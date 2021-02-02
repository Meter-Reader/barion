# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_gift_card_purchases
#
#  id          :integer          not null, primary key
#  amount      :decimal(, )      not null
#  count       :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  purchase_id :integer
#
# Indexes
#
#  index_barion_gift_card_purchases_on_purchase_id  (purchase_id)
#
require 'test_helper'

module Barion
  class GiftCardPurchaseTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
  end
end
