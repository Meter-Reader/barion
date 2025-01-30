# frozen_string_literal: true

require 'barion/engine' if defined?(Rails::Engine)
require 'barion/config'

# Main module of Barion engine
# rubocop:disable Metrics/ModuleLength
module Barion
  BASE_URL = {
    test: 'https://api.test.barion.com',
    prod: 'https://api.barion.com'
  }.freeze

  PIXELID_PATTERN = ::Regexp.new('BP-.{10}-\d{2}').freeze

  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new('1.0', 'Barion')
  end

  def self.config(&_block)
    return Barion::Config.instance unless block_given?

    yield(Barion::Config.instance)
  end

  def self.sandbox
    config.sandbox
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.sandbox=(val)
    config.sandbox = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.sandbox?
    config.sandbox?
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.poskey
    config.poskey
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.poskey=(val)
    config.poskey = (val)
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.publickey
    config.publickey
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.publickey=(val)
    config.publickey = (val)
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.acronym
    config.acronym
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.acronym=(val)
    config.acronym = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.pixel_id
    config.pixel_id
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.pixel_id=(val)
    config.pixel_id = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.default_payee
    config.default_payee
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.default_payee=(val)
    config.default_payee = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.user_class
    config.user_class
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.user_class=(val)
    config.user_class = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.item_class
    config.item_class
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.item_class=(val)
    config.item_class = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.rest_client_class
    config.rest_client_class
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  def self.rest_client_class=(val)
    config.rest_client_class = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Error to signal the data in the db has been changed since saving it
  class TamperedData < RuntimeError
  end

  # Generic error class for Barion module
  class Error < StandardError
    attr_reader :title, :error_code, :happened_at, :auth_data, :endpoint, :errors

    def initialize(params)
      @title = params[:Title]
      @error_code = params[:ErrorCode]
      @happened_at = params[:HappenedAt]
      @auth_data = params[:AuthData]
      @endpoint = params[:Endpoint]
      @errors = Array(params[:Errors]).map { |e| Barion::Error.new(e) } if params.key? :Errors
      super(params[:Description])
    end

    def all_errors
      Array(@errors).map(&:message).join("\n")
    end
  end
end
# rubocop:enable Metrics/ModuleLength
