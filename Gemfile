# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :development, :test do
  gem 'codecov', require: false
  gem 'factory_bot_rails'
  gem 'minitest'
  gem 'minitest-reporters', require: false
  gem 'rubocop'
  gem 'rubocop-factory_bot'
  gem 'rubocop-minitest'
  gem 'rubocop-rake'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura', require: false
  gem 'sqlite3', '~>1.7'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'annotate'
  gem 'faker'
  gem 'overcommit'
  gem 'puma'
  gem 'rake'
  gem 'yard'
end
