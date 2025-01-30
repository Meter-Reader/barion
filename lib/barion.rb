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

  # Returns the deprecator instance for the Barion module.
  #
  # This is a singleton method that initializes the deprecator
  # if it hasn't been initialized yet, using ActiveSupport::Deprecation.
  #
  # @return [ActiveSupport::Deprecation] the deprecator instance
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new('1.0', 'Barion')
  end

  # Configure the Barion engine
  #
  # @example
  #   ::Barion.config do |conf|
  #     conf.poskey = 'test'
  #     conf.sandbox = true
  #   end
  def self.config(&_block)
    return Barion::Config.instance unless block_given?

    yield(Barion::Config.instance)
  end

  # Returns whether the Barion engine is in sandbox mode.
  #
  # @return [boolean] whether the engine is in sandbox mode
  # @deprecated
  def self.sandbox
    config.sandbox
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Sets whether the Barion engine is in sandbox mode.
  #
  # @param val [boolean] the desired state for sandbox mode
  #   true to enable sandbox mode, false to disable it
  # @deprecated Use ::Barion.config.sandbox= instead
  def self.sandbox=(val)
    config.sandbox = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Returns whether the Barion engine is in sandbox mode.
  #
  # This method delegates to the Barion::Config instance's sandbox? method
  # to determine the current sandbox mode setting.
  #
  # @return [Boolean] true if in sandbox mode, false otherwise
  # @deprecated Use ::Barion.config.sandbox? instead.
  def self.sandbox?
    config.sandbox?
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Returns the current POSKey setting.
  #
  # @return [String, nil] the current POSKey setting
  # @deprecated Use ::Barion.config.poskey instead.
  def self.poskey
    config.poskey
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Sets the POSKey for the shop.
  #
  # @param val [String] the POSKey provided by Barion
  # @deprecated Use ::Barion.config.poskey= instead
  def self.poskey=(val)
    config.poskey = (val)
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Returns the current PublicKey setting.
  #
  # @return [String, nil] the current PublicKey setting
  def self.publickey
    config.publickey
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Sets the PublicKey for the shop.
  #
  # @param val [String] the PublicKey provided by Barion
  def self.publickey=(val)
    config.publickey = (val)
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Returns the current acronym for Barion.
  #
  # @return [String] the current acronym setting, empty string by default
  def self.acronym
    config.acronym
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Sets the acronym for Barion.
  #
  # @param val [String] the desired acronym, empty string by default
  def self.acronym=(val)
    config.acronym = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Returns the current Barion Pixel ID.
  #
  # The Pixel ID is used for tracking and analytics purposes.
  #
  # @return [String, nil] the current Pixel ID setting
  # @deprecated Use ::Barion.config.pixel_id instead.
  def self.pixel_id
    config.pixel_id
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Sets the Barion Pixel ID.
  #
  # Updates the Barion configuration with the provided Pixel ID.
  # This method is deprecated and it is recommended to use
  # `::Barion.config.pixel_id=` instead.
  #
  # @param val [String] the Pixel ID to set
  def self.pixel_id=(val)
    config.pixel_id = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Returns the current default payee for Barion.
  #
  # The default payee is the default email address to which the payment
  # confirmation email is sent.
  #
  # @return [String] the current default payee setting, empty string by default
  # @deprecated Use ::Barion.config.default_payee instead
  def self.default_payee
    config.default_payee
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Sets the default payee for Barion.
  #
  # Updates the Barion configuration with the provided default payee.
  # This method is deprecated and it is recommended to use
  # `::Barion.config.default_payee=` instead.
  #
  # @param val [String] the default payee to set
  # @deprecated Use ::Barion.config.default_payee= instead
  def self.default_payee=(val)
    config.default_payee = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Returns the class used for user authentication.
  #
  # This method is deprecated and it is recommended to use
  # `::Barion.config.user_class` instead.
  # @deprecated Use ::Barion.config.user_class instead
  def self.user_class
    config.user_class
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Sets the class used for user authentication.
  #
  # Updates the Barion configuration with the provided user class.
  # This method is deprecated and it is recommended to use
  # `::Barion.config.user_class=` instead.
  #
  # @param val [Class] the class to use for user authentication
  # @deprecated Use ::Barion.config.user_class= instead
  def self.user_class=(val)
    config.user_class = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Returns the class used for item representation.
  #
  # This method is deprecated and it is recommended to use
  # `::Barion.config.item_class` instead.
  # @deprecated Use ::Barion.config.item_class instead
  # @return [Class] the class used for item representation
  # @deprecated Use ::Barion.config.item_class instead
  def self.item_class
    config.item_class
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Sets the class used for item representation.
  #
  # Updates the Barion configuration with the provided item class.
  # This method is deprecated and it is recommended to use
  # `::Barion.config.item_class=` instead.
  #
  # @param val [Class] the class to use for item representation
  # @deprecated Use ::Barion.config.item_class= instead
  # @deprecated Use ::Barion.config.item_class= instead
  def self.item_class=(val)
    config.item_class = val
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Returns the class used for making REST calls to the Barion API.
  #
  # This method is deprecated and it is recommended to use
  # `::Barion.config.rest_client_class` instead.
  # @deprecated Use ::Barion.config.rest_client_class instead
  # @return [Class] the class used for making REST calls
  def self.rest_client_class
    config.rest_client_class
    deprecator.warn(
      "#{__method__} is deprecated. " \
      "Use ::Barion.config.#{__method__} instead."
    )
  end

  # Sets the class used for making REST calls to the Barion API.
  #
  # Updates the Barion configuration with the provided REST client class.
  # This method is deprecated and it is recommended to use
  # `::Barion.config.rest_client_class=` instead.
  #
  # @param val [Class] the class to use for making REST calls
  # @deprecated Use ::Barion.config.rest_client_class= instead
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
    attr_reader :title, :error_code, :happened_at, :auth_data, :endpoint, :errors, :description

    # Creates a new instance of the Barion::Error class. It can hold nested errors.
    #
    # @param params [Hash] a hash containing the error data
    # @option params [String] :Title the title of the error
    # @option params [Integer] :ErrorCode the error code
    # @option params [String] :HappenedAt when the error happened in ISO 8601 format
    # @option params [String] :AuthData authentication data
    # @option params [String] :Endpoint the endpoint where the error happened
    # @option params [Array<Hash>] :Errors the errors that happened
    # @option params [String] :Description the description of the error
    def initialize(params)
      @title = params[:Title]
      @error_code = params[:ErrorCode]
      @happened_at = params[:HappenedAt]
      @auth_data = params[:AuthData]
      @endpoint = params[:Endpoint]
      @errors = Array(params[:Errors]).map { |e| Barion::Error.new(e) } if params.key? :Errors
      @description = params[:Description]
      super(@description)
    end

    # Returns all errors that happened in the request in a single string
    #
    # @return [String] all errors that happened in the request
    def all_errors
      Array(@errors).map(&:message).join("\n")
    end
  end
end
# rubocop:enable Metrics/ModuleLength
