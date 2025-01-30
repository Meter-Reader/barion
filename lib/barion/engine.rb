# frozen_string_literal: true

# Module enclosing all Barion related functionality
module Barion
  # Barion engine main class
  class Engine < ::Rails::Engine
    isolate_namespace Barion
    engine_name 'barion'

    config.generators do |g|
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'test/factories'
    end

    initializer 'barion.config', before: :load_config_initializers do |app|
      app.config.barion = Barion.config
    end
  end

  ActiveSupport.on_load(:action_view) do
    # self refers to ActiveRecord::Base here,
    # so we can call .include
    include ::Barion::PixelHelper
  end
end
