# frozen_string_literal: true

require 'barion/version'
require 'barion/config'

# Barion solution top level module
module Barion
  class << self
    def config
      @config ||= Barion::Config.new
    end

    def configure
      yield(config)
    end
  end

  class BarionError < StandardError; end
end
