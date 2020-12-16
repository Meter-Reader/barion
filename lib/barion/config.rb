# frozen_string_literal: true

require 'barion/version'

module Barion
  # Holds configuration elements for Barion integration
  class Config
    attr_reader :version
    attr_accessor :poskey, :publickey, :sandbox

    def initialize
      @version = '2'
      @sandbox = true
      @poskey = nil
      @publickey = nil
    end

    def version=(value)
      @version = value || '2'
    end

    def sandbox?
      !!@sandbox
    end
  end
end
