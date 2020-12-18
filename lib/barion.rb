# frozen_string_literal: true

require 'barion/version'
require 'barion/config'

# Barion solution top level module
module Barion
  class << self
    attr_accessor :configuration

    def configure
      @configuration ||= Barion::Config.new
      yield(@configuration) if block_given?
    end

    def reset
      @configuration = Barion::Config.new
    end
  end

  class BarionError < StandardError; end
end
