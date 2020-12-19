# frozen_string_literal: true

require 'barion/validations'

module Barion
  # Holds configuration elements for Barion integration
  class Config
    include Barion::Validations

    attr_reader :version,
                :default_country
    attr_accessor :poskey,
                  :publickey,
                  :sandbox,
                  :shop_acronym

    def initialize
      @version = '2'
      @sandbox = true
      @poskey = nil
      @publickey = nil
      @shop_acronym = nil
      @default_country = 'zz'
    end

    def version=(value)
      @version = value || '2'
    end

    def sandbox?
      !!@sandbox
    end

    def default_country=(code)
      @default_country = validate_length('default country', code, min: 2, max: 2)
    end
  end
end
