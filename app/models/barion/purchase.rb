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
module Barion
  # Represents a purchase in Barion engine
  class Purchase < ApplicationRecord
    enum availability_indicator: {
      MerchandiseAvailable: 0,
      FutureAvailability: 10
    }, _default: :MerchandiseAvailable

    attr_accessor :delivery_email_address

    enum delivery_timeframe: {
      ElectronicDelivery: 0,
      SameDayShipping: 10,
      OvernightShipping: 20,
      TwoDayOrMoreShipping:	30
    }
    enum re_order_indicator: {
      FirstTimeOrdered: 0,
      Reordered: 10
    }
    enum shipping_address_indicator: {
      ShipToCardholdersBillingAddress: 0,
      ShipToAnotherVerifiedAddress: 10,
      ShipToDifferentAddress: 20,
      ShipToStore: 30,
      DigitalGoods: 40,
      TravelAndEventTickets: 50,
      Other: 60
    }
    enum purchase_type: {
      GoodsAndServicePurchase: 0,
      CheckAcceptance: 1,
      AccountFunding: 2,
      QuasiCashTransaction: 3,
      PrePaidVacationAndLoan: 4
    }

    belongs_to :payment, inverse_of: :purchase_information
    has_one :gift_card_purchase

    validates :recurring_frequency,
              numericality: { only_integer: true },
              inclusion: { in: 0..9_999 },
              allow_nil: true

    with_options if: :initial_recurring_payment? do |purchase|
      purchase.validates :recurring_frequency, presence: true
      purchase.validates :recurring_expiry, presence: true
    end

    private

    def initial_recurring_payment?
      payment.recurring? and payment.initiate_recurrence
    end
  end
end
