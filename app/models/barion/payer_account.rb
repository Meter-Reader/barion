# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_payer_accounts
#
#  id                               :integer          not null, primary key
#  change_indicator                 :integer
#  creation_indicator               :integer
#  email                            :string(256)
#  home_number                      :string(30)
#  locale                           :string(5)
#  name                             :string(45)
#  password_change_indicator        :integer
#  password_last_changed            :datetime
#  payment_method_added             :datetime
#  phone_number                     :string(30)
#  shipping_address_usage_indicator :integer
#  suspicious                       :integer          default(FALSE)
#  work_phone_number                :string(30)
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  billing_address_id               :bigint
#  shipping_address_id              :bigint
#
# Indexes
#
#  index_barion_payer_accounts_on_billing_address_id   (billing_address_id)
#  index_barion_payer_accounts_on_email                (email)
#  index_barion_payer_accounts_on_name                 (name)
#  index_barion_payer_accounts_on_shipping_address_id  (shipping_address_id)
#
# Foreign Keys
#
#  billing_address_id   (billing_address_id => barion_addresses.id)
#  shipping_address_id  (shipping_address_id => barion_addresses.id)
#
module Barion
  class PayerAccount < ApplicationRecord
    include Barion::DataFormats

    attribute :email, :string
    attribute :name, :string
    attribute :locale, :string
    attribute :phone_number, :string
    attribute :home_number, :string
    attribute :creation_indicator, :boolean
    attribute :change_indicator, :boolean
    attribute :password_last_changed, :datetime
    attribute :password_change_indicator, :boolean
    attribute :suspicious, :boolean, default: false
    attribute :payment_method_added, :boolean
    attribute :shipping_address_usage_indicator, :boolean

    belongs_to :billing_address, class_name: 'Barion::Address'
    belongs_to :shipping_address, class_name: 'Barion::Address'

    has_many :payments, inverse_of: :payer_account, dependent: :nullify

    validates :email, length: { maximum: 256 }, allow_nil: true

    def home_number=(number)
      @home_number = DataFormats.phone_number(number)
    end

    def phone_number=(number)
      @phone_number = DataFormats.phone_number(number)
    end
  end
end
