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
#  payment_id                 :bigint
#
# Indexes
#
#  index_barion_purchases_on_delivery_email_address  (delivery_email_address)
#  index_barion_purchases_on_delivery_timeframe      (delivery_timeframe)
#  index_barion_purchases_on_payment_id              (payment_id)
#
module Barion
  # Represents a purchase in Barion engine
  class Purchase < ApplicationRecord
    include Barion::JsonSerializer

    enum availability_indicator: {
      merchandise_available: 0,
      future_availability: 10
    }, _default: :merchandise_available

    attr_accessor :delivery_email_address

    enum delivery_timeframe: {
      electronic_delivery: 0,
      same_day_shipping: 10,
      overnight_shipping: 20,
      two_day_or_more_shipping:	30
    }
    enum re_order_indicator: {
      first_time_ordered: 0,
      reordered: 10
    }
    enum shipping_address_indicator: {
      ship_to_cardholders_billing_address: 0,
      ship_to_another_verified_address: 10,
      ship_to_different_address: 20,
      ship_to_store: 30,
      digital_goods: 40,
      travel_and_event_tickets: 50,
      other: 60
    }
    enum purchase_type: {
      goods_and_service_purchase: 0,
      check_acceptance: 1,
      account_funding: 2,
      quasi_cash_transaction: 3,
      pre_paid_vacation_and_loan: 4
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

    def serialize_options
      { except: %i[id created_at updated_at],
        include: %i[gift_card_purchase],
        map: {
          keys: {
            _all: :camelize
          },
          values: {
            _all: proc { |v| v.respond_to?(:camelize) ? v.camelize : v },
            pre_order_date: :as_datetime,
            recurring_expiry: :as_datetime,
            purchase_date: :as_datetime,
            availability_indicator: :as_enum_id,
            delivery_timeframe: :as_enum_id,
            re_order_indicator: :as_ennum_id,
            shipping_address_indicator: :as_enum_id,
            purchase_type: :as_enum_id
          }
        } }
    end

    private

    def initial_recurring_payment?
      payment.recurring? and payment.initiate_recurrence
    end
  end
end
