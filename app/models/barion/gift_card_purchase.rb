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

module Barion
  # Represents a Gift card purchase in Barion engine
  class GiftCardPurchase < ApplicationRecord
    belongs_to :purchase, inverse_of: :gift_card_purchase

    validates_associated :purchase
    validates :amount, numericality: { greater_than: 0 }
    validates :count, numericality: { only_integer: true }, inclusion: { in: 1..99 }

    attr_writer :amount

    def amount
      return nil if @amount.nil?

      case currency
      when nil
        nil
      when 'HUF'
        @amount.round(0)
      else
        @amount.round(2)
      end
    end

    def currency
      return nil if purchase.nil? || purchase.payment.nil?

      purchase.payment.currency
    end
  end
end
