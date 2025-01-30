# frozen_string_literal: true

require 'singleton'

module Barion
  # Encloses all Barion related configuration
  class Config
    include Singleton

    # @!attribute [rw] publickey
    #   Set this to the string provided by Barion registration
    #   @return [String, nil] the public key provided by Barion (default: nil)
    attr_accessor :publickey
    # @!attribute [rw] default_payee
    #   Set this to the registered email address of your shop
    #   @return [String, nil] registered email address for your Barion shop (default: nil)
    attr_accessor :default_payee
    # @!attribute [w] acronym
    #   Set this to the string provided by Barion registration
    #   @return [String, nil] the acronym provided by Barion (default: '')
    attr_writer :acronym
    # @!attribute [r] pixel_id
    #   The pixel ID set up in the initalizer
    #   @return [String, nil] the acronym provided by Barion (default: '')
    attr_reader :pixel_id

    # @!attribute [r] poskey
    #   The POSKey set up in the initalizer
    #   @return [String, nil] the POSKey provided by Barion (default: nil)
    def poskey
      @_poskey || nil
    end

    # The acronym set up in the initalizer
    # @return [String] the acronym provided by Barion (default: '')
    def acronym
      @acronym || ''
    end

    # Set the POSKey for the shop
    #
    # @param key [String] the POSKey provided by Barion
    # @raise [ArgumentError] if the key is not a String
    def poskey=(key)
      unless key.is_a?(String)
        raise ArgumentError,
              "::Barion::Config.poskey must be set to a ::String, got #{key.inspect}"
      end

      @_poskey = key
    end

    # Returns the current sandbox mode setting.
    # Delegates to the sandbox? method to determine the current state.
    #
    # @return [Boolean] true if in sandbox mode, false otherwise
    def sandbox
      sandbox?
    end

    # Returns the current sandbox mode setting.
    #
    # If the sandbox mode was not set explicitly, it defaults to true.
    #
    # @return [Boolean] true if in sandbox mode, false otherwise
    def sandbox?
      @_sandbox = true if @_sandbox.nil?
      @_sandbox
    end

    # Sets the sandbox mode.
    #
    # @param val [Boolean] the desired state for sandbox mode
    #   true to enable sandbox mode, false to disable it
    def sandbox=(val)
      @_sandbox = !!val
    end

    # Sets the Barion Pixel ID.
    #
    # Validates that the provided ID is a string and matches the Barion Pixel ID format.
    #
    # @param id [String] the Barion Pixel ID to set
    # @raise [ArgumentError] if the ID is not a string or does not match the expected format
    def pixel_id=(id)
      unless id.is_a?(String)
        raise ArgumentError,
              "::Barion::Config.pixel_id must be set to a ::String, got #{id.inspect}"
      end

      return if id.empty?

      if PIXELID_PATTERN.match(id).nil?
        raise ::ArgumentError,
              "String:'#{id}' is not in Barion Pixel ID format: 'BP-0000000000-00'"
      end

      @pixel_id = id
    end

    # Returns the REST client endpoint based on the current environment.
    #
    # Determines the environment by checking if the sandbox mode is enabled.
    # If sandbox mode is enabled, the test environment URL is used; otherwise,
    # the production environment URL is used.
    #
    # @return [Object] a new instance of the REST client class initialized with
    #   the appropriate base URL for the current environment.
    def endpoint
      env = sandbox? ? :test : :prod
      rest_client_class.new ::Barion::BASE_URL[env]
    end

    # Sets the user class used for user authentication.
    #
    # Validates that the provided user class is a string.
    #
    # @param class_name [String] the user class to use for user authentication
    # @raise [ArgumentError] if the user class is not a string
    def user_class=(class_name)
      unless class_name.is_a?(String)
        raise ArgumentError, "::Barion:.config.user_class must be set to a ::String, got #{class_name.inspect}"
      end

      @_user_class = class_name
    end

    # Returns the user class set in the initializer.
    #
    # @return [Class] the class set in the initializer
    def user_class
      # This is nil before the initializer is installed.
      return nil if @_user_class.nil?

      @_user_class.constantize
    end

    # Sets the class used for item representation.
    #
    # @param val [Class] the class to use for item representation
    def item_class=(class_name)
      unless class_name.is_a?(String)
        raise ArgumentError, "::Barion.config.item_class must be set to a ::String, got #{class_name.inspect}"
      end

      @_item_class = class_name
    end

    # Returns the item class set in the initializer.
    #
    # This method returns +nil+ until the initializer is installed.
    #
    # @return [Class] the class set in the initializer
    def item_class
      # This is nil before the initializer is installed.
      return nil if @_item_class.nil?

      @_item_class.constantize
    end

    # Returns the class used for making REST calls to the Barion API.
    #
    # If it was not set explicitly, it defaults to `::RestClient::Resource`.
    #
    # @return [Class] the class used for making REST calls
    def rest_client_class
      (@_rest_client_class || '::RestClient::Resource').constantize
    end

    # Sets the class used for making REST calls to the Barion API.
    #
    # The class set with this method is used for making REST calls to the Barion API.
    # It should be set to a class that responds to the same methods as
    # `::RestClient::Resource`.
    #
    # @param class_name [Class, String] the class to use for making REST calls
    def rest_client_class=(class_name)
      unless class_name.is_a?(String)
        raise ArgumentError, "::Barion::Config.rest_client_class must be set to a ::String, got #{class_name.inspect}"
      end

      @_rest_client_class = class_name
    end
  end
end
