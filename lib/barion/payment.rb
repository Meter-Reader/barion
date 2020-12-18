# frozen_string_literal: true

require 'barion/version'
require 'barion/config'
require 'securerandom'

module Barion
  # Represents a payment in Barion
  class Payment
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
                :payer_home_number

    attr_accessor :payment_request_id,
                  :transactions,
                  :shipping_address,
                  :billing_address,
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
      if (seconds < 60) || (seconds > 31_536_000)
        raise ArgumentError, 'reservation period should be between 1 minute and 1 year'
      end

      @reservation_period = seconds
    end

    def delayed_capture_period=(seconds)
      unless @payment_type == :delayed_capture
        raise ArgumentError, "delayed capture period should only be set if payment type is 'DelayedCapture'"
      end
      if (seconds < 60) || (seconds > 604_800)
        raise ArgumentError, 'delayed capture period should be between 1 minute and 1 year'
      end

      @reservation_period = seconds
    end

    def payment_window=(seconds)
      if (seconds < 1_800) || (seconds > 604_800)
        raise ArgumentError, 'payment window should be between 1 minute and 1 year'
      end

      @payment_window = seconds
    end

    def guest_checkout=(value)
      @guest_checkout = !!value
    end

    def initiate_recurrence=(value)
      @initiate_recurrence = !!value
    end

    def recurrence_id=(value)
      raise ArgumentError, "#{value} is too long for recurrence id" if value.length > 100

      @recurrence_id = value
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
      @payer_hint = truncate(value, 256)
    end

    def card_holder_name_hint=(value)
      if value.to_s.length < 2
        raise ArgumentError, "#{value} is too short, card holder name hint must be between 2 and 45 characters"
      end

      @card_holder_name_hint = truncate(value, 45)
    end

    def trace_id=(value)
      if value.to_s.length > 100
        raise ArgumentError, "#{value} is too long, trace id can be 100 characters long only"
      end

      @trace_id = value
    end

    def redirect_url=(value)
      if value.to_s.length > 2_000
        raise ArgumentError, "#{value} is too long, redirect url can be 2 000 characters long only"
      end

      @redirect_url = value
    end

    def callback_url=(value)
      if value.to_s.length > 2_000
        raise ArgumentError, "#{value} is too long, callback url can be 2 000 characters long only"
      end

      @callback_url = value
    end

    def order_number=(value)
      if value.to_s.length > 100
        raise ArgumentError, "#{value} is too long, order number can be 100 characters long only"
      end

      @order_number = value
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

    def format_phone_number(number)
      number = number.sub(/^\+/, '').sub(/^00/, '')
      raise ArgumentError, "#{number} is too long for phone number" if number.length > 30

      number
    end

    def truncate(str, limit)
      str.to_s[0..limit - 1]
    end

    def generate_payment_request_id
      limit = 100 - @@payment_counter.to_s.length
      @payment_request_id = "#{truncate(@config.shop_acronym, limit)}#{@@payment_counter}"
    end
  end
end
