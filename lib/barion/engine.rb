# frozen_string_literal: true

module Barion
  class Engine < ::Rails::Engine
    isolate_namespace Barion
    engine_name 'barion'

    class << self
      mattr_accessor :poskey, default: nil
      mattr_accessor :publickey, default: nil
      mattr_accessor :acronym, default: ''
      mattr_accessor :sandbox, default: true
      mattr_accessor :default_country, default: 'zz'

      def sandbox?
        !!Barion.sandbox
      end

      def sandbox=(val)
        Barion.sandbox = !!val
      end
    end
  end
end
