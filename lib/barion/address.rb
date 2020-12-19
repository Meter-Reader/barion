# frozen_string_literal: true

require 'barion/validations'
require 'barion/config'

module Barion
  # Represents an address in Barion
  class Address
    include Barion::Validations

    attr_reader :country,
                :city,
                :region,
                :zip,
                :street,
                :street2,
                :street3,
                :full_name

    def initialize
      @country = Barion.configuration.default_country || 'zz'
    end

    def country=(code)
      @country = validate_length('country', code, min: 2, max: 2)
    end

    def zip=(zip)
      @zip = validate_length('zip', zip, max: 16)
    end

    def city=(name)
      @city = validate_length('city', name, max: 50)
    end

    def region=(name)
      @region = validate_length('region', name, min: 2, max: 2)
    end

    def street=(name)
      @street = validate_length('street', name, max: 50)
    end

    def street2=(name)
      @street2 = validate_length('street2', name, max: 50)
    end

    def street3=(name)
      @street3 = validate_length('street3', name, max: 50)
    end

    def full_name=(name)
      @full_name = validate_length('full_name', name, max: 45)
    end
  end
end
