# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_payments
#
#  id                      :integer          not null, primary key
#  callback_url            :string(2000)
#  card_holder_name_hint   :string(45)
#  challenge_preference    :string
#  checksum                :string
#  currency                :string(3)        not null
#  delayed_capture_period  :integer
#  funding_sources         :integer          default("all")
#  gateway_url             :string(2000)
#  guest_checkout          :boolean
#  initiate_recurrence     :boolean
#  locale                  :string(10)       not null
#  order_number            :string(100)
#  payer_hint              :string(256)
#  payer_home_number       :string(30)
#  payer_phone_number      :string(30)
#  payer_work_phone_number :string(30)
#  payment_type            :integer          default("immediate"), not null
#  payment_window          :string(6)
#  poskey                  :string           not null
#  qr_url                  :string(2000)
#  recurrence_result       :integer
#  recurrence_type         :integer          default(NULL)
#  redirect_url            :string(2000)
#  reservation_period      :integer
#  status                  :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  billing_address_id      :bigint
#  payer_account_id        :bigint
#  payment_id              :string
#  payment_request_id      :string(100)
#  purchase_information_id :bigint
#  recurrence_id           :string(100)
#  shipping_address_id     :bigint
#  trace_id                :string(100)
#
# Indexes
#
#  index_barion_payments_on_billing_address_id       (billing_address_id)
#  index_barion_payments_on_order_number             (order_number)
#  index_barion_payments_on_payer_account_id         (payer_account_id)
#  index_barion_payments_on_payment_id               (payment_id)
#  index_barion_payments_on_payment_request_id       (payment_request_id)
#  index_barion_payments_on_payment_type             (payment_type)
#  index_barion_payments_on_poskey                   (poskey)
#  index_barion_payments_on_purchase_information_id  (purchase_information_id)
#  index_barion_payments_on_recurrence_id            (recurrence_id)
#  index_barion_payments_on_shipping_address_id      (shipping_address_id)
#  index_barion_payments_on_status                   (status)
#
# Foreign Keys
#
#  billing_address_id       (billing_address_id => barion_addresses.id)
#  payer_account_id         (payer_account_id => barion_payer_accounts.id)
#  purchase_information_id  (purchase_information_id => barion_purchases.id)
#  shipping_address_id      (shipping_address_id => barion_addresses.id)
#
module Barion
  # Represents a payment in Barion engine
  class Payment < ApplicationRecord
    include Barion::DataFormats

    enum currency: { EUR: 'EUR', USD: 'USD', HUF: 'HUF', CZK: 'CZK' }, _default: :HUF
    enum locale: { 'cs-CZ': 'cs-CZ',
                   'de-DE': 'de-DE',
                   'en-US': 'en-US',
                   'es-ES': 'es-ES',
                   'fr-FR': 'fr-FR',
                   'hu-HU': 'hu-HU',
                   'sk-SK': 'sk-SK',
                   'sl-SI': 'sl-SI' }, _default: 'hu-HU'
    CHALLENGES = %i[no_preference challenge_required no_challenge_needed].freeze
    enum payment_type: %i[immediate reservation delayed_capture], _default: :immediate
    enum funding_sources: { all: 0, balance: 1 }, _suffix: true, _default: :all
    enum recurrence_type: { one_click: 1, merchant_initiated: 2, recurring: 3 }
    enum status: {
      Initial: 0,
      Prepared: 10,
      Started: 20,
      InProgress: 21,
      Waiting: 22,
      Reserved: 25,
      Authorized: 26,
      Canceled: 30,
      Succeeded: 40,
      Failed: 50,
      PartiallySucceeded: 60,
      Expired: 70
    }, _default: :Initial
    attribute :payment_window, :integer, default: 30.minutes.to_i
    attribute :guest_checkout, :boolean, default: true
    attribute :initiate_recurrence, :boolean, default: false
    attribute :phone_number, :string
    attribute :home_number, :string

    before_validation :create_payment_request_id

    has_many :transactions,
             inverse_of: :payment,
             dependent: :destroy

    has_one :shipping_address,
            class_name: 'Barion::Address',
            inverse_of: :payment

    has_one :billing_address,
            class_name: 'Barion::Address',
            inverse_of: :payment

    has_one :payer_account, inverse_of: :payment

    has_one :purchase_information,
            class_name: 'Barion::Purchase',
            inverse_of: :payment

    validates :payment_type, presence: true
    validates :reservation_period,
              presence: true,
              numericality: { only_integer: true },
              inclusion: { in: 1.minute.to_i..1.year.to_i },
              if: :reservation?
    validates :delayed_capture_period,
              presence: true,
              numericality: { only_integer: true },
              inclusion: { in: 1.minute.to_i..1.week.to_i },
              if: :delayed_capture?
    validates :delayed_capture_period,
              absence: true,
              unless: :delayed_capture?
    validates :payment_window,
              numericality: { only_integer: true },
              inclusion: { in: 1.minute.to_i..1.week.to_i }
    validates_uniqueness_of :payment_request_id
    validates :recurrence_id, length: { maximum: 100 }
    validates :payer_hint, length: { maximum: 256 }
    validates :card_holder_name_hint,
              length: { minimum: 2, maximum: 45 },
              allow_nil: true
    validates :trace_id, length: { maximum: 100 }
    validates :redirect_url, length: { maximum: 2000 }
    validates :callback_url, length: { maximum: 2000 }
    validates :gateway_url, length: { maximum: 2000 }
    validates :qr_url, length: { maximum: 2000 }
    validates :order_number, length: { maximum: 100 }
    validates :payer_hint, length: { maximum: 256 }
    validates :transactions, presence: true
    validates_associated :transactions
    validates_associated :payer_account

    after_initialize :set_defaults

    attr_reader :poskey, :payer_phone_number, :payer_home_number, :payer_work_phone_number

    def poskey=(poskey = nil)
      @poskey = poskey || Barion.poskey
    end

    def payment_type=(value)
      case value.to_sym
      when :immediate
        self.reservation_period = nil
      when :reservation
        self.reservation_period = 30.minutes.to_i
      when :delayed_capture
        self.reservation_period = 1.minutes.to_i
        self.delayed_capture_period = 1.week.to_i
      else
        raise ArgumentError
      end
      super(value)
    end

    def payer_work_phone_number=(number)
      @payer_work_phone_number = Barion::DataFormats.phone_number(number)
    end

    def payer_phone_number=(number)
      @payer_phone_number = Barion::DataFormats.phone_number(number)
    end

    def payer_home_number=(number)
      @payer_home_number = Barion::DataFormats.phone_number(number)
    end

    def readonly?
      !initial?
    end

    private

    def set_defaults
      @poskey = Barion.poskey
    end

    def create_payment_request_id
      self.payment_request_id = "#{Barion.acronym}#{Time.now.to_f.to_s.gsub('.', '')}" if payment_request_id.nil?
    end
  end
end
