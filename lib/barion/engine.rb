# frozen_string_literal: true

module Barion
  # Barion engine main class
  class Engine < ::Rails::Engine
    isolate_namespace Barion
    engine_name 'barion'

    config.generators do |g|
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'test/factories'
    end
  end
end
