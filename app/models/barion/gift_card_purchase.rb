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
    include Barion::JsonSerializer

    belongs_to :purchase, inverse_of: :gift_card_purchase

    attribute :amount, :decimal
    attribute :count, :integer

    validates_associated :purchase
    validates :amount, numericality: { greater_than: 0 }
    validates :count, numericality: { only_integer: true }, inclusion: { in: 1..99 }

    def json_options
      { except: %i[id created_at updated_at currency],
        map: {
          keys: {
            _all: :camelize
          },
          values: {
            _all: proc { |v| v.respond_to?(:camelize) ? v.camelize : v }
          }
        } }
    end

    def amount
      value = super
      return nil if value.nil?

      case currency
      when nil
        value
      when 'HUF'
        value.round(0)
      else
        value.round(2)
      end
    end

    def currency
      return nil if purchase.nil? || purchase.payment.nil?

      purchase.payment.currency
    end
  end
end
