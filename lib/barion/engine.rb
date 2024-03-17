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
  end

  ActiveSupport.on_load(:action_view) do
    # self refers to ActiveRecord::Base here,
    # so we can call .include
    include ::Barion::PixelHelper
  end

  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new('1.0', 'Barion')
  end
end
