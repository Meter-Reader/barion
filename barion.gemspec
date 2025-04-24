# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'barion/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name                  = 'barion'
  spec.version               = Barion::VERSION
  spec.required_ruby_version = '>= 3.4.0'
  spec.authors               = ['Péter Nagy']
  spec.metadata              = { 'rubygems_mfa_required' => 'true' }
  spec.email                 = ['peter@antronin.consulting']
  spec.homepage              = 'https://antronin.consulting'
  spec.summary               = 'Barion payment engine for Ruby on Rails'
  spec.description           = <<-DESC
  This is a Ruby-on-Rails engine to use the Barion Payment Gateway in any RoR application.
  DESC
  spec.license = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  spec.require_paths = ['lib', 'app/helpers/barion', 'app/models/barion', 'app/models/concerns/barion']

  spec.add_dependency 'rails', '~> 7.0'
  spec.add_dependency 'rest-client', '~> 2.1'
end
