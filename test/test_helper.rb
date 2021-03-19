# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
ENV['COVERAGE_REPORTS'] = 'test-reports'
ENV['TESTRESULTS_REPORTS'] = 'test-results'

if ENV['CODECOV']
  require 'simplecov'
  require 'minitest/reporters'

  Minitest::Reporters.use! [
    Minitest::Reporters::DefaultReporter.new,
    Minitest::Reporters::MeanTimeReporter.new,
    Minitest::Reporters::JUnitReporter.new(ENV['TESTRESULTS_REPORTS'])
  ]
end
require_relative '../test/dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require 'rails/test_help'
require 'factory_bot_rails'

FactoryBot.definition_file_paths << File.expand_path('../test/factories', __dir__)
FactoryBot.find_definitions

# Filter out the backtrace from minitest while preserving the one from other libraries.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

module ActiveSupport
  # Extends ActiveSupport:TestCase
  class TestCase
    include FactoryBot::Syntax::Methods

    def assert_valid(model)
      assert model.valid?, model.errors.objects.first.try(:full_message)
    end

    def refute_valid(model)
      refute model.valid?
    end
  end
end

require 'minitest/autorun'
require 'faker'
require 'webmock/minitest'
require 'vcr'
require 'English'

VCR.configure do |config|
  config.cassette_library_dir = 'test/recorded_ios'
  config.hook_into :webmock
  config.filter_sensitive_data('<POSKEY>') { ENV['TEST_POSKEY'] }
  config.filter_sensitive_data('<PAYEE>') { ENV['TEST_PAYEE'] }
end
