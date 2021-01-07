# frozen_string_literal: true

module Barion
  class Payment < ApplicationRecord
    generate_public_uid column: :payment_request_id, generator: PublicUid::Generators::NumberSecureRandom.new

    CURRENCIES = %i[EUR USD HUF CZK].freeze
    PAYMENT_TYPES = %i[immediate reservation delayed_capture].freeze
    FUNDINGSRCS = %i[all balance].freeze
    LOCALES = %w[cs-CZ de-DE en-US es-ES fr-FR hu-HU sk-SK sl-SI].freeze
    RECURRENCE_TYPES = %i[one_click merchant_initiated recurring].freeze
    CHALLENGES = %i[no_preference challenge_required no_challenge_needed].freeze

    validates :payment_type, presence: true, inclusion: { in: PAYMENT_TYPES }
    validates :reservation_period, presence: true, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1.minute.in_seconds,
      less_than_or_equal_to: 1.year.in_seconds
    }, if: :reservation?

    validates :delayed_capture_period, presence: true, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1.minute.in_seconds,
      less_than_or_equal_to: 1.week.in_seconds
    }, if: :delayed_capture?

    validates :payent_windows, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1.minute.in_seconds,
      less_than_or_equal_to: 1.week.in_seconds
    }
    validates :recurrence_id, length: { maximum: 100 }
    validates :recurrence_type, inclusion: { in: RECURRENCE_TYPES }
    validates :funding_sources, inclusion: { in: FUNDINGSRCS }
    validates :payer_hint, length: { maximum: 256 }
    validates :card_holder_name_hint, length: { maximum: 256 }
    validates :trace_id, length: { maximum: 100 }
    validates :redirect_url, length: { maximum: 2000 }
    validates :callback_url, length: { maximum: 2000 }
    validates :order_number, length: { maximum: 100 }
    validates :locale, inclusion: { in: LOCALES }
    validates :currency, inclusion: { in: CURRENCIES }
    validates :payer_phone_number, length: { maximum: 30 }
    validates :payer_work_phone_number, length: { maximum: 30 }
    validates :payer_home_number, length: { maximum: 30 }

    has_many :transaction

    def guest_checkout=(value)
      @guest_checkout = !!value
    end

    def initiate_recurrence=(value)
      @initiate_recurrence = !!value
    end

    def payer_phone_number=(number)
      @payer_phone_number = format_phone_number(number)
    end

    def payer_work_phone_number=(number)
      @payer_phone_number = format_phone_number(number)
    end

    def payer_home_number=(number)
      @payer_phone_number = format_phone_number(number)
    end

    private

    def format_phone_number(number)
      number.sub(/^\+/, '').sub(/^00/, '')
    end

    def reservation?
      payment_type == :reservation
    end

    def delayed_capture?
      payment_type == :delayed_capture
    end
  end
end
