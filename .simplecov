# frozen_string_literal: true

SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/features/'
  add_filter '/config/'
  add_filter '/bin/'
  add_filter '/deploy/'
  add_filter '/lib/tasks/'
  add_group 'Models', '/app/models'
  add_group 'Controllers', '/app/controllers'
  add_group 'Helpers', '/app/helpers'
  add_group 'Libraries', '/lib'
end
SimpleCov.coverage_dir('test-results/codecoverage')
require 'simplecov-cobertura'
require 'codecov'
SimpleCov.formatters = [SimpleCov::Formatter::Codecov, SimpleCov::Formatter::CoberturaFormatter]
