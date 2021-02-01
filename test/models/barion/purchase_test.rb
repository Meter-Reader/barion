# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_purchases
#
#  id                         :integer          not null, primary key
#  availability_indicator     :integer
#  delivery_email_address     :string
#  delivery_timeframe         :integer
#  pre_order_date             :datetime
#  purchase_date              :datetime
#  purchase_type              :integer
#  re_order_indicator         :integer
#  recurring_expiry           :datetime
#  recurring_frequency        :integer
#  shipping_address_indicator :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  gift_card_purchase_id      :bigint
#  payment_id                 :bigint
#
# Indexes
#
#  index_barion_purchases_on_delivery_email_address  (delivery_email_address)
#  index_barion_purchases_on_delivery_timeframe      (delivery_timeframe)
#  index_barion_purchases_on_gift_card_purchase_id   (gift_card_purchase_id)
#  index_barion_purchases_on_payment_id              (payment_id)
#
require 'test_helper'

module Barion
  class PurchaseTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
  end
end
