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
#  suspicious_activity_indicator    :integer          default(0)
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
  class PayerAccount < ApplicationRecord
    include Barion::DataFormats

    attribute :account_is, :string
    enum account_change_indicator: {
      'ChangedDuringThisTransaction': 0,
      'LessThan30Days': 10,
      'Between30And60Days': 20,
      'MoreThan60Days': 30
    }, _default: 0, _prefix: true
    attribute :account_created, :datetime
    enum account_creation_indicator: {
      'NoAccount': 0,
      'CreatedDuringThisTransaction': 10,
      'LessThan30Days': 20,
      'Between30And60Days': 30,
      'MoreThan60Days': 40
    }, _default: 0, _prefix: true
    attribute :account_last_changed, :datetime
    enum password_change_indicator: {
      'NoChange': 0,
      'ChangedDuringThisTransaction': 10,
      'LessThan30Days': 20,
      'Between30And60Days': 30,
      'MoreThan60Days': 40
    }, _default: 0, _prefix: true
    attribute :password_last_changed, :datetime
    attribute :payment_method_added, :boolean
    attribute :provision_attempts, :integer
    attribute :purchases_in_the_last_6_months, :integer
    attribute :shipping_address_added, :datetime
    enum shipping_address_usage_indicator: {
      'ThisTransaction': 0,
      'LessThan30Days': 10,
      'Between30And60Days': 20,
      'MoreThan60Days': 30
    }, _default: 0
    enum suspicious_activity_indicator: {
      'NoSuspiciousActivityObserved': 0,
      'SuspiciousActivityObserved': 10
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
  end
end
