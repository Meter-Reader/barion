# frozen_string_literal: true

module Barion
  # Barion enviroments
  class Environment
    include Singleton

    BASE_URL = {
      test: 'https://api.test.barion.com',
      prod: 'https://api.barion.com'
    }.freeze

    class << self
      def sandbox
        self.test
      end

      def test
        Barion::TestEnvironment.instance
      end

      def production
        Barion::ProductionEnvironment.instance
      end
    end

    def base_url
      BASE_URL.fetch(@type)
    end
  end

  # Barion test environment settings
  class TestEnvironment < Barion::Environment
    def initialize
      @type = :test
      super
    end
  end

  # Barion production environment settings
  class ProductionEnvironment < Barion::Environment
    def initialize
      @type = :prod
      super
    end
  end
end
