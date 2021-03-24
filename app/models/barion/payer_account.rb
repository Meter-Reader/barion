# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_payer_accounts
#
#  id                               :integer          not null, primary key
#  account_change_indicator         :integer
#  account_created                  :datetime
#  account_creation_indicator       :integer
#  account_last_changed             :datetime
#  password_change_indicator        :integer
#  password_last_changed            :datetime
#  payment_method_added             :datetime
#  provision_attempts               :integer
#  purchases_in_the_last_6_months   :integer
#  shipping_address_added           :datetime
#  shipping_address_usage_indicator :integer
#  suspicious_activity_indicator    :integer          default("no_suspicious_activity_observed")
#  transactional_activity_per_day   :integer
#  transactional_activity_per_year  :integer
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  account_id                       :string(64)
#  payment_id                       :bigint
#
# Indexes
#
#  index_barion_payer_accounts_on_account_id  (account_id)
#  index_barion_payer_accounts_on_payment_id  (payment_id)
#
module Barion
  # Represents a PayerAccount in Barion engine
  class PayerAccount < ApplicationRecord
    include ::Barion::DataFormats
    include ::Barion::JsonSerializer

    attribute :account_is, :string
    enum account_change_indicator: {
      changed_during_this_transaction: 0,
      less_than_30_days: 10,
      between_30_and_60_days: 20,
      more_than_60_days: 30
    }, _default: 0, _prefix: true
    attribute :account_created, :datetime
    enum account_creation_indicator: {
      no_account: 0,
      created_during_this_transaction: 10,
      less_than_30_days: 20,
      between_30_and_60_days: 30,
      more_than_60_days: 40
    }, _default: 0, _prefix: true
    attribute :account_last_changed, :datetime
    enum password_change_indicator: {
      no_change: 0,
      changed_during_this_transaction: 10,
      less_than_30_days: 20,
      between_30_and_60_days: 30,
      more_than_60_days: 40
    }, _default: 0, _prefix: true
    attribute :password_last_changed, :datetime
    attribute :payment_method_added, :boolean
    attribute :provision_attempts, :integer
    attribute :purchases_in_the_last_6_months, :integer
    attribute :shipping_address_added, :datetime
    enum shipping_address_usage_indicator: {
      this_transaction: 0,
      less_than_30_days: 10,
      between_30_and_60_days: 20,
      more_than_60_days: 30
    }, _default: 0
    enum suspicious_activity_indicator: {
      no_suspicious_activity_observed: 0,
      suspicious_activity_observed: 10
    }, _default: 0
    attribute :transactional_activity_per_day, :integer
    attribute :transactional_activity_per_year, :integer

    belongs_to :payment, inverse_of: :payer_account, dependent: :delete

    validates :account_id, length: { maximum: 64 }, allow_nil: true
    validates :provision_attempts,
              numericality: true,
              inclusion: { in: 0..999 },
              allow_nil: true
    validates :transactional_activity_per_day,
              numericality: { only_integer: true },
              inclusion: { in: 0..999 },
              allow_nil: true
    validates :purchases_in_the_last_6_months,
              numericality: { only_integer: true },
              inclusion: { in: 0..9999 },
              allow_nil: true
    validates :transactional_activity_per_year,
              numericality: { only_integer: true },
              inclusion: { in: 0..999 },
              allow_nil: true

    def serialize_options
      { except: %i[id created_at updated_at],
        map: {
          keys: {
            _all: :camelize
          },
          values: {
            _all: proc { |v| v.respond_to?(:camelize) ? v.camelize : v },
            account_created: :as_datetime,
            account_last_changed: :as_datetime,
            password_last_changed: :as_datetime,
            account_change_indicator: :as_enum_id,
            account_creation_indicator: :as_enum_id,
            password_change_indicator: :as_enum_id,
            shipping_address_usage_indicator: :as_enum_id,
            suspicious_activity_indicator: :as_enum_id
          }
        } }
    end
  end
end
