# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'barion/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name                  = 'barion'
  spec.version               = ::Barion::VERSION
  spec.required_ruby_version = '>= 2.5.0'
  spec.authors               = ['Péter Nagy']
  spec.email                 = ['peter@nagy.consulting']
  spec.homepage              = 'https://www.nagy.consulting'
  spec.summary               = 'Barion payment engine for Ruby on Rails'
  spec.description           = <<-DESC
  This is a Ruby-on-Rails engine to use the Barion Payment Gateway in any RoR application.
  DESC
  spec.license = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 6.1'
  spec.add_runtime_dependency 'rest-client', '~> 2.1'

  spec.add_development_dependency 'faker', '~> 2.15'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
  spec.add_development_dependency 'vcr', '~>6.0'
  spec.add_development_dependency 'webmock', '~>3.12'
  spec.add_development_dependency 'yard', '~> 0.9'
end
