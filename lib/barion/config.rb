# frozen_string_literal: true

require 'singleton'

module Barion
  # Encloses all Barion related configuration
  class Config
    include Singleton

    attr_accessor :publickey, :default_payee
    attr_writer :acronym
    attr_reader :pixel_id, :sandbox

    def poskey
      @poskey || nil
    end

    def acronym
      @acronym || ''
    end

    def poskey=(key)
      unless key.is_a?(String)
        raise ArgumentError,
              "::Barion::Config.poskey must be set to a ::String, got #{key.inspect}"
      end

      @poskey = key
    end

    def sandbox?
      if @sandbox.present?
        true
      else
        @sandbox
      end
    end

    def sandbox=(val)
      @sandbox = !!val
    end

    def pixel_id=(id)
      unless id.is_a?(String)
        raise ArgumentError,
              "::Barion::Config.pixel_id must be set to a ::String, got #{id.inspect}"
      end

      if PIXELID_PATTERN.match(id).nil?
        raise ::ArgumentError,
              "String:'#{id}' is not in Barion Pixel ID format: 'BP-0000000000-00'"
      end

      @pixel_id = id
    end

    def endpoint
      env = sandbox? ? :test : :prod
      rest_client_class.new ::Barion::BASE_URL[env]
    end

    def user_class=(class_name)
      unless class_name.is_a?(String)
        raise ArgumentError, "::Barion::Config.user_class must be set to a ::String, got #{class_name.inspect}"
      end

      @user_class = class_name
    end

    def user_class
      # This is nil before the initializer is installed.
      return nil if @user_class.nil?

      @user_class.constantize
    end

    def item_class=(class_name)
      unless class_name.is_a?(String)
        raise ArgumentError, "::Barion::Config.item_class must be set to a ::String, got #{class_name.inspect}"
      end

      @item_class = class_name
    end

    def item_class
      # This is nil before the initializer is installed.
      return nil if @item_class.nil?

      @item_class.constantize
    end

    def rest_client_class
      (@rest_client_class || '::RestClient::Resource').constantize
    end

    def rest_client_class=(class_name)
      unless class_name.is_a?(String)
        raise ArgumentError, "::Barion::Config.rest_client_class must be set to a ::String, got #{class_name.inspect}"
      end

      @rest_client_class = class_name
    end
  end
end
