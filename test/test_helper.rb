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

# Filter out the backtrace from minitest while preserving the one from other libraries.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('fixtures', __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = "#{ActiveSupport::TestCase.fixture_path}/files"
  ActiveSupport::TestCase.fixtures :all
end

module ActiveSupport
  class TestCase
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
