# frozen_string_literal: true

require 'barion/config'
require 'barion/validations'

module Barion
  # Represents a payment in Barion
  class Payment
    include Barion::Validations

    @@payment_counter = 0
    CURRENCIES = %i[EUR USD HUF CZK].freeze
    PAYMENT_TYPES = %i[immediate reservation delayed_capture].freeze
    FUNDINGSRCS = %i[all balance].freeze
    LOCALES = %w[cs-CZ de-DE en-US es-ES fr-FR hu-HU sk-SK sl-SI].freeze
    RECURRENCE_TYPES = %i[one_click merchant_initiated recurring].freeze

    attr_reader :payment_type,
                :reservation_period,
                :delayed_capture_period,
                :payment_window,
                :guest_checkout,
                :initiate_recurrence,
                :recurrence_id,
                :funding_sources,
                :recurrence_type,
                :payer_hint,
                :card_holder_name_hint,
                :trace_id,
                :redirect_url,
                :callback_url,
                :order_number,
                :locale,
                :currency,
                :payer_phone_number,
                :payer_work_phone_number,
                :payer_home_number,
                :shipping_address,
                :billing_address

    attr_accessor :payment_request_id,
                  :transactions,
                  :payer_account,
                  :purchase_information,
                  :challenge_preference

    def initialize
      @@payment_counter += 1
      @config = Barion.configuration
      @payment_type = :immediate
      @payment_window = 1_800 # 7days
      @guest_checkout = true
      @initiate_recurrence = false
      @funding_sources = :all
      @locale = 'hu-HU'
      @currency = :HUF
      generate_payment_request_id
    end

    def poskey
      @config.poskey
    end

    def payment_type=(type)
      raise ArgumentError, "#{type} is not a valid payment_type" unless PAYMENT_TYPES.include?(type)

      @payment_type = type
      @reservation_period, @delayed_capture_period = case type
                                                     when :reservation
                                                       [1_800, nil]
                                                     when :delayed_capture
                                                       [nil, 604_800]
                                                     else
                                                       [nil, nil]
                                                     end
    end

    def reservation_period=(seconds)
      unless @payment_type == :reservation
        raise ArgumentError, "reservation period should only be set if payment type is 'Reservation'"
      end

      @reservation_period = validate_size('reservation_period', seconds, min: 60, max: 31_536_000)
    end

    def delayed_capture_period=(seconds)
      unless @payment_type == :delayed_capture
        raise ArgumentError, "delayed capture period should only be set if payment type is 'DelayedCapture'"
      end

      @delayed_capture_period = validate_size('delayed capture period', seconds, min: 60, max: 604_800)
    end

    def payment_window=(seconds)
      @payment_window = validate_size('payment window', seconds, min: 1_800, max: 604_800)
    end

    def guest_checkout=(value)
      @guest_checkout = !!value
    end

    def initiate_recurrence=(value)
      @initiate_recurrence = !!value
    end

    def recurrence_id=(value)
      @recurrence_id = validate_length('recurrence id', value, max: 100)
    end

    def recurrence_type=(value)
      raise ArgumentError, "#{value} is not a valid recurrence type" unless RECURRENCE_TYPES.include?(value)

      @recurrence_type = value
    end

    def funding_sources=(src)
      raise ArgumentError, "#{src} is not a valid funding source" unless FUNDINGSRCS.include?(src)

      @funding_sources = src
    end

    def payer_hint=(value)
      @payer_hint = validate_length('payer hint', value, max: 256, truncate: true)
    end

    def card_holder_name_hint=(value)
      @card_holder_name_hint = validate_length('card holder name', value, min: 2, max: 45, truncate: true)
    end

    def trace_id=(value)
      @trace_id = validate_length('trace id', value, max: 100)
    end

    def redirect_url=(value)
      @redirect_url = validate_length('redirect url', value, max: 2_000)
    end

    def callback_url=(value)
      @callback_url = validate_length('callback url', value, max: 2_000)
    end

    def order_number=(value)
      @order_number = validate_length('order number', value, max: 100)
    end

    def shipping_address=(address)
      raise ArgumentError, 'shipping address must be an instance of Barion::Address' unless address.instance_of?(Barion::Address)

      @shipping_address = address
    end

    def billing_address=(address)
      raise ArgumentError, 'billing address must be an instance of Barion::Address' unless address.instance_of?(Barion::Address)

      @billing_address = address
    end

    def locale=(value)
      raise ArgumentError, "#{value} is not a valid locale" unless LOCALES.include?(value)

      @locale = value
    end

    def currency=(value)
      raise ArgumentError, "#{value} is not a valid currency" unless CURRENCIES.include?(value)

      @currency = value
    end

    def payer_phone_number=(number)
      @payer_phone_number = format_phone_number(number)
    end

    def payer_work_phone_number=(number)
      @payer_phone_number = format_phone_number(number)
    end

    def payer_home_phone_number=(number)
      @payer_phone_number = format_phone_number(number)
    end

    private

    def generate_payment_request_id
      limit = 100 - @@payment_counter.to_s.length
      @payment_request_id = "#{truncate(@config.shop_acronym, limit)}#{@@payment_counter}"
    end
  end
end
