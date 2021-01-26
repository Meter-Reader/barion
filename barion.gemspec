# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'barion/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'barion'
  spec.version     = Barion::VERSION
  spec.authors     = ['Péter Nagy']
  spec.email       = ['peter@nagy.consulting']
  spec.homepage    = 'https://www.nagy.consulting'
  spec.summary     = 'Barion payment engine for Ruby on Rails'
  spec.description = 'Barion Payment Zrt. established in 2015 serve customers across the EEA. See https://barion.com for details.'
  spec.license     = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 6.1'
  spec.add_runtime_dependency 'rest-client', '~>2.1'

  spec.add_development_dependency 'annotate'
  spec.add_development_dependency 'debase', '~>0.2'
  spec.add_development_dependency 'faker', '~>2.15'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'ruby-debug-ide', '~>0.7'
  spec.add_development_dependency 'solargraph', '~>0.40'
  spec.add_development_dependency 'sqlite3', '~>1.4'
  spec.add_development_dependency 'yard', '~>0.9'
end
