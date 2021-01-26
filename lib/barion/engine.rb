# frozen_string_literal: true

module Barion
  class Engine < ::Rails::Engine
    isolate_namespace Barion
    engine_name 'barion'
  end
end
