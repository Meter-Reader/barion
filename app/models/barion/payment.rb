# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_payments
#
#  id                      :integer          not null, primary key
#  callback_url            :string(2000)
#  card_holder_name_hint   :string(45)
#  challenge_preference    :integer          default("no_preference")
#  checksum                :string           not null
#  completed_at            :datetime
#  created_at_barion       :datetime
#  currency                :string(3)        not null
#  delayed_capture_period  :integer
#  delayed_capture_until   :datetime
#  fraud_risk_score        :integer
#  funding_source          :integer
#  funding_sources         :integer          default("all")
#  gateway_url             :string(2000)
#  guest_check_out         :boolean
#  initiate_recurrence     :boolean
#  locale                  :string(10)       not null
#  order_number            :string(100)
#  payer_hint              :string(256)
#  payer_home_number       :string(30)
#  payer_phone_number      :string(30)
#  payer_work_phone_number :string(30)
#  payment_type            :integer          default("immediate"), not null
#  payment_window          :string(6)
#  pos_name                :string
#  pos_owner_country       :string
#  pos_owner_email         :string
#  poskey                  :string           not null
#  qr_url                  :string(2000)
#  recurrence_result       :integer
#  recurrence_type         :integer          default(NULL)
#  redirect_url            :string(2000)
#  reservation_period      :integer
#  reserved_until          :datetime
#  started_at              :datetime
#  status                  :integer          not null
#  suggested_local         :string
#  total                   :decimal(, )
#  valid_until             :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  payment_id              :string
#  payment_request_id      :string(100)
#  pos_id                  :string
#  recurrence_id           :string(100)
#  trace_id                :string(100)
#
# Indexes
#
#  index_barion_payments_on_order_number        (order_number)
#  index_barion_payments_on_payment_id          (payment_id)
#  index_barion_payments_on_payment_request_id  (payment_request_id)
#  index_barion_payments_on_payment_type        (payment_type)
#  index_barion_payments_on_poskey              (poskey)
#  index_barion_payments_on_recurrence_id       (recurrence_id)
#  index_barion_payments_on_status              (status)
#
module Barion
  # Represents a payment in Barion engine
  class Payment < ApplicationRecord
    include Barion::DataFormats
    include Barion::Currencies
    include Barion::JsonSerializer

    enum locale: { 'cs-CZ': 'cs-CZ',
                   'de-DE': 'de-DE',
                   'en-US': 'en-US',
                   'es-ES': 'es-ES',
                   'fr-FR': 'fr-FR',
                   'hu-HU': 'hu-HU',
                   'sk-SK': 'sk-SK',
                   'sl-SI': 'sl-SI' }, _default: 'hu-HU'
    enum challenge_preference: {
      no_preference: 0,
      challenge_required: 10,
      no_challenge_needed: 20
    }, _default: :no_preference
    enum recurrence_result: %i[none successful failed not_found], _prefix: true
    enum payment_type: %i[immediate reservation delayed_capture], _default: :immediate
    enum funding_sources: { all: 0, balance: 1 }, _suffix: true, _default: :all
    enum recurrence_type: { one_click: 1, merchant_initiated: 2, recurring: 3 }
    enum status: {
      initial: 0,
      prepared: 10,
      started: 20,
      in_progress: 21,
      waiting: 22,
      reserved: 25,
      authorized: 26,
      canceled: 30,
      succeeded: 40,
      failed: 50,
      partially_succeeded: 60,
      expired: 70
    }, _default: :initial
    attribute :payment_window, :integer, default: 30.minutes.to_i
    attribute :guest_check_out, :boolean, default: true
    attribute :initiate_recurrence, :boolean, default: false
    attribute :phone_number, :string
    attribute :home_number, :string
    attribute :checksum, :string
    enum funding_source: { balance: 1, bank_card: 2, bank_transfer: 3 }, _suffix: true

    has_many :payment_transactions,
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
    validates :payment_transactions, presence: true
    validates :checksum, presence: true
    validates_associated :payment_transactions
    validates_associated :payer_account

    after_initialize :set_defaults
    after_initialize :validate_checksum

    before_validation :create_payment_request_id
    before_validation :refresh_checksum

    def poskey=(value = nil)
      value = ::Barion.poskey if value.nil?
      super(value)
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
        raise ArgumentError, "#{value} is not a valid payment_type"
      end
      super(value)
    end

    def payer_work_phone_number=(number)
      super(::Barion::DataFormats.phone_number(number))
    end

    def payer_phone_number=(number)
      super(::Barion::DataFormats.phone_number(number))
    end

    def payer_home_number=(number)
      super(::Barion::DataFormats.phone_number(number))
    end

    def readonly?
      return false if @_bypass_readonly

      !initial?
    end

    def refresh_checksum
      self.checksum = gen_checksum
    end

    def execute
      if valid?
        ::Barion.endpoint['v2/Payment/Start'].post(
          as_json.to_json,
          { content_type: :json, accept: :json }
        ) { |response, request, _result| handle_response(response, request) }
      else
        false
      end
    end

    def refresh_state
      ::Barion.endpoint['v2/Payment/GetPaymentState'].get(
        {
          params: {
            POSKey: poskey,
            PaymentId: payment_id
          }
        }
      ) { |response, request, _| handle_response(response, request) }
    end

    def serialize_options
      { only: %i[callback_url card_holder_name_hint challenge_preference currency
                 delayed_capture_period funding_sources guest_check_out initiate_recurrence
                 locale order_number payer_hint payer_home_number payer_phone_number
                 payer_work_phone_number payment_type payment_window poskey recurrence_type
                 redirect_url reservation_period payment_request_id recurrence_id trace_id],
        include: %i[billing_address shipping_address payment_transactions payer_account purchase_information],
        map: {
          keys: {
            _all: :camelize,
            poskey: 'POSKey',
            payment_transactions: 'Transactions'
          },
          values: {
            _all: proc { |v| v.respond_to?(:camelize) ? v.camelize : v },
            _except: %w[poskey redirect_url callback_url locale payment_request_id payer_hint card_holder_name_hint],
            reservation_period: :as_time,
            delayed_capture_period: :as_time,
            payment_window: :as_time,
            funding_sources: :as_list,
            challenge_preference: :as_enum_id
          }
        } }
    end

    def deserialize_options
      {
        assoc: {
          payment_transactions: {
            pos_transaction_id: 'POSTransactionId'
          }
        },
        map: {
          keys: {
            _all: :underscore,
            Transactions: 'payment_transactions',
            CreatedAt: 'barion_created_at'
          },
          values: {
            _all: proc { |v| v.respond_to?(:underscore) ? v.underscore : v },
            _except: %w[Locale Currency]
          }
        },
        before_save: :refresh_checksum
      }
    end

    protected

    # rubocop:disable Lint/UselessMethodDefinition
    def checksum=(value)
      super(value)
    end
    # rubocop:enable Lint/UselessMethodDefinition

    def handle_response(response, request)
      case response.code
      when 200
        process_response(JSON.parse(response))
        refresh_checksum
        _bypass_readonly do
          save
        end
        true
      when 301, 302, 307
        raise Barion::Error.new(
          { Title: response.description,
            Description: 'No redirection is allowed in communication, please check endpoint!',
            HappenedAt: DateTime.now,
            ErrorCode: response.code,
            EndPoint: request.url }
        )
      when 400
        errors = ::JSON.parse(response)['Errors']
        raise Barion::Error.new(
          { Title: response.description,
            Description: 'Request failed, please check errors',
            HappenedAt: DateTime.now,
            Errors: errors,
            ErrorCode: response.code,
            EndPoint: request.url }
        )
      end
    end

    def set_defaults
      self.poskey = ::Barion.poskey if poskey.nil?
      self.callback_url = Rails.application.routes.url_helpers.gateway_callback_url
      self.redirect_url = Rails.application.routes.url_helpers.gateway_back_url
    end

    def create_payment_request_id
      self.payment_request_id = "#{::Barion.acronym}#{::Time.now.to_f.to_s.gsub('.', '')}" if payment_request_id.nil?
    end

    def gen_checksum
      ::Digest::SHA512.hexdigest(as_json.to_json)
    end

    def validate_checksum
      if checksum.present? && checksum != gen_checksum
        raise ::Barion::TamperedData, "checksum: #{refresh_checksum}, json: #{as_json}"
      end

      true
    end

    private

    def _bypass_readonly
      @_bypass_readonly = true
      yield
      @_bypass_readonly = false
    end
  end
end
